class VariablePanel < HyperComponent
  param :variable_array , default: []
  fires :variable_changed
  fires :type_changed
  render() {content}

  def content
    unless variable_array.nil?
      DIV(class:'col', style:{'gridColumn':'2','gridRow':'2',overflowY: 'auto'}) do
        FORM do
          variable_array.each do |variable|
            Input(variable: variable)
            .on(:value_changed) do |parameter|
              variable_changed!(parameter)
            end
            .on(:type_changed) do |parameter|
              type_changed!(parameter)
            end
          end
        end
      end
    end
  end

  # def should_component_update?(new_params_hash, new_state_hash)
  #   # puts variable_array.object_id
  #   # puts new_params_hash[:variable_array].object_id
  #   super
  # end

end
