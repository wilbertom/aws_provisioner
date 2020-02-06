# frozen_string_literal: true

require 'json'
require 'yaml'

require_relative 'composite_resource'

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
      if resource.is_a?(CompositeResource)
        resource.resources.each do |sub_resource|
          add(sub_resource)
        end
      else
        resources << resource
      end
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
            'Name' => "#{current}#{resource.name}"
          }
        }
      end
    end
  end
end
