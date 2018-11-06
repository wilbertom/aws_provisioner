require_relative 'runtime'
require_relative 'template'
require_relative 'resource'
require_relative 'environment'

module AwsProvisioner
  module DSL

    private

    def self.translate_resource_type(resource_type)
      type = resource_type
        .to_s
        .split('_')
        .map { |part| self.translate_resource_part_name(part) }
        .join('::')

      "AWS::#{type}"
    end

    def self.translate_resource_part_name(part)
      if part == 'ec2'
        'EC2'
      else
        part.camelize
      end
    end
  end
end

def template(name=nil, description: nil, &block)
  t = AwsProvisioner::Template.new(name, description: description)

  t.instance_eval(&block)
  AwsProvisioner::Runtime.templates << t

  t
end

def resource(resource_type, name, &block)
  aws_type = AwsProvisioner::DSL.translate_resource_type(resource_type)
  r = AwsProvisioner::Resource.new(aws_type, name, {})
  r.properties.instance_eval(&block)

  r
end

class Object
  def add_aws_provisioner_dsl
    AwsProvisioner::Environment.environments.each do |environment|
      define_method("#{environment}?".to_sym) do
        AwsProvisioner::Environment.current?(environment)
      end
    end

    define_method(:current) do
      AwsProvisioner::Environment.current
    end
  end
end

def configure
  config_file_path = ENV["AWS_PROVISIONER_CONFIG"]

  if config_file_path
    config = YAML.load(File.read(config_file_path))

    environments = config["environments"].reduce({}) do |acc, entry|
      key, value = entry
      acc[key.to_sym] = value

      acc
    end

    AwsProvisioner::Environment.configure(
      environments,
      ENV["AWS_PROVISIONER_ENVIRONMENT"].to_sym
    )
  end

  Object.add_aws_provisioner_dsl
end

configure
