class Index < HyperComponent
  include Hyperstack::Router::Helpers
  param :selected_theme
  render do
    DIV(class: 'col-9') do
      if Theme.count == 0
        H4(class: "text-secondary text-center"){"Click the add button to add a new theme"}
      elsif selected_theme.nil?
        H4(class: "text-secondary text-center"){"Click a theme of the list on the left"}
      else
        DIV(class: 'row') do
          DIV(style: {height: 'calc(100vh - 60px)'}) do
            BootstrapEditor::Editor(reset: @reset, variable_file: selected_theme.variable_file, custom_file: selected_theme.custom_file)
            .on(:reset_done) { mutate @reset = false }
            .on(:changed) do |ast, custom_file|
              @ast = ast
              puts "custome_file"
              puts custom_file
              @custom_file = custom_file
            end
          end
        end
        DIV(class: 'row') do
          Footer(theme: selected_theme).on(:reset){ mutate @reset = true }
          .on(:saved) do
            if @custom_file.nil?
              @custom_file = ""
            end
            puts @custom_file
            selected_theme.update({variable_file: @ast.find_changed_value, custom_file: @custom_file})
          end.on(:deleted) { theme.destroy }
        end
      end
    end
  end
end