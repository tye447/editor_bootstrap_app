class Preview < HyperComponent
  render do
    IFRAME(class:"w-100 h-100 border-0", style:{'gridArea': ' 2 / 1 / auto / auto'}, src:"/preview.html")
  end
end
