class App < HyperComponent
  include Hyperstack::Router
  include Hyperstack::Router::Helpers
  render do
    DIV do
      BootstrapEditor::App()
    end
  end
end
