class VariablePanel < HyperComponent
  param :variable_array , default: []
  fires :variable_changed
  render() {content}

  def content
    DIV(class:'col', style:{'gridColumn':'2','gridRow':'2',overflowY: 'auto'}) do
      FORM do
        variable_array.each do |variable|
          Input(variable: variable).on(:value_changed) do |parameter, change_choice|
            variable_changed!(parameter, change_choice)
          end
        end
      end
    end
  end


end
