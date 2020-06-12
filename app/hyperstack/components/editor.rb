class Editor < HyperComponent
  include Hyperstack::Router::Helpers
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
        mutate @cssString = result['text']
      end
    end
    HTTP.get("/default_variable.scss") do |response|
      @variable =  response.body
      @ast = Sass.parse(@variable)
      @array = @ast.find_declaration_variables
    end
  end

  after_update do
    update_preview
    puts "test"
  end

  def update_preview
    `
    var frame = document.querySelector('iframe');
    frame.contentWindow.postMessage('test','*');
    `
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
              @combinaison = @variable.to_s+"\n"+@bootstrap.to_s+"\n"+@custom.to_s+"\n"
              Sass.compile(@combinaison) do |result|
                  mutate @cssString = result['text']
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
              @combinaison = @variable.to_s+"\n"+@bootstrap.to_s+"\n"+@custom.to_s+"\n"
              Sass.compile(@combinaison) do |result|
                mutate @cssString = result['text']
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
              mutate @cssString = result['text']
            end
            alert "Style reseted!"
          end
        end
      end
    end
  end
  
  def preview
    IFRAME(id:'myIframe', src:"/preview")
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
                  @combinaison = @variable.to_s+"\n"+@bootstrap.to_s+"\n"+@custom.to_s+"\n"
                  Sass.compile(@combinaison) do |result|
                    mutate @cssString = result['text']
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
