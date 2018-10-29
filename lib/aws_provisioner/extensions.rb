require 'active_support/core_ext/string/inflections'

class Symbol
  def camelize
    self.to_s.camelize
  end
end
