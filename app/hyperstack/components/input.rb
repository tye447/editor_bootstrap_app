class Input < ::HyperComponent
  param :variable
  param :change_choice, default: 'value'
  fires :value_changed
  render(){ content }

  def content
    DIV do
      title
      DIV(class:'input-group mb-3') do
        send("input_#{variable['type']}", variable, change_choice)
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
        mutate variable['type'] = evt.target.value
      end
    end
  end

  def input_variable(variable,change_choice)
    INPUT(type: :text, class:"form-control", value:variable['value'])
    .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable,change_choice)
    end
  end

  def input_color(variable,change_choice)
    DIV(class:"input-group-prepend") do
      INPUT(type: :color, class:"form-control input-group-text", style:{"width":"50px","backgroundColor":"#e9ecef"}, value: variable['value'])
      .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable,change_choice)
      end
    end
    INPUT(id: variable['id'], type: :text, class: "form-control", value: variable['value'])
    .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable,change_choice)
    end
    .on(:blur) do |evt|
      new_value = ::Element.find('#'+variable['id'].to_s).val()
      mutate variable['value'] = hex_conv(new_value.to_s)
    end
  end

  def input_string(variable,change_choice)
    input_variable(variable,change_choice)
  end

  def input_number(variable,change_choice)
    INPUT(type: :number, class:"form-control", value:variable['value'])
    .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable,change_choice)
    end
    DIV(class:"input-group-append") do
      SELECT(class:"form-control border-0",value: variable['unit']){
        OPTION{'rem'}
        OPTION{'em'}
        OPTION{'px'}
        OPTION{''}
        OPTION{'%'}
      }.on(:change) do |evt|
        mutate variable['unit'] = evt.target.value
        change_choice = 'unit'
        value_changed!(variable,change_choice)
      end
      # SPAN(class:"input-group-text"){variable['unit']}
    end
  end

  def hex_conv(hex)
    if hex.length == 4 && hex[0] == '#'
      return hex[0]+hex[1]+hex[1]+hex[2]+hex[2]+hex[3]+hex[3]
    else
      return hex
    end
  end

end