class Input < ::HyperComponent
  param :variable
  fires :type_changed
  fires :value_changed
  render(){ content }

  def content
    DIV(class:'mb-3') do
      title
      DIV(class:'input-group') do
        send("input_#{variable['type']}", variable)
      end
      DIV(class:"position-absolute",style: {"zIndex": "2"}) do
        sketch_color_picker(variable)
      end if @show
    end
  end

  def title
    DIV(class:'mb-1 d-flex') do
      LABEL(class:"font-weight-bold flex-grow-1 mb-0 pt-2"){variable['name']}
      SELECT(class:"form-control w-auto",value: variable['type']) do
        OPTION{'variable'}
        OPTION{'color'}
        OPTION{'number'}
        OPTION{'string'}
      end.on(:change) do |evt|
        mutate variable['type'] = evt.target.value
        type_changed!(variable)
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
      BUTTON(type: :button, class: "input-group-text"){
        I(class: "fas fa-square",style:{color: variable['value']})
      }.on(:click){mutate (@show = !@show)}
    end

    INPUT(id: variable['id'], type: :text, class: "form-control", value: variable['value'])
    .on(:change) do |evt|
      mutate variable['value'] = evt.target.value
      value_changed!(variable)
    end
  end


  def sketch_color_picker(variable)
    DIV(class: "fixed-top fixed-bottom",style: {"zIndex": "0"})
    .on(:click) do
      mutate @show = false
    end
    SketchPicker(color: variable["value"])
    .on(:change) do |color, event|
      mutate variable['value'] = color.hex
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
      SELECT(class:"form-control border-0",value: variable['unit']) do
        OPTION{'rem'}
        OPTION{'em'}
        OPTION{'px'}
        OPTION{''}
        OPTION{'%'}
      end.on(:change) do |evt|
        mutate variable['unit'] = evt.target.value
        value_changed!(variable)
      end
    end
  end

end