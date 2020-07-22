class EditTheme < HyperComponent
  param :theme

  render do
    DIV(class: 'modal fade', id: 'modal', tabIndex: '-1', role: 'dialog',
      'aria-labelledby': 'modalLabel','aria-hidden': 'true',style: {display: 'none'}) do
      DIV(class: 'modal-dialog', role: 'document') do
        DIV(class: 'modal-content') do
          DIV(class: 'modal-header') do
            H5(class: "modal-title", id:"modalLabel"){"Edit"}
            BUTTON(type: :'button', class: 'close', 'data-dismiss': 'modal', 'aria-label': 'Close'){
              SPAN('aria-hidden': 'true'){"×"}
            }
          end
          DIV(class: 'modal-body') do
            DIV(class: 'form-group') do
              LABEL{"Id"}
              SPAN{theme['id'].to_s}
            end
            DIV(class: 'form-group') do
              LABEL{"Title"}
              INPUT(type: :text, id: 'title', class: 'form-control', value: theme['title']).on(:change) do |evt|
                mutate theme['title'] = evt.target.value
              end
            end
            DIV(class: 'form-group') do
              LABEL{"URL"}
              INPUT(type: :text, id: 'url', class: 'form-control', value: theme['url']).on(:change) do |evt|
                mutate theme['url'] = evt.target.value
              end
            end
          end
          DIV(class: 'modal-footer') do
            BUTTON(type: :button, class: 'btn btn-secondary', 'data-dismiss': "modal"){"Save"}.on(:click) do
              puts theme['url']
              puts theme['title']
            end
            BUTTON(type: :button, class: 'btn btn-danger', 'data-dismiss': "modal"){"Close"}
          end
        end
      end
    end
  end
end