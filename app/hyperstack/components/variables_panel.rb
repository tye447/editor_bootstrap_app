class VariablePanel < HyperComponent
  param :array_variables , default: []
  fires :variable_changed
  render() {content}

  def content
    DIV(class:'col', style:{'gridColumn':'2','gridRow':'2',overflowY: 'auto'}) do
      FORM do
        array_variables.each do |variable|
          Input(variable: variable).on(:value_changed) do |parameter|
            variable_changed!(parameter)
          end
        end
      end
    end
  end


end
