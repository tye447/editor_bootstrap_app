class Editor < HyperComponent
  include Hyperstack::Router::Helpers

  CLIENT_SIDE_COMPILATION = true

  render do
    DIV(class: 'vh-100',style: { display:'grid', 'gridTemplateRows': '5fr 95fr', 'gridTemplateColumns': '9fr 3fr' } ) do
      header
      # IFRAME(class:"w-100 h-100 border-0", style:{'gridArea': ' 2 / 1 / auto / auto'}, src:"/preview.html")
      Preview()
      VariablePanel(variable_array: @variable_array).on(:variable_changed) do |variable|
        change_variable_value(variable)
      end
      loader
      ErrorMessage()
    end
  end

  after_mount do
    init
  end

  def header
    DIV(class:"d-flex pl-3 pr-3 mb-2 mt-2",style:{"gridColumnStart":"1","gridColumnEnd":"3"}) do
      input_variable_file
      input_custom_file
      download
      spacer
      reset
    end
  end

  def input_variable_file
    DIV(class:'input-group w-auto mr-1') do
      DIV(class:'custom-file') do
        INPUT(type: :file, class: 'custom-file-input', id:"fileVariable").on(:change) do |evt|
          @file = evt.target.files[0]
          unless @file.nil?
            @file_content = @file.text()
            @file_content.then{|result|
              @variable_file = result
              update_variables
              compile_css(initial: false)
            }
          end
        end
        LABEL(class:"custom-file-label", htmlFor:'fileVariable'){"Variable File"}
      end
    end

  end

  def input_custom_file

    DIV(class:'input-group mr-1 w-auto') do
      DIV(class:'custom-file') do
        INPUT(type: :file,class: 'custom-file-input', id:"fileCustom").on(:change) do |evt|
          @file = evt.target.files[0]
          unless @file.nil?
            @file_content = @file.text()
            @file_content.then{|result|
              @custom_file = result
              compile_css(initial: false)
            }
          end
        end
        LABEL(class:"custom-file-label", htmlFor:'fileCustom'){"Custom File"}
      end
    end
  end

  def reset
    DIV(class:"mr-1") do
      BUTTON(class:'btn btn-danger'){"Reset"}.on(:click) do
        show_loader
        initial_variables
        update_preview(@default_css_string)
        hide_loader
        mutate
      end
    end
  end

  def spacer
    DIV(class:"flex-grow-1") do

    end
  end

  def download
    DIV(class:"mr-1") do
      BUTTON(type: :button,class:"btn btn-outline-primary dropdown-toggle",'data-toggle':"dropdown",'aria-haspopup':"true",'aria-expanded':"false"){"Download"}
      DIV(class:"dropdown-menu"){
        A(class:"dropdown-item",href:"#"){"bootstrap.css"}.on(:click) do |evt|
          evt.prevent_default
          `download(#{@css_string}, "bootstrap.css", "text/plain");`
        end
        A(class:"dropdown-item",href:"#"){"variable.scss"}.on(:click) do |evt|
          evt.prevent_default
          if @variable_file == ""
            `download(#{@default_variable_file}, "variable.scss", "text/plain");`
          else
            `download(#{@variable_file}, "variable.scss", "text/plain");`
          end
        end
        A(class:"dropdown-item",href:"#"){"custom.scss"}.on(:click) do |evt|
          evt.prevent_default
          `download(#{@custom_file}, "custom.scss", "text/plain");`
        end
      }
    end
  end
  def loader
    DIV(id: 'loader', class: 'spinner-border position-absolute',style:{ display: "none", top: "50%", left: "50%", width: "6em", height: "6em" }) do
      SPAN(class: 'sr-only') do
      end
    end
  end

  def init
    show_loader
    HTTP.get("/functions.scss") do |res_func|
      @functions = res_func.body
      HTTP.get("/flat_bootstrap.scss") do |res_bootstrap|
        @bootstrap =  res_bootstrap.body
        HTTP.get("/default_variable.scss") do |res_var|
          @default_variable_file =  res_var.body
          unless @default_variable_file.nil?
            # store the default ast for reset
            @default_ast = Sass.parse(@default_variable_file)
            # store the default variables array
            @default_variable_array = @default_ast.find_declaration_variables
          end
          initial_variables
          compile_css(initial: true)
        end
      end
    end
  end

  def update_variables
    unless @variable_file.nil?
      @var_ast = Sass.parse(@variable_file)
      unless @var_ast.nil?
        # get array for the variable file imported
        @ast.merge(@var_ast)
        @variable_array = @ast.find_declaration_variables
        @variable_file =  @ast.stringify
      end
    end
  end

  def update_preview(css_string)
    return unless css_string.present?
    `
      var frame = top.document.querySelector('iframe');
      frame.contentWindow.postMessage(#{css_string},'/');
    `
  end

  def initial_variables
    # init custom file and variable file
    @custom_file = ""
    @variable_file = ""
    ::Element.find('#fileVariable').val("");
    ::Element.find('#fileCustom').val("");
    # init ast and array
    unless @default_ast.nil?
      @ast = @default_ast.deep_dup
      unless @default_variable_array.nil?
        @variable_array = deep_dup(@default_variable_array)
      end
    end
  end

  def deep_dup(object)
    @result = `lodash.cloneDeep(#{object});`
    return @result
  end

  def compile_css(options = {})
    # compile as a css string

    show_loader
    if options[:initial]
      @combinaison = @functions.to_s+"\n"+@default_variable_file.to_s+"\n"+@bootstrap.to_s+"\n"
    else
      @combinaison = @functions.to_s+"\n"+@variable_file.to_s+"\n"+@bootstrap.to_s+"\n"+@custom_file.to_s+"\n"
    end

    after(0) do
      if CLIENT_SIDE_COMPILATION
        Sass.compile(@combinaison) do |result|
          unless result.nil?
            if result['status']==1
              # return error message
              @error_message = result['message'].to_s
              `
              $(".toast").show();
              $("#error").html(#{@error_message});
              $(".toast").toast('show');
              `
            else
              # return css string and apply it into the iframe
              @css_string = result['text']
              if options[:initial]
                @default_css_string  = @css_string
              end
              update_preview(@css_string)
            end
            mutate
            hide_loader
          end
        end
      else
        HTTP.post("/compile_css", payload: {scss: @combinaison}) do |response|
          # get response status
          @status = response.json['status']
          if(@status != 'ok')
            # return error message
            @error_message = result['message'].to_s
              `$(".toast").show();
              $("#error").html(#{@error_message});
              $(".toast").toast('show');
              `
          else
            # return css string and apply it into the iframe
            @css_string = response.json['message'].to_s
            if options[:initial]
              @default_css_string  = @css_string
            end
            update_preview(@css_string)
          end
          mutate
          hide_loader
        end

      end
    end
  end

  def show_loader
    ::Element.find('#loader').show()
  end

  def hide_loader
    ::Element.find('#loader').hide()
  end

  def change_variable_value(variable)
    unless @ast.nil? || variable.nil?
      @timer&.abort
      @timer = after(1) do
        # replace the value or the unit of the variable
        @ast.replace(variable)
        @variable_file = @ast.stringify
        compile_css(initial: false)
        @timer = nil
      end
    end
  end
end