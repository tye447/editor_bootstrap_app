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
      Sass.compile(@bootstrap) do |result|
        mutate @css = result['text']
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
              mutate @variable = result
              @ast = Sass.parse(@variable)
              @array = @ast.find_declaration_variables
              @string_var = @variable.to_s
              @combinaison = @string_var +"\n" + @bootstrap + "\n"+@custom+"\n"
              Sass.compile(@combinaison) do |result|
                  mutate @css = result['text']
              end
              alert "file variable charged!"
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
              @ast = Sass.parse(@variable)
              @array = @ast.find_declaration_variables
              @string_var = @variable.to_s
              @combinaison = @string_var +"\n" + @bootstrap + "\n"+@custom
              Sass.compile(@combinaison) do |result|
                mutate @css = result['text']
              end
              alert "file custom charged!"
            } 
          end
        end
        DIV do
          BUTTON(class:'btn btn-primary'){"Reset"}.on(:click) do
            @variable=""
            @custom=""
            Sass.compile(@bootstrap) do |result|
              mutate @css = result['text']
            end
            alert "Style reseted!"
          end
        end
      end
    end
  end
  
  def preview
    DIV(class:'preview',style: {'overflowY':'scroll','height':'700px'}) do
      Preview(css: @css)
    end
  end

  def param
    DIV(class:'param',style: {'overflowY':'scroll','height':'700px'}) do
      unless @array.nil?
        FORM do
          @array.each do |v|
            DIV(class:'form-group') do
              LABEL{v['name']}
              DIV(style: {'display':'flex'}) do
                INPUT(type: v['type'], class:'form-control', value:v['value'])
                .on(:change) do |evt|
                  mutate v['value'] = evt.target.value
                  @ast = Sass.parse(@variable)
                  @ast.replace(v['name'],v['type'],v['value'])
                  mutate @variable = @ast.stringify
                  @string_var = @variable.to_s
                  @combinaison = @string_var +"\n" + @bootstrap + "\n"+@custom
                  Sass.compile(@combinaison) do |result|
                    mutate @css = result['text']
                  end
                  alert "replace ok"
                end
                SPAN(class: 'form-control'){v['unit']}
              end
            end
          end
        end
      end
    end
  end

end