class HyperComponent
  include Hyperstack::Component
  include Hyperstack::State::Observable
  param_accessor_style :accessors

  # fix bug when a "fires" is defined on() if applyied to a component

  # Proc are passed as props and it causes useless updates

  def props_changed?(next_props)
    return true if `Object.keys(#{@__hyperstack_component_native}.props).length` != next_props.length
    props = Hash.new(`#{@__hyperstack_component_native}.props`)
    next_props.each do |k, v|
      next if v.is_a?(Proc) && props[k].is_a?(Proc)
      return true if props[k] != v
    end
    return false
  end

end
