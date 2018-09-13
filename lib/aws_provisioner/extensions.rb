require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/class/attribute'

class Symbol
  def camelize
    self.to_s.camelize
  end
end

module Boolean
end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end
