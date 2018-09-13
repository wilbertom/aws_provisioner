module AwsProvisioner
  class Template

    attr_reader :format_version, :description, :resources

    def initialize(description=nil)
      @format_version = "2010-09-09"
      @description = description
      @resources = []

      if block_given?
        yield self
      end
    end

    def add(resource)
      resources << resource
    end

    def to_h
      {
        "AWSTemplateFormatVersion" => format_version,
        "Description" => description,
        "Resources" => resources_to_h,
      }
    end

    private

    def resources_to_h
      resources.reduce({}) do |acc, resource|
        acc[resource.name] = resource.to_h!

        acc
      end
    end
  end
end
