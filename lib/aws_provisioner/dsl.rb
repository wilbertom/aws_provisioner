require_relative 'runtime'
require_relative 'aws'
require_relative 'template'

module AwsProvisioner
  module DSL

    class UnkownResourceType < Exception
    end

    private
    def self.translate_resource_type(resource_type)
      class_path = resource_type
        .to_s
        .split('_')
        .map { |part| self.translate_resource_part_name(part) }
        .join('::')

      ('AwsProvisioner::AWS::' + class_path).constantize
    rescue NameError
      raise UnkownResourceType
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
  aws_type_cls = AwsProvisioner::DSL.translate_resource_type(resource_type)
  r = aws_type_cls.new(name, {})
  r.instance_eval(&block)

  r
end
