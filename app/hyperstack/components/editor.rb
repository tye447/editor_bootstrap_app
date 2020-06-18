class Editor < HyperComponent
  include Hyperstack::Router::Helpers
  render do
    DIV(class: 'vh-100',style:{display:'grid', 'gridTemplateRows': '5fr 95fr','gridTemplateColumns': '9fr 3fr'}) do
      top
      preview
      param
      loader
    end
  end

  after_mount do
    init
  end

  def init
    @variable = ""
    @default_variable =""
    show_loader
    HTTP.get("/functions.scss") do |res_func|
      @functions = res_func.body
      HTTP.get("/flat_bootstrap.scss") do |response|
        @bootstrap =  response.body
        HTTP.get("/default_variable.scss") do |response2|
          @default_variable =  response2.body
          compile_css
          update_variables
          update_preview
          mutate
        end
      end
    end
  end

  def update_variables
    puts 'update_variables'
    if @variable == "" 
      @variable = @default_variable
    end
    @ast = Sass.parse(@variable)
    @array = @ast.find_declaration_variables
  end

  def update_preview
    return unless @css_string.present?
    `
      var frame = top.document.querySelector('iframe');
      frame.contentWindow.postMessage(#{@css_string},'/');
    `
  end

  def compile_css
    puts 'compile_css'
    show_loader
    @combinaison = @functions.to_s+"\n"+@variable.to_s+"\n"+@default_variable.to_s+"\n"+@bootstrap.to_s+"\n"+@custom.to_s+"\n"
    Sass.compile(@combinaison) do |result|
      @css_string = result['text']
      update_preview
      puts "end compile"
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
            @variable = result
            update_variables
            compile_css
            mutate
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
            @custom = result
            compile_css
            mutate
          } 
        end
        LABEL(class:"custom-file-label", htmlFor:'fileCustom'){"Custom File"}
      end
    end
  end

  def reset
    DIV(class:"mr-1") do
      BUTTON(class:'btn btn-danger'){"Reset"}.on(:click) do
        init
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
          `download(#{@variable}, "variable.scss", "text/plain");`
        end
        A(class:"dropdown-item",href:"#"){"custom.scss"}.on(:click) do |evt|
          evt.prevent_default
          `download(#{@custom}, "custom.scss", "text/plain");`
        end
      }
    end
  end

  
  
  def preview
    DIV(style:{'gridColumn':'1','gridRow':'2'}) do
      IFRAME(class:"w-100 h-100 border-0", src:"/preview.html")
    end
  end

  def param
    DIV(class:'col', style:{'gridColumn':'2','gridRow':'2',overflowY: 'auto'}) do
      unless @array.nil?
        FORM do
          @array.each do |v|
            Input(v:v).on(:value_changed) do |v_bis|
              change_value(v_bis)
            end
          end
        end
      end
    end
  end

  def change_value(v)
    @timer&.abort
    @timer = after(1) do
      @ast.replace(v['name'],v['type'],v['value'])
      @variable = @ast.stringify
      compile_css
      @timer = nil
    end
  end

  def input_variable(v)
    INPUT(type: :text, class:"form-control", value:v['value'])
    .on(:change) do |evt|
      mutate v['value'] = evt.target.value
      change_value(v)
    end
  end

  def input_color(v)
    puts "input_color"
    DIV(class:"input-group-prepend") do
      INPUT(type: :color, class:"form-control", style:{"width":"50px","backgroundColor":"#e9ecef"}, value: v['value'])
      .on(:change) do |evt|
        mutate v['value'] = evt.target.value
        change_value(v)
      end
    end
    INPUT(type: :text, class:"form-control", value:v['value'])
    .on(:change) do |evt|
      mutate v['value'] = evt.target.value
      change_value(v)
    end
  end
  
  def input_string(v)
    input_variable(v)
  end

  def input_number(v)
    INPUT(type: :number, class:"form-control", value:v['value'])
    .on(:change) do |evt|
      mutate v['value'] = evt.target.value
      change_value(v)
    end
    DIV(class:"input-group-append") do
      SPAN(class:"input-group-text"){v['unit']}
    end
  end

  def loader
    DIV(id: 'loader', class: 'spinner-border position-absolute',style:{ display: "none", top: "50%", left: "50%", width: "6em", height: "6em" }) do
      SPAN(class: 'sr-only') do
      end
    end
  end
  
end