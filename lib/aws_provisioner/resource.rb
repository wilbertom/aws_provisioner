require_relative 'extensions'
require_relative 'properties'

module AwsProvisioner
  class Resource
    attr_reader :name, :properties, :type

    def initialize(type, name, hash={})
      @name = name or raise ArgumentError
      @properties = Properties.new(hash)
      @type = type
    end

    def to_h
      h = {}
      h["Properties"]  = properties.to_t
      h["Type"] = type

      h
    end
  end
end
