class Input < ::HyperComponent
    param :v 
    
    fires :value_changed
    render(){ content }
    
    def content
      DIV do
          title
          DIV(class:'input-group mb-3') do
          send("input_#{v['type']}", v)
          end
      end
    end

    def title
      DIV(class:'mb-1 d-flex') do
          LABEL(class:"font-weight-bold flex-grow-1 mb-0 pt-2"){v['name']}
          SELECT(class:"form-control w-auto",value: v['type']){
          OPTION{'variable'}
          OPTION{'color'}
          OPTION{'number'}
          OPTION{'string'}
          }.on(:change) do |evt|
          v['type'] = evt.target.value
          puts "title"
          mutate
          end
      end
    end

    def input_variable(v)
      INPUT(type: :text, class:"form-control", value:v['value'])
      .on(:change) do |evt|
          mutate v['value'] = evt.target.value
          value_changed!(v)
      end
    end

    def input_color(v)
      DIV(class:"input-group-prepend") do
          INPUT(type: :color, class:"form-control", style:{"width":"50px","backgroundColor":"#e9ecef"}, value: v['value'])
          .on(:change) do |evt|
          mutate v['value'] = evt.target.value
          value_changed!(v)
          end
      end
      INPUT(type: :text, class:"form-control", value:v['value'])
      .on(:change) do |evt|
          mutate v['value'] = evt.target.value
          value_changed!(v)
      end
    end
    
    def input_string(v)
      input_variable(v)
    end

    def input_number(v)
      INPUT(type: :number, class:"form-control", value:v['value'])
      .on(:change) do |evt|
          mutate v['value'] = evt.target.value
          value_changed!(v)
      end
      DIV(class:"input-group-append") do
          SPAN(class:"input-group-text"){v['unit']}
      end
    end

end


