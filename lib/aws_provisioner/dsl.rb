# frozen_string_literal: true

require_relative 'runtime'
require_relative 'template'
require_relative 'resource'
require_relative 'environment'

module AwsProvisioner
  module DSL
    class ReferenceForUnkownResource < RuntimeError; end

    def self.configure
      config_file_path = ENV['AWS_PROVISIONER_CONFIG']

      if config_file_path
        config = YAML.safe_load(File.read(config_file_path))
        configure_environment(config)
      end

      Object.add_aws_provisioner_dsl
    end

    def self.translate_resource_type(resource_type)
      type = if RESOURCE_TYPE_SPECIAL_CASES.include?(resource_type)
               RESOURCE_TYPE_SPECIAL_CASES[resource_type]
             else
               resource_type
                 .to_s
                 .split('_')
                 .map { |part| translate_resource_part_name(part) }
                 .join('::')
             end

      "AWS::#{type}"
    end

    # Scraped from the ruby AWS sdk repo running:
    # grep -R m1_xlarge gems/aws-sdk-ec2/lib/aws-sdk-ec2/resource.rb \
    #   | awk '{for(i=7;i<=NF;++i) printf("%s \n",  $i) }'
    # here we grep for a comment in the source code which lists all the valid
    # instance_type values for the Resource#create_instances method
    INSTANCE_TYPES = [
      't1.micro',
      't2.nano',
      't2.micro',
      't2.small',
      't2.medium',
      't2.large',
      't2.xlarge',
      't2.2xlarge',
      't3.nano',
      't3.micro',
      't3.small',
      't3.medium',
      't3.large',
      't3.xlarge',
      't3.2xlarge',
      'm1.small',
      'm1.medium',
      'm1.large',
      'm1.xlarge',
      'm3.medium',
      'm3.large',
      'm3.xlarge',
      'm3.2xlarge',
      'm4.large',
      'm4.xlarge',
      'm4.2xlarge',
      'm4.4xlarge',
      'm4.10xlarge',
      'm4.16xlarge',
      'm2.xlarge',
      'm2.2xlarge',
      'm2.4xlarge',
      'cr1.8xlarge',
      'r3.large',
      'r3.xlarge',
      'r3.2xlarge',
      'r3.4xlarge',
      'r3.8xlarge',
      'r4.large',
      'r4.xlarge',
      'r4.2xlarge',
      'r4.4xlarge',
      'r4.8xlarge',
      'r4.16xlarge',
      'r5.large',
      'r5.xlarge',
      'r5.2xlarge',
      'r5.4xlarge',
      'r5.8xlarge',
      'r5.12xlarge',
      'r5.16xlarge',
      'r5.24xlarge',
      'r5.metal',
      'r5a.large',
      'r5a.xlarge',
      'r5a.2xlarge',
      'r5a.4xlarge',
      'r5a.12xlarge',
      'r5a.24xlarge',
      'r5d.large',
      'r5d.xlarge',
      'r5d.2xlarge',
      'r5d.4xlarge',
      'r5d.8xlarge',
      'r5d.12xlarge',
      'r5d.16xlarge',
      'r5d.24xlarge',
      'r5d.metal',
      'x1.16xlarge',
      'x1.32xlarge',
      'x1e.xlarge',
      'x1e.2xlarge',
      'x1e.4xlarge',
      'x1e.8xlarge',
      'x1e.16xlarge',
      'x1e.32xlarge',
      'i2.xlarge',
      'i2.2xlarge',
      'i2.4xlarge',
      'i2.8xlarge',
      'i3.large',
      'i3.xlarge',
      'i3.2xlarge',
      'i3.4xlarge',
      'i3.8xlarge',
      'i3.16xlarge',
      'i3.metal',
      'hi1.4xlarge',
      'hs1.8xlarge',
      'c1.medium',
      'c1.xlarge',
      'c3.large',
      'c3.xlarge',
      'c3.2xlarge',
      'c3.4xlarge',
      'c3.8xlarge',
      'c4.large',
      'c4.xlarge',
      'c4.2xlarge',
      'c4.4xlarge',
      'c4.8xlarge',
      'c5.large',
      'c5.xlarge',
      'c5.2xlarge',
      'c5.4xlarge',
      'c5.9xlarge',
      'c5.18xlarge',
      'c5d.large',
      'c5d.xlarge',
      'c5d.2xlarge',
      'c5d.4xlarge',
      'c5d.9xlarge',
      'c5d.18xlarge',
      'cc1.4xlarge',
      'cc2.8xlarge',
      'g2.2xlarge',
      'g2.8xlarge',
      'g3.4xlarge',
      'g3.8xlarge',
      'g3.16xlarge',
      'g3s.xlarge',
      'cg1.4xlarge',
      'p2.xlarge',
      'p2.8xlarge',
      'p2.16xlarge',
      'p3.2xlarge',
      'p3.8xlarge',
      'p3.16xlarge',
      'd2.xlarge',
      'd2.2xlarge',
      'd2.4xlarge',
      'd2.8xlarge',
      'f1.2xlarge',
      'f1.4xlarge',
      'f1.16xlarge',
      'm5.large',
      'm5.xlarge',
      'm5.2xlarge',
      'm5.4xlarge',
      'm5.12xlarge',
      'm5.24xlarge',
      'm5a.large',
      'm5a.xlarge',
      'm5a.2xlarge',
      'm5a.4xlarge',
      'm5a.12xlarge',
      'm5a.24xlarge',
      'm5d.large',
      'm5d.xlarge',
      'm5d.2xlarge',
      'm5d.4xlarge',
      'm5d.12xlarge',
      'm5d.24xlarge',
      'h1.2xlarge',
      'h1.4xlarge',
      'h1.8xlarge',
      'h1.16xlarge',
      'z1d.large',
      'z1d.xlarge',
      'z1d.2xlarge',
      'z1d.3xlarge',
      'z1d.6xlarge',
      'z1d.12xlarge',
      'u-6tb1.metal',
      'u-9tb1.metal',
      'u-12tb1.metal'
    ].freeze

    private

    RESOURCE_TYPE_SPECIAL_CASES = {
      auto_scaling_auto_scaling_group: 'AutoScaling::AutoScalingGroup',
      auto_scaling_launch_configuration: 'AutoScaling::LaunchConfiguration',
      auto_scaling_scheduled_action: 'AutoScaling::ScheduledAction',
      certificate_manager_certificate: 'CertificateManager::Certificate',
      ec2_internet_gateway: 'EC2::InternetGateway',
      ec2_nat_gateway: 'EC2::NatGateway',
      ec2_route_table: 'EC2::RouteTable',
      ec2_security_group_egress: 'EC2::SecurityGroupEgress',
      ec2_security_group_ingress: 'EC2::SecurityGroupIngress',
      ec2_security_group: 'EC2::SecurityGroup',
      ec2_subnet_route_table_association: 'EC2::SubnetRouteTableAssociation',
      ec2_vpc_endpoint: 'EC2::VPCEndpoint',
      ec2_vpc_gateway_attachment: 'EC2::VPCGatewayAttachment',
      ecs_task_definition: 'ECS::TaskDefinition',
      elastic_load_balancing_v2_listener: 'ElasticLoadBalancingV2::Listener',
      elastic_load_balancing_v2_load_balancer: 'ElasticLoadBalancingV2::LoadBalancer',
      elastic_load_balancing_v2_target_group: 'ElasticLoadBalancingV2::TargetGroup',
      iam_instance_profile: 'IAM::InstanceProfile',
      logs_log_group: 'Logs::LogGroup',
      rds_db_instance: 'RDS::DBInstance',
      rds_db_parameter_group: 'RDS::DBParameterGroup',
      rds_db_subnet_group: 'RDS::DBSubnetGroup',
      route_53_hosted_zone: 'Route53::HostedZone',
      secrets_manager_secret: 'SecretsManager::Secret'
    }.freeze

    RESOURCE_TYPE_PARTS_UPPER_CASES = %w[
      ec2 vpc eip iam eks ecr rds ecs ssm
    ].freeze

    private_class_method def self.configure_environment(config)
      environments = config['environments'].each_with_object({}) do |entry, acc|
        key, value = entry
        acc[key.to_sym] = value
      end

      AwsProvisioner::Environment.configure(
        environments,
        ENV['AWS_PROVISIONER_ENVIRONMENT'].to_sym
      )
    end

    private_class_method def self.translate_resource_part_name(part)
      if RESOURCE_TYPE_PARTS_UPPER_CASES.include?(part)
        part.upcase
      else
        part.camelize
      end
    end
  end
end

def template(name = nil, description = nil, &block)
  t = AwsProvisioner::Template.new(name, description: description)

  t.instance_eval(&block)
  AwsProvisioner::Runtime.templates << t

  t
end

def resource(resource_type, name, export: false, &block)
  aws_type = AwsProvisioner::DSL.translate_resource_type(resource_type)
  r = AwsProvisioner::Resource.new(aws_type, name, export: export)
  r.properties.instance_eval(&block)
  AwsProvisioner::Runtime.add_resource(resource_type, r)

  r
end

def ref(resource_type, resource_name)
  r = AwsProvisioner::Runtime.resource(resource_type, resource_name)

  raise AwsProvisioner::DSL::ReferenceForUnkownResource if r.nil?

  r.ref
end

class Object
  def add_aws_provisioner_dsl
    add_environment_predicates
    add_current_environment
    add_aws_instance_types
  end

  private

  def add_environment_predicates
    AwsProvisioner::Environment.environments.each do |environment|
      define_method("#{environment}?".to_sym) do
        AwsProvisioner::Environment.current?(environment)
      end
    end
  end

  def add_current_environment
    define_method(:current) do
      AwsProvisioner::Environment.current
    end
  end

  def add_aws_instance_types
    AwsProvisioner::DSL::INSTANCE_TYPES.each do |instance_type|
      define_method(instance_type.tr('.', '_').tr('-', '_').to_s) do
        instance_type
      end
    end
  end
end

AwsProvisioner::DSL.configure
