class Menu < HyperComponent
  fires :theme_selected
  render do
    DIV(class: 'col-3') do
      DIV(id: 'menu', class: 'list-group overflow-auto', role: 'tablist', style: {height: '100vh'}) do
        Theme.all.each do |theme|
          A(id: theme.id, class: "list-group-item list-group-item-action",
            'data-toggle': "list", role: "tab"){theme.title}
          .on(:click) do
            theme_selected!(theme)
          end
          DIV(class:'d-none') do
            SPAN{theme.variable_file}
            SPAN{theme.custom_file}
          end
        end
      end
      AddButton()
    end
  end
end