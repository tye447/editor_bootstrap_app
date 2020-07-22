class App < HyperComponent
  include Hyperstack::Router
  include Hyperstack::Router::Helpers

  before_mount do
    @edit_theme = Theme.new
    @show_theme = Theme.new
    @list = Theme.all
    HTTP.get('/themes') do |res|
      @list = res.json['result']
    end
  end

  render(DIV) do
    DIV(class: 'container_fluid') do
      DIV(class: 'd-flex w-100') do
        DIV(class: 'col-3') do
          DIV(class: 'list-group overflow-auto', role: 'tablist', style: {height: '100vh'}) do
            @list.each do |theme|
              DIV(class: 'd-flex') do
                A(id: theme['id'], class: "list-group-item list-group-item-action",
                  role: "tab"){theme['title']}.on(:click) do
                    `$('.list-group-item').removeClass('active')`
                    `$('#'+#{theme['id']}).addClass('active')`
                    mutate @show_theme = theme
                    puts theme['url']
                  end
                BUTTON(class: 'btn btn-primary', 'data-toggle': 'modal', 'data-target': '#modal'){"Edit"}.on(:click) do
                  mutate @edit_theme = theme
                end
              end
            end
          end
          EditTheme(theme: @edit_theme)
          I(class: "fas fa-plus-circle fa-4x text-danger position-absolute",style: {bottom: '1em', right: '1em', zIndex: 1 })
          .on(:click) do
            @theme = Theme.new
            @theme.save
            mutate
          end
        end

        Index(theme: @show_theme)
      end
    end
  end
end