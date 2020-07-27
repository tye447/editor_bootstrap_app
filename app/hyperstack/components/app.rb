class App < HyperComponent
  include Hyperstack::Router
  include Hyperstack::Router::Helpers
  render(DIV) do
    DIV(class: 'container_fluid') do
      DIV(class: 'd-flex w-100') do
        DIV(class: 'col-3') do
          DIV(class: 'list-group overflow-auto', role: 'tablist', style: {height: '100vh'}) do
            Theme.all.each do |theme|
              A(id: theme.id, class: "list-group-item list-group-item-action",
                'data-toggle': "list", role: "tab"){theme.title}
              .on(:click) do
                mutate @selected_theme = theme
              end
            end
          end
          EditItem(theme: @selected_theme) unless @selected_theme.nil?
          AddButton()
        end
        Index(selected_theme: @selected_theme)
      end
    end
  end
end