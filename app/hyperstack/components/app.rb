class App < HyperComponent
  include Hyperstack::Router

  render(DIV) do
    DIV do
      top
    end
    DIV(style:{'display':'flex'}) do
      preview
      param
    end
  end
  after_mount do
    HTTP.get("/flat_bootstrap.scss") do |response|
      @bootstrap =  response.body
    end
  end

  def top
    @custom = ""
    DIV do
      DIV(style:{'display':'flex'}) do
        DIV(class:'variable') do
          LABEL{'variable:'}
          BR{}
          INPUT(type: :file).on(:change) do |evt|
            @file = evt.target.files[0].text()
            @file.then{|result| 
              mutate @variable = result
              @ast = parser(@variable)
              @combinaison = @variable +"\n" + @bootstrap + "\n"+@custom
              Sass.compile(@combinaison) do |result|
                mutate @css = result['text']
              end
              @array = @ast.find_declaration_variables
            } 
          end
        end

        DIV(class:'custom') do
          LABEL{'custom:'}
          BR{}
          INPUT(type: :file).on(:change) do |evt|
            @file = evt.target.files[0].text()
            @file.then{|result| 
              mutate @custom = result
              @ast = parser(@variable)
              @combinaison = @variable +"\n" + @bootstrap + "\n"+@custom
              Sass.compile(@combinaison) do |result|
                mutate @css = result['text']
              end
              @array = @ast.find_declaration_variables
            } 
          end
        end
      end

      DIV(style: {'overflowY':'scroll','height':'200px','borderWidth':'4px'}) do
        H5{'SCSS:'}
        P{"#{@variable}"}
      end

      DIV(style: {'overflowY':'scroll','height':'200px','borderWidth':'4px'}) do
        H5{'CSS:'}
        P{"#{@css}"}
      end
    end
  end

  def preview
    DIV(class:'preview',style: {'overflowY':'scroll','height':'300px'}) do
      Preview(css: @css)
    end
  end

  def param
    DIV(class:'param',style: {'overflowY':'scroll','height':'300px'}) do
      unless @array.nil?
        FORM do
          @array.each do |v|
            DIV(class:'form-group') do
              LABEL{v['name']}
              DIV(style: {'display':'flex'}) do
                INPUT(type: v['type'], class:'form-control', value:v['value'])
                .on(:change) do |evt|
                  mutate v['value'] = evt.target.value
                  @ast = parser(@variable)
                  @ast.replace(v['name'],v['type'],v['value'])
                  mutate @variable = @ast.stringify
                  @combinaison = @variable +"\n" + @bootstrap
                  Sass.compile(@combinaison) do |result|
                    mutate @css = result['text']
                  end
                end
                SPAN(class: 'form-control'){v['unit']}
              end
            end
          end
        end
      end
    end
  end

  def parser(text)
    Sass.parse(text)
  end

  
end