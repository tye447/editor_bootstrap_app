class Editor < HyperComponent
  include Hyperstack::Router::Helpers

  CLIENT_SIDE_COMPILATION = true

  render do
    DIV(class: 'vh-100',style: { display:'grid', 'gridTemplateRows': '5fr 95fr', 'gridTemplateColumns': '9fr 3fr' } ) do
      header
      Preview()
      variable_panel
      loader
      ErrorMessage()
    end
  end

  after_mount do
    init
  end

  # components
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
              @import_variable_file = result
              update_variables
              mutate
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
          `download(#{@export_variable_file}, "variable.scss", "text/plain");`
        end
        A(class:"dropdown-item",href:"#"){"custom.scss"}.on(:click) do |evt|
          evt.prevent_default
          `download(#{@custom_file}, "custom.scss", "text/plain");`
        end
      }
    end
  end

  def variable_panel
    VariablePanel(variable_array: @variable_array).on(:variable_changed) do |variable|
      change_variable_value(variable)
    end.on(:type_changed) do |variable|
      change_variable_type(variable)
    end
  end
  def loader
    DIV(id: 'loader', class: 'spinner-border position-absolute',style:{ display: "none", top: "50%", left: "50%", width: "6em", height: "6em" }) do
      SPAN(class: 'sr-only') do
      end
    end
  end


  # methods
  def init
    show_loader
    HTTP.get("/functions.scss") do |res_func|
      @functions = res_func.body
      HTTP.get("/flat_bootstrap.scss") do |res_bootstrap|
        @bootstrap =  res_bootstrap.body
        HTTP.get("/default_variable.scss") do |res_var|
          @default_variable_file =  res_var.body
          # store the default variables array
          @default_variable_ast = Sass.parse(@default_variable_file)
          @ast = @default_variable_ast.duplicate
          @default_variable_array = @default_variable_ast.find_declaration_variables
          initial_variables
          compile_css(initial: true)
          mutate
        end
      end
    end
  end

  def update_variables
    # write import variable file into variable file
    @import_variable_array = Sass.parse(@import_variable_file).find_declaration_variables
    @import_variable_array.each do |item|

      if @default_variable_array.map {|x| x.values[1]}.uniq.include?(item['name'])
        @old_variable_array.push(item)
      else
        @new_variable_array.push(item)
      end
    end

    @old_variable_array = remove_duplicate(@old_variable_array)
    @new_variable_array = remove_duplicate(@new_variable_array)

    @old_variable_array.each do |item|
      @ast.replace(item)
    end

    @variable_name_array = @variable_array.map {|x| x.values[1]}.uniq

    @new_variable_array.each do |item|
      if @variable_name_array.include?(item['name'])
        @ast.replace(item)
      else
        @ast.add(item,@new_variable_array.index(item))
      end
    end
    @variable_file = @ast.stringify
    @export_variable_file = @ast.find_changed_value
    @variable_array = @ast.find_declaration_variables
  end

  def remove_duplicate(array)
    new_array = []
    variable_name_array = array.map {|x| x.values[1]}.uniq
    variable_name_array.each do |item_name|
      target = array.select{|x| x['name'] == item_name}
      new_array.push(target.last)
    end
    return new_array
  end

  def change_variable_value(variable)
    @timer&.abort
    @timer = after(1) do
      # add the changed value to variable file
      @ast.replace(variable)
      @variable_file = @ast.stringify
      @export_variable_file = @ast.find_changed_value
      target = @variable_array.find {|x| x['name'] == variable['name']}
      target['value'] = variable['value']
      target['unit'] = variable['unit']
      compile_css(initial: false)
      @timer = nil
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
    @import_variable_file = ""
    @export_variable_file = ""
    # array to stock all the variables changed
    @ast = @default_variable_ast.duplicate
    ::Element.find('#fileVariable').val("")
    ::Element.find('#fileCustom').val("")
    # init ast and array
    @variable_array = clone_deep(@default_variable_array)
    @old_variable_array = []
    @new_variable_array = []
    mutate
  end

  def clone_deep(object)
    @result = `lodash.cloneDeep(#{object});`
    return @result
  end

  def compile_css(options = {})
    # compile as a css string
    show_loader
    if options[:initial]
      @combinaison = @functions.to_s + "\n"+ @default_variable_file.to_s + "\n" + @bootstrap.to_s + "\n"
    else
      @combinaison = @functions.to_s + "\n"+ @variable_file.to_s + "\n" + @bootstrap.to_s + "\n" + @custom_file.to_s + "\n"
    end
    after(0) do
      if CLIENT_SIDE_COMPILATION
        Sass.compile(@combinaison) do |result|
          unless result.nil?
            if result['status']==1
              # show error message
              show_error(result['message'].to_s)
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
          if response.json['status'] != 'ok'
            # show error message
            show_error(result['message'].to_s)
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

  def show_error(error_message)
    `
    $(".toast").show();
    $("#error").html(#{error_message});
    $(".toast").toast('show');
    `
  end

  def show_loader
    ::Element.find('#loader').show()
  end

  def hide_loader
    ::Element.find('#loader').hide()
  end

  def change_variable_type(variable)
    target = @variable_array.find{|item| item['name'] == variable['name']}
    target['type'] = variable['type']
  end

end
