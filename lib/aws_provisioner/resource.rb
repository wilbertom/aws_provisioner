# frozen_string_literal: true

require_relative 'extensions'
require_relative 'properties'

module AwsProvisioner
  class Resource
    attr_reader :name, :properties, :type, :export

    def initialize(type, name, hash: {}, export: false)
      (@name = name) || raise(ArgumentError)
      @properties = Properties.new(hash)
      @type = type
      @export = export
    end

    def to_h
      h = {}
      h['Properties'] = properties.to_t
      h['Type'] = type

      h
    end

    def ref
      { 'Ref' => name.to_s }
    end
  end
end
