class VariablePanel < HyperComponent
  param :array_variable , default: []
  fires :variable_changed
  render() {content}

  def content
    DIV(class:'col', style:{'gridColumn':'2','gridRow':'2',overflowY: 'auto'}) do
      unless array_variable.nil?
        FORM do
          array_variable.each do |variable|
            Input(variable:variable).on(:value_changed) do |parameter|
              variable_changed!(parameter)
            end
          end
        end
      end
    end
  end


end
