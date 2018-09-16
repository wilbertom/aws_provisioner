require 'json'
require 'yaml'

module AwsProvisioner
  class Template

    attr_accessor :name
    attr_reader :format_version, :description, :resources

    def initialize(name=nil, description: nil)
      @format_version = "2010-09-09"
      @description = description
      @resources = []
      @name = name

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

    def compile(format)
      case format
      when :json
        JSON.pretty_generate(to_h)
      when :yaml
        YAML.dump(to_h)
      end
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
