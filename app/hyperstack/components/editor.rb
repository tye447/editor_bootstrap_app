class Editor < HyperComponent
  include Hyperstack::Router::Helpers
  render() do
    DIV(class: 'container-fluid') do
      DIV do
        top
      end
      DIV(class: 'row') do
        preview
        param
      end
      loader
    end
  end

  after_mount do
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

  def top
    DIV do
      DIV(style:{'display':'flex'}) do
        DIV(class:'variable') do
          LABEL{'variable:'}
          BR{}
          INPUT(type: :file).on(:change) do |evt|
            @file = evt.target.files[0].text()
            @file.then{|result| 
              @variable = result
              update_variables
              compile_css
              puts "file variable charged!"
              mutate
            } 
          end
        end

        DIV(class:'custom') do
          LABEL{'custom:'}
          BR{}
          INPUT(type: :file).on(:change) do |evt|
            @file = evt.target.files[0].text()
            @file.then{|result| 
              @custom = result
              compile_css
              puts "file custom charged!"
              mutate
            } 
          end
        end
        DIV do
          BUTTON(class:'btn btn-primary'){"Reset"}.on(:click) do
            @variable=""
            @custom=""
            update_variables
            compile_css
            update_preview
            puts "Style reseted!"
            mutate
          end
        end
      end
    end
  end
  
  def preview
    IFRAME(src:"/preview", style: {border: 'none'}, class: 'col-9')
  end

  def loader
    DIV(id: 'loader', class: 'spinner-border position-absolute', style: {display: 'none', top: '50%', left: '50%', width: '6em', height: '6em'}) do
      SPAN(class: 'sr-only') do
      end
    end
  end

  def param
    DIV(class:'param col-3',style: {'overflowY':'scroll','height':'700px'}) do
      unless @array.nil?
        FORM do
          @array.each do |v|
            DIV(class:'form-group') do
              LABEL{v['name']}
              DIV(style: {'display':'flex'}) do
                INPUT(type: v['type'], class:'form-control', value:v['value'])
                .on(:change) do |evt|

                  @timer&.abort
                  @timer = after(0.3) do
                    @ast = Sass.parse(@variable)
                    @ast.replace(v['name'],v['type'],v['value'])
                    @variable = @ast.stringify
                    compile_css
                    @timer = nil
                  end

                  mutate v['value'] = evt.target.value
                  puts "replace ok"
                end
                SPAN(class: 'form-control'){v['unit']}
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
