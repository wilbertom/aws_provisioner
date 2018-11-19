# frozen_string_literal: true

require 'json'
require 'yaml'

module AwsProvisioner
  class Template
    attr_accessor :name
    attr_reader :format_version, :description, :resources

    def initialize(name = nil, description: nil)
      @format_version = '2010-09-09'
      @description = description
      @resources = []
      @name = name
    end

    def add(resource)
      resources << resource
    end

    def exports
      resources.select(&:export)
    end

    def to_h
      {
        'AWSTemplateFormatVersion' => format_version,
        'Description' => description,
        'Resources' => resources_to_h,
        'Outputs' => exports_to_h
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
      resources.each_with_object({}) do |resource, acc|
        acc[resource.name] = resource.to_h
      end
    end

    def exports_to_h
      exports.each_with_object({}) do |resource, acc|
        acc[resource.name] = {
          'Value' => resource.ref,
          'Export' => {
            'Name' => resource.name
          }
        }
      end
    end
  end
end
