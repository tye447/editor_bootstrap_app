class Editor < HyperComponent
  include Hyperstack::Router::Helpers
  render do
    DIV(class: 'container-fluid') do
      DIV(style:{'height':"calc(10vh)"}) do
        top
      end
      DIV(class: 'row',style:{'height':"calc(90vh)"}) do
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
    HTTP.get("/flat_bootstrap.scss") do |response|
      @bootstrap =  response.body

      HTTP.get("/default_variable.scss") do |response2|
        @variable =  response2.body
        update_variables
        compile_css
        update_preview
        mutate
      end
    end
  end

  def input_variable
    DIV(class:'variable') do
      DIV(class:'input-group mb-3') do
        DIV(class:'input-group-prepend') do
          SPAN(class: 'input-group-text', id:"fileVariable"){"Variable"}
        end
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
          LABEL(class:"custom-file-label", htmlFor:'fileVariable'){"Choose file"}
        end
      end
    end
  end

  def input_custom
    DIV(class:'custom') do
      DIV(class:'input-group mb-3') do
        DIV(class:'input-group-prepend') do
          SPAN(class: 'input-group-text', id:"fileCustom"){"Custom"}
        end
        DIV(class:'custom-file') do
          INPUT(type: :file,class: 'custom-file-input', id:"fileCustom").on(:change) do |evt|
            @file = evt.target.files[0].text()
            @file.then{|result| 
              @custom = result
              compile_css
              mutate
            } 
          end
          LABEL(class:"custom-file-label", htmlFor:'fileCustom'){"Choose file"}
        end
      end
    end
  end

  def download
    DIV do
      BUTTON(class:"btn btn-outline-primary"){"Download"}.on(:click) do
        `download(#{@css_string}, "bootstrap.css", "text/plain");`
      end
    end
  end

  def reset
    DIV do
      BUTTON(class:'btn btn-outline-primary'){"Reset"}.on(:click) do
        init
      end
    end
  end

  def top
    DIV do
      DIV(style:{display:'flex'}) do
        input_variable
        input_custom
        reset
        download
      end
    end
  end
  
  def preview
    IFRAME(src:"/preview.html", style: {border: 'none'}, class: 'col-9')
  end

  def loader
    DIV(id: 'loader', class: 'spinner-border position-absolute', style: {display: 'none', top: '50%', left: '50%', width: '6em', height: '6em'}) do
      SPAN(class: 'sr-only') do
      end
    end
  end

  def param
    DIV(class:'param col-3',style: {'overflowY':'scroll',height:'100%'}) do
      unless @array.nil?
        FORM do
          @array.each do |v|
            DIV(class:'form-group') do
              LABEL{v['name']}
              DIV(style: {'display':'flex','border':'none'},id:v['id']) do
                INPUT(type: :text, class:'form-control', value:v['value'])
                .on(:change) do |evt|
                  mutate v['value'] = evt.target.value
                  @timer&.abort
                  @timer = after(1) do
                    @ast = Sass.parse(@variable)
                    @ast.replace(v['name'],v['type'],v['value'])
                    @variable = @ast.stringify
                    compile_css
                    @timer = nil
                  end
                end
                @show = change_type(v['type'])
                INPUT(type: v['type'], class:'form-control', value:v['value'],style:{display:@show,border:'none'})
                .on(:change) do |evt|
                  mutate v['value'] = evt.target.value
                  @timer&.abort
                  @timer = after(1) do
                    @ast = Sass.parse(@variable)
                    @ast.replace(v['name'],v['type'],v['value'])
                    @variable = @ast.stringify
                    compile_css
                    @timer = nil
                  end
                end
                SPAN(class: 'form-control',style: {'border':'none'}){v['unit']}
                SELECT(class:'form-control',value: v['type']){
                  OPTION{'variable'}
                  OPTION{'color'}
                  OPTION{'number'}
                  OPTION{'string'}
                }.on(:change) do |evt|
                  mutate v['type'] = evt.target.value
                  # v['type']= v['type']
                  # change_type(v['id'],v['type'])
                  #@ast = Sass.parse(@variable)
                  #@ast.replace(v['name'],v['type'],v['value'])
                  #v['type'] = new_type
                  #@variable = @ast.stringify
                  #compile_css
                end
              end
            end
          end
        end
      end
    end
  end

  def update_variables
    @ast = Sass.parse(@variable)
    @array = @ast.find_declaration_variables
  end

  def change_type(type)
    if type== 'color'
      return 'block'
    else
      return 'none'
    end
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
    @combinaison = @variable.to_s+"\n"+@bootstrap.to_s+"\n"+@custom.to_s+"\n"
    Sass.compile(@combinaison) do |result|
      @css_string = result['text']
      update_preview
      ::Element.find('#loader').hide()
      mutate
    end
  end

end