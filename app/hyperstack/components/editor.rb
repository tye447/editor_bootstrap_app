class Editor < HyperComponent
  include Hyperstack::Router::Helpers

  CLIENT_SIDE_COMPILATION = true

  render do
    DIV(class: 'vh-100',style: { display:'grid', 'gridTemplateRows': '5fr 95fr', 'gridTemplateColumns': '9fr 3fr' } ) do
      top
      preview
      variable_panel
      loader
      error_message
    end
  end

  after_mount do
    init
  end

  def error_message
    DIV(id: 'error', class: 'alert alert-warning alert-dismissible fixed-top', role: 'alert', style: {'display': 'none'}) do
      STRONG{"SASS Error: "}
      SPAN(id: 'error_message', class: 'mr-auto')
      BUTTON(type: 'button', class: 'ml-2 mb-1 close'){
        SPAN('aria-hidden': 'true'){"×"}
      }.on(:click) do
        hide_error
      end
    end
  end

  def top
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
          @file = evt.target.files[0].text()
          @file.then{|result|
            mutate @variable_file = result
            update_variables
            compile_css(initial: false)
          }
        end
        LABEL(class:"custom-file-label", htmlFor:'fileVariable'){"Variable File"}
      end
    end

  end

  def input_custom_file

    DIV(class:'input-group mr-1 w-auto') do
      DIV(class:'custom-file') do
        INPUT(type: :file,class: 'custom-file-input', id:"fileCustom").on(:change) do |evt|
          @file = evt.target.files[0].text()
          @file.then{|result|
            mutate @custom_file = result
            compile_css(initial: false)

          }
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
        # @css_string = @default_css_string
        # @variable_file = @default_variable_file
        #@custom_file = ""
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

  def preview
    IFRAME(class:"w-100 h-100 border-0", style:{'gridArea': ' 2 / 1 / auto / auto'}, src:"/preview.html")
  end

  def variable_panel
    unless @variable_array.nil?
      VariablePanel(variable_array: @variable_array).on(:variable_changed) do |variable, change_choice|
        change_variable_value(variable, change_choice)
      end
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
          compile_css(initial: true)
          initial_variables
          mutate
        end
      end
    end
  end

  def update_variables
    unless @variable_file.nil?
      @var_ast = Sass.parse(@variable_file)
      unless @var_ast.nil?
        @var_variables = @var_ast.find_declaration_variables
        @variable_array = @default_variable_array
        confusion_arraies
        mutate
      end
    end
  end

  def confusion_arraies
    unless @var_variables.nil?
      @var_variables.each do |item|
        target = @variable_array.find{|e| e['name'] == item['name']}
        unless target.nil?
          if target['value'] != item['value']
            @ast.replace(item, change: 'value')
            target['value'] = item['value']
          end
          if target['unit'] != item['unit']
            @ast.replace(item, change: 'unit')
            target['unit'] = item['unit']
          end
        end
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
    unless @default_variable_file.nil?
      # init custome file and variable file
      @custom_file = ""
      @variable_file = ""
      # store the default ast
      @default_ast = Sass.parse(@default_variable_file)
      @ast = Sass.parse(@default_variable_file)
      # store the default variables array
      @default_variable_array = @default_ast.find_declaration_variables
      @variable_array = @ast.find_declaration_variables
      ::Element.find('#fileVariable').val("");
      ::Element.find('#fileCustom').val("");
    end
  end

  def compile_css(options = {})
    # compile as a css string

    show_loader
    if options[:initial]
      @combinaison = @functions.to_s+"\n"+@default_variable_file.to_s+"\n"+@bootstrap.to_s+"\n"
    else
      @combinaison = @functions.to_s+"\n"+@variable_file.to_s+"\n"+@default_variable_file.to_s+"\n"+@bootstrap.to_s+"\n"+@custom_file.to_s+"\n"
    end

    after(0) do
      if CLIENT_SIDE_COMPILATION
        Sass.compile(@combinaison) do |result|
          unless result.nil?
            if result['status']==1
              # return error message
              @errorMessage = result['message'].to_s
              show_error(@errorMessage)
            else
              # return css string and apply it into the iframe
              @css_string = result['text']
              if options[:initial]
                @default_css_string  = @css_string
              end
              update_preview(@css_string)
            end
            hide_loader
          end
        end
      else
        HTTP.post("/compile_css", payload: {scss: @combinaison}) do |response|
          # get response status
          @status = response.json['status']
          if(@status != 'ok')
            # return error message
            @errorMessage = response.json['message'].to_s
            show_error(@errorMessage)
          else
            # return css string and apply it into the iframe
            @css_string = response.json['message'].to_s
            if options[:initial]
              @default_css_string  = @css_string
            end
            update_preview(@css_string)
          end
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

  def show_error(error)
    ::Element.find('#error').show()
    ::Element.find('#error_message').html(error)
  end

  def hide_error
    ::Element.find('#error').hide()
  end

  def change_variable_value(variable, change_choice)
    unless @ast.nil? || variable.nil?
      @timer&.abort
      @timer = after(1) do
        # replace the value or the unit of the variable
        @ast.replace(variable, change: change_choice)
        @variable_file = @ast.stringify
        puts @variable_file
        compile_css(initial: false)
        @timer = nil
      end
    end
  end
end