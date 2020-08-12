class Index < HyperComponent
  include Hyperstack::Router::Helpers
  param :selected_theme
  fires :deleted
  render do
    DIV(class: 'col-9') do
      if Theme.count == 0
        H4(class: "text-secondary text-center"){"Click the add button to add a new theme"}
      elsif selected_theme.nil? || selected_theme.variable_file.nil? || selected_theme.custom_file.nil?
        H4(class: "text-secondary text-center"){"Click a theme of the list on the left"}
      else
        DIV(class: 'row') do
          DIV(style: {height: 'calc(100vh - 60px)'}) do
            BootstrapEditor::Editor(reset: @reset, variable_file: selected_theme.variable_file, custom_file: selected_theme.custom_file)
            .on(:reset_done) do |ast, custom_file|
              mutate @reset = false
              @ast = ast
              @custom_file = custom_file
            end
            .on(:changed) do |ast, custom_file|
              @ast = ast
              @custom_file = custom_file
            end
          end
        end
        DIV(class: 'row') do
          Footer(theme: selected_theme).on(:reset){ mutate @reset = true }
          .on(:saved) do
            unless @ast.nil?
              selected_theme.update({variable_file: @ast.find_changed_value, custom_file: @custom_file})
            end
          end.on(:deleted) do
            # selected_theme.destroy
            deleted!(selected_theme)
          end
        end
      end
    end
  end
end