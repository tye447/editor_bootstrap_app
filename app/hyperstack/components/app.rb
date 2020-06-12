class App < HyperComponent
  include Hyperstack::Router
  include Hyperstack::Router::Helpers
  render(DIV) do
    Route('/preview',exact: true) do
      Preview()
    end
    Route('/',exact: true) do
      Editor()
    end
  end
end
