class App < HyperComponent
  include Hyperstack::Router
  include Hyperstack::Router::Helpers
  render(DIV) do
    DIV(class: 'container_fluid') do
      DIV(class: 'd-flex w-100') do
        Menu().on(:theme_selected) do |theme|
          mutate @selected_theme = theme
        end
        EditItem(theme: @selected_theme) unless @selected_theme.nil?
        Index(selected_theme: @selected_theme).on(:deleted) do |selected_theme|
          selected_theme.destroy
          mutate @selected_theme = nil
        end
      end
    end
  end
end