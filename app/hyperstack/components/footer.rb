class Footer < HyperComponent
  fires :reset_state
  fires :saved
  render(DIV, class: 'footer d-flex') do
    BUTTON(type: :submit, class: 'btn btn-primary float-right'){"Save"}.on(:click) do
      saved!
    end
    reset
  end

  def reset
    DIV(class:"mr-1") do
      BUTTON(class:'btn btn-danger'){"Reset"}.on(:click) do
        reset_state!
      end
    end
  end
end