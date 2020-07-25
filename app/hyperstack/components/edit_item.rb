class EditItem < HyperComponent
  param :theme
  render do
    DIV(class: 'modal fade', tabIndex: '-1', role: 'dialog',
      'aria-labelledby': 'modalLabel','aria-hidden': 'true',style: {display: 'none'}) do
      DIV(class: 'modal-dialog', role: 'document') do
        DIV(class: 'modal-content') do
          DIV(class: 'modal-header') do
            H5(class: "modal-title", id:"modalLabel"){"Edit Theme Title"}
            BUTTON(type: :'button', class: 'close', 'data-dismiss': 'modal', 'aria-label': 'Close'){
              SPAN('aria-hidden': 'true'){"×"}
            }
          end
          DIV(class: 'modal-body') do
            FORM do
              DIV(class: 'form-group') do
                LABEL{"Title"}
                INPUT(type: :text, name: 'title', class: 'form-control', defaultValue: theme.title)
              end

              DIV(class: 'container') do
                DIV(class: 'row') do
                  DIV(class: 'col') do
                    BUTTON(type: :button, class: 'btn btn-primary'){"Save"}.on(:click) do
                      theme.update(title: `$('input[name=title]').val()`)
                    end
                  end
                  DIV(class: 'col') do
                    INPUT(type: :reset, class: 'btn btn-danger', value: 'Reset')
                  end
                  DIV(class: 'col') do
                    BUTTON(type: :button, class: 'btn btn-secondary', 'data-dismiss': "modal"){"Close"}
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end