class Footer < HyperComponent
  param :theme
  fires :reset
  fires :saved
  fires :deleted
  render do
    DIV(class: 'container') do
      DIV(class: 'row') do
        DIV(class: 'col') do
          BUTTON(class: 'btn btn-primary', 'data-toggle': 'modal', 'data-target': '.modal'){"Edit"}
        end
        DIV(class: 'col') do
          BUTTON(class:'btn btn-danger'){"Reset"}.on(:click){ reset! }
        end
        DIV(class: 'col') do
          BUTTON(class: 'btn btn-success'){"Save"}.on(:click){ saved! }
        end
        DIV(class: 'col') do
          BUTTON(class: 'btn btn-danger'){"Delete"}.on(:click){ deleted! }
        end
      end
    end
  end
end