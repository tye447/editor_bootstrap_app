class Editor < HyperComponent
  include Hyperstack::Router::Helpers
  render do
    DIV(class: 'vh-100',style: { display:'grid', 'gridTemplateRows': '5fr 95fr', 'gridTemplateColumns': '9fr 3fr' } ) do
      top
      preview
      VariableParam( array_variable:@array_variables ).on(:variable_changed) do |variable|
        change_variable_value(variable)
      end
      loader
    end
  end

  after_mount do
    init
  end

  def init
    show_loader
    HTTP.get("/functions.scss") do |res_func|
      @functions = res_func.body
      HTTP.get("/flat_bootstrap.scss") do |res_bootstrap|
        @bootstrap =  res_bootstrap.body
        HTTP.get("/default_variable.scss") do |res_var|
          @default_variable_file =  res_var.body
          initial_compile_css
          initial_variables
          @ast = @default_ast.clone
          @array_variables = @default_array_variables
        end
      end
    end
  end

  def update_variables
    unless @variable_file.nil?
      @ast = Sass.parse(@variable_file)
      @array_variables = @ast.find_declaration_variables
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
      @default_ast = Sass.parse(@default_variable_file)
      @ast = @default_ast.clone
      @default_array_variables = @default_ast.find_declaration_variables
      @array_variables = @default_array_variables.clone
    end
  end

  def initial_compile_css
    show_loader
    @initial_combinaison = @functions.to_s+"\n"+@default_variable_file.to_s+"\n"+@bootstrap.to_s+"\n"
    Sass.compile(@initial_combinaison) do |result|
      @default_css_string = result['text']
      update_preview(@default_css_string)
      hide_loader
      mutate
    end
  end

  def compile_css
    show_loader
    @combinaison = @functions.to_s+"\n"+@variable_file.to_s+"\n"+@default_variable_file.to_s+"\n"+@bootstrap.to_s+"\n"+@custom_file.to_s+"\n"
    Sass.compile(@combinaison) do |result|
      @css_string = result['text']
      update_preview(@css_string)
      hide_loader
      mutate
    end
  end

  def show_loader
    ::Element.find('#loader').show()
  end

  def hide_loader
    ::Element.find('#loader').hide()
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
            compile_css
            
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
            compile_css
            
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
        @array_variables = @default_ast.find_declaration_variables
        update_preview(@default_css_string)
        @css_string = @default_css_string
        @variable_file = @default_variable_file
        @custom_file = ""
        ::Element.find('#fileVariable').val("");
        ::Element.find('#fileCustom').val("");
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
          `download(#{@variable_file}, "variable.scss", "text/plain");`
        end
        A(class:"dropdown-item",href:"#"){"custom.scss"}.on(:click) do |evt|
          evt.prevent_default
          `download(#{@custom_file}, "custom.scss", "text/plain");`
        end
      }
    end
  end

  def preview
    DIV(style:{'gridColumn':'1','gridRow':'2'}) do
      IFRAME(class:"w-100 h-100 border-0", src:"/preview.html")
    end
  end

  def change_variable_value(variable)
    unless @ast.nil?
      @timer&.abort
      @timer = after(1) do
        @ast.replace(variable['name'],variable['type'],variable['value'])
        @variable_file = @ast.stringify
        compile_css
        @timer = nil
      end
    end
  end

  def loader
    DIV(id: 'loader', class: 'spinner-border position-absolute',style:{ display: "none", top: "50%", left: "50%", width: "6em", height: "6em" }) do
      SPAN(class: 'sr-only') do
      end
    end
  end
  
end