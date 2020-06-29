class ErrorMessage < HyperComponent
  render(DIV, class: 'error_message') do
    DIV(class: 'toast position-absolute', role: 'alert', 'data-delay':'5000', style:{'top': '0', 'right': '0','display': 'none'}) do
      DIV(class: 'toast-header') do
        STRONG(class: 'mr-auto'){"SASS Error: "}
        BUTTON(type: 'button', class: 'ml-2 mb-1 close', 'data-dismiss': 'toast') do
          SPAN('aria-hidden': 'true'){"×"}
        end
      end
      DIV(class: 'toast-body') do
        SPAN(id: 'error', class: 'mr-auto')
      end
    end
  end

  after_mount do
    `$('.toast').on('hidden.bs.toast', function () {
      $(".toast").hide();
    })`
  end

end
