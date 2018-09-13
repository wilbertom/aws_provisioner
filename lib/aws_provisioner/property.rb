require_relative 'extensions'

module AwsProvisioner
  class Property

    class InvalidProperty < Exception; end

    attr_reader :name, :type

    def initialize(name, spec)
      @name = name
      @type = nil
      @required = nil

      parse(spec)

      raise ArgumentError unless @type
    end

    def template_name
      self.name.camelize
    end

    def required?
      @required
    end

    def valid?(properties)
      value = properties[name]

      if !required? and value.nil?
        return true
      end

      return value.is_a? type.camelize.constantize
    end

    private

    def parse(spec)
      @type = if spec.include?(:string)
        :string
      elsif spec.include?(:boolean)
        :boolean
      end

      @required = spec.include?(:required)
    end
  end
end
