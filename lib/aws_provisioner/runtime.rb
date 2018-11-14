# frozen_string_literal: true

module AwsProvisioner
  class Runtime
    @templates = []
    @resources = {}

    class << self
      attr_reader :templates

      def resource(resource_type, resource_name)
        resources_for_type = @resources[resource_type]

        return nil if resources_for_type.nil?

        resources_for_type[resource_name]
      end

      def add_resource(resource_type, resource)
        @resources[resource_type] = @resources[resource_type] || {}
        @resources[resource_type][resource.name] = resource
      end
    end
  end
end
