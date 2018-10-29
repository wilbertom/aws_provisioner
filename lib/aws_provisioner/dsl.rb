require_relative 'runtime'
require_relative 'template'
require_relative 'resource'

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
