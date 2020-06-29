class Utils
  def self.deep_dup(object)
    @result = `lodash.cloneDeep(#{object});`
    return @result
  end

end