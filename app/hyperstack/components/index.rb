class Index < HyperComponent
  include Hyperstack::Router::Helpers
  param :theme
  render do
    @url = theme['url']
    DIV(class: 'col-9') do
      DIV(class: 'row') do
        DIV(style: {height: 'calc(100vh - 60px)'}) do
          BootstrapEditor::Editor(reset_state: @reset_state,save_state: @save_state)
          .on(:reset_done) do
            mutate @reset_state = false
          end
          .on(:save_done) do |variable_array|
            puts variable_array
            puts @url
            # HTTP.post(@url,payload:{data: variable_array}) do |res|
            #   puts res
            # end
            mutate @save_state = false
          end
        end
      end
      DIV(class: 'row') do
        Footer().on(:reset_state) do
          mutate @reset_state = true
        end.on(:saved) do
          mutate @save_state = true
        end
      end
    end
  end
end