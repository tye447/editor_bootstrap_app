class AddButton < HyperComponent
  render do
    I(class: "fas fa-plus-circle fa-4x text-danger position-absolute",style: {bottom: '1em', right: '1em', zIndex: 1 })
    .on(:click) do
      Theme.create
    end
  end
end