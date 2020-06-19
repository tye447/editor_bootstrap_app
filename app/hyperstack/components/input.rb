class Input < ::HyperComponent
  param :variable 
  
  fires :value_changed
  render(){ content }
  
  def content
    DIV do
      title
      DIV(class:'input-group mb-3') do
        send("input_#{variable['type']}", variable)
      end
    end
  end

  def title
    DIV(class:'mb-1 d-flex') do
      LABEL(class:"font-weight-bold flex-grow-1 mb-0 pt-2"){variable['name']}
      SELECT(class:"form-control w-auto",value: variable['type']){
        OPTION{'variable'}
        OPTION{'color'}
        OPTION{'number'}
        OPTION{'string'}
      }.on(:change) do |evt|
        variable['type'] = evt.target.value
        puts "title"
        mutate
      end
    end
  end

  def input_variable(variable)
    INPUT(type: :text, class:"form-control", value:variable['value'])
    .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable)
    end
  end

  def input_color(variable)
    DIV(class:"input-group-prepend") do
      INPUT(type: :color, class:"form-control", style:{"width":"50px","backgroundColor":"#e9ecef"}, value: variable['value'])
      .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable)
      end
    end
    INPUT(type: :text, class:"form-control", value:variable['value'])
    .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable)
    end
  end
  
  def input_string(variable)
    input_variable(variable)
  end

  def input_number(variable)
    INPUT(type: :number, class:"form-control", value:variable['value'])
    .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable)
    end
    DIV(class:"input-group-append") do
      SPAN(class:"input-group-text"){variable['unit']}
    end
  end

end


