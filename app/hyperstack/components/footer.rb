class Footer < HyperComponent
  param :theme
  fires :reset
  fires :saved
  fires :deleted
  before_mount
  render do
    DIV(class: 'container') do
      DIV(class: 'row') do
        DIV(class: 'col') do
          BUTTON(class: 'btn btn-primary', 'data-toggle': 'modal', 'data-target': '.modal'){
            I(class: 'fas fa-edit')
            SPAN{" Edit"}
          }
        end
        DIV(class: 'col') do
          BUTTON(class:'btn btn-danger'){
            I(class: 'fas fa-power-off')
            SPAN{" Reset"}
          }.on(:click){ reset! }
        end
        DIV(class: 'col') do
          BUTTON(class: 'btn btn-success'){
            I(class: 'fas fa-save')
            SPAN{" Save"}
          }.on(:click){ saved! }
        end
        DIV(class: 'col') do
          BUTTON(class: 'btn btn-danger'){
            I(class: 'fas fa-trash-alt')
            SPAN{" Delete"}
          }.on(:click){ deleted! }
        end
      end
    end
  end
end