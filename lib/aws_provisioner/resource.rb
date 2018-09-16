require_relative 'extensions'

module AwsProvisioner
  class Resource
    attr_reader :name, :properties, :type

    class_attribute :property_specs,
                    default: [],
                    instance_predicate: false,
                    instance_writer: false

    def self.property(name, spec)
      self.property_specs += [Property.new(name, spec)]
    end

    def initialize(name, properties={})
      @name = name or raise ArgumentError
      @properties = properties
    end

    def type
      self.class.to_s.sub("AwsProvisioner::", '')
    end

    def valid?
      property_specs.each do |property_spec|
        return false unless property_spec.valid?(properties)
      end

      names = property_specs.map(&:name)
      properties.each do |key, value|
        return false unless names.include?(key)
      end

      true
    end

    def to_h!
      unless valid?
        raise Property::InvalidProperty
      end

      h = property_specs.reduce({}) do |acc, property_spec|
        acc[property_spec.template_name] = properties[property_spec.name]

        acc
      end

      h["Type"] = type

      h
    end

    def method_missing(m, *args, &block)
      if assignment?(m, args)
        m = m[0...-1].to_sym if m.to_s.end_with?("=")
        return self.properties[m] = args[0]
      elsif self.properties.include? m
        return self.properties[m]
      else
        super
      end
    end

    private

    def assignment?(m, args)
      m.to_s.end_with?("=") || !args.empty?
    end
  end
end
