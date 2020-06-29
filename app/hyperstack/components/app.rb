class App < HyperComponent
  include Hyperstack::Router
  include Hyperstack::Router::Helpers
  render do
    Editor()
  end
end
