class Editor < HyperComponent
  include Hyperstack::Router::Helpers
  render do
    DIV(class: 'container-fluid') do
      top
      DIV(class: 'row') do
        preview
        param
      end
      loader
    end
  end

  after_mount do
    init
  end

  def init
    @variable = ""
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
    ::Element.find('#loader').show()
    @combinaison = @functions.to_s+"\n"+@variable.to_s+"\n"+@default_variable.to_s+"\n"+@bootstrap.to_s+"\n"+@custom.to_s+"\n"

    Sass.compile(@combinaison) do |result|
      @css_string = result['text']
      update_preview
      ::Element.find('#loader').hide()
      mutate
    end
  end

  def top
    DIV(class:"top row") do
      input_variable_file
      input_custom_file
      reset
      download
    end
  end

  def icon
    SVG(class: "bi bi-upload",width: "1em",height:"1em",viewBox:"0 0 16 16",fill:"currentColor",xmlns:"http://www.w3.org/2000/svg") do
      PATH(fillRule:"evenodd","d":"M.5 8a.5.5 0 0 1 .5.5V12a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V8.5a.5.5 0 0 1 1 0V12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V8.5A.5.5 0 0 1 .5 8zM5 4.854a.5.5 0 0 0 .707 0L8 2.56l2.293 2.293A.5.5 0 1 0 11 4.146L8.354 1.5a.5.5 0 0 0-.708 0L5 4.146a.5.5 0 0 0 0 .708z")
      PATH(fillRule:"evenodd","d":"M8 2a.5.5 0 0 1 .5.5v8a.5.5 0 0 1-1 0v-8A.5.5 0 0 1 8 2z")
    end

  end

  def input_variable_file
    
    DIV(class: "input_file mr-1") do
      BUTTON(class:"btn btn-primary"){
        icon
        " Add Variable File "
      }
      INPUT(type: :file).on(:change) do |evt|
        @file = evt.target.files[0].text()
        @file.then{|result| 
          @variable = result
          update_variables
          compile_css
          mutate
        } 
      end
    end


    # DIV(class:'variable mr-1') do
    #   DIV(class:'input-group') do
    #     DIV(class:'input-group-prepend') do
    #       SPAN(class: 'input-group-text', id:"fileVariable"){"Variable"}
    #     end
    #     DIV(class:'custom-file') do
    #       INPUT(type: :file, class: 'custom-file-input', id:"fileVariable").on(:change) do |evt|
    #         @file = evt.target.files[0].text()
    #         @file.then{|result| 
    #           @variable = result
    #           update_variables
    #           compile_css
    #           mutate
    #         } 
    #       end
    #       LABEL(class:"custom-file-label", htmlFor:'fileVariable'){"Choose file"}
    #     end
    #   end
    # end
  end

  def input_custom_file
    DIV(class: "input_file mr-1") do
      BUTTON(class:"btn btn-success"){
        icon
        " Add Custom File "
      }
      INPUT(type: :file).on(:change) do |evt|
        @file = evt.target.files[0].text()
        @file.then{|result| 
          @custom = result
          update_variables
          compile_css
          mutate
        } 
      end
    end

    # DIV(class: "input_file") do
    #   BUTTON(class:"btn_input_file"){"Custom"}
    #   INPUT(type: :file, name: "myfile").on(:change) do |evt|
    #     @file = evt.target.files[0].text()
    #     @file.then{|result| 
    #       @custom = result
    #       #update_variables
    #       compile_css
    #       mutate
    #     } 
    #   end
    # end

    # DIV(class:'custom mr-1') do
    #   DIV(class:'input-group') do
    #     DIV(class:'input-group-prepend') do
    #       SPAN(class: 'input-group-text', id:"fileCustom"){"Custom"}
    #     end
    #     DIV(class:'custom-file') do
    #       INPUT(type: :file,class: 'custom-file-input', id:"fileCustom").on(:change) do |evt|
    #         @file = evt.target.files[0].text()
    #         @file.then{|result| 
    #           @custom = result
    #           compile_css
    #           mutate
    #         } 
    #       end
    #       LABEL(class:"custom-file-label", htmlFor:'fileCustom'){"Choose file"}
    #     end
    #   end
    # end
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

  def reset
    DIV(class:"mr-1") do
      BUTTON(class:'btn btn-danger'){"Reset"}.on(:click) do
        init
      end
    end
  end
  
  def preview
    IFRAME(src:"/preview.html", style: {border: 'none'}, class: 'col-9')
  end

  def param
    DIV(class:'param col-3') do
      unless @array.nil?
        FORM do
          @array.each do |v|
            DIV(class:'row') do
              DIV(class:'col') do
                LABEL(class:"font-weight-bold"){v['name']}
              end
              DIV(class:'col') do
                SELECT(class:"form-control",value: v['type']){
                  OPTION{'variable'}
                  OPTION{'color'}
                  OPTION{'number'}
                  OPTION{'string'}
                }.on(:change) do |evt|
                  v['type'] = evt.target.value
                  mutate
                end
              end
            end
            DIV(class:'row mb-3') do
              send("input_#{v['type']}", v)
            end
          end
        end
      end
    end
  end

  def change_value(v)
    @timer&.abort
    @timer = after(1) do
      @ast = Sass.parse(@variable)
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
    INPUT(type: :text, class:"form-control col", value:v['value'])
    .on(:change) do |evt|
      mutate v['value'] = evt.target.value
      change_value(v)
    end
    SPAN(class:'col'){
      INPUT(type: v['type'], class:"icon-color field-radio input-color", value:v['value'])
      .on(:change) do |evt|
        mutate v['value'] = evt.target.value
        change_value(v)
      end
    }
  end
  
  def input_string(v)
    input_variable(v)
  end

  def input_number(v)
    INPUT(type: :number, class:"form-control col", value:v['value'])
    .on(:change) do |evt|
      mutate v['value'] = evt.target.value
      change_value(v)
    end
    SPAN(class:"col input_number"){v['unit']}
  end

  def loader
    DIV(id: 'loader', class: 'spinner-border position-absolute') do
      SPAN(class: 'sr-only') do
      end
    end
  end
  
  def test
    puts "test"
  end
end