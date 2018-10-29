module AwsProvisioner
  class Properties
    attr_reader :properties

    def initialize(hash={})
      @properties = hash.reduce({}) do |acc, entry|
        key, value = entry

        if value.instance_of?(Hash)
          acc[key] = Properties.new(value)
        else
          acc[key] = value
        end

        acc
      end
    end

    def empty?
      @properties.empty?
    end

    def rename
      renamed_properties = @properties.reduce({}) do |acc, entry|
        key, value = entry
        template_key = template_name(key)

        if value.instance_of? self.class
          acc[template_key] = value.rename
        else
          acc[template_key] = value
        end

        acc
      end

      Properties.new(renamed_properties)
    end

    def to_t
      self.rename.reformat_keys.to_h
    end

    def reformat_keys
      # TODO: rename and make private
      @properties.reduce({}) do |acc, entry|
        key, value = entry

        if value.instance_of? self.class
          acc[key.to_s] = value.reformat_keys
        else
          acc[key.to_s] = value
        end

        acc
      end
    end

    def to_h
      @properties.reduce({}) do |acc, property|
        key, value = property

        if value.instance_of? self.class
          acc[key] = value.to_h
        else
          acc[key] = value
        end

        acc
      end
    end

    private

    def method_missing(m, *args, &block)
      if @properties.include? m
          return @properties[m]
      elsif assignment?(m, args, block)
          return assign(m, args, block)
      else
        property = Properties.new
        @properties[m] = property
        return property
      end
    end

    def assign(m, args, block)
      # require 'byebug'; byebug
      if standard_assignment?(m, args, block)
        attribute = m.to_s[0...-1].to_sym
        @properties[attribute] = args.first
      elsif dsl_simple_assignment?(m, args, block)
        attribute = m
        @properties[attribute] = args.first
      elsif dsl_nested_assignment?(m, args, block)
        attribute = m
        self.send("#{attribute}").instance_eval(&block)
      end
    end

    def assignment?(m, args, block)
       standard_assignment?(m, args, block) \
        or dsl_simple_assignment?(m, args, block) \
        or dsl_nested_assignment?(m, args, block)
    end

    def standard_assignment?(m, _args, _block)
      # example: properties.something = 20
      m.to_s.end_with?('=')
    end

    def dsl_simple_assignment?(_m, args, _block)
      # example: properties.instance_eval { something 20 }
      !args.first.nil?
    end

    def dsl_nested_assignment?(_m, _args, block)
      # example: properties.instance_eval { something { else 20 } }
      !block.nil?
    end

    def template_name(key)
       key.camelize.to_sym
    end
  end
end
