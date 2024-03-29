# frozen_string_literal: true

require 'aws_provisioner/dsl'

describe 'AwsProvisioner::DSL' do
  let(:name) { :example }
  let(:description) { 'Example template' }

  describe 'template' do
    it 'takes a optional description parameter which defaults to nil' do
      t = template name do
      end

      expect(t.description).to eq nil
    end

    it 'takes a optional name parameter which defaults to nil' do
      t = template do
      end

      expect(t.name).to eq nil
    end

    it 'creates a AwsProvisioner::Template with the passed name and description' do
      expect(AwsProvisioner::Template).to receive(:new).with(name, description: description)

      template name, description do
      end
    end

    it 'adds a template to the internal global templates variable' do
      expect do
        template name do
        end
      end.to change(AwsProvisioner::Runtime.templates, :count).by 1
    end

    it 'returns the template it adds to the internal global templates variable' do
      t = template name do
      end

      expect(AwsProvisioner::Runtime.templates).to include(t)
    end

    it 'can add resources directly on the block' do
      instance = resource :ec2_instance, 'instance01' do
      end

      t = template name do
        add instance
      end

      expect(t.resources).to include(instance)
    end
  end

  describe 'resource' do
    it 'creates a new resource with the AWS type transformed' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::Some::Aws::Resource', 'instance01', export: false)
        .and_call_original

      resource :some_aws_resource, 'instance01' do
      end
    end

    it 'accepts a export argument' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::Some::Aws::Resource', 'instance01', export: true)
        .and_call_original

      resource :some_aws_resource, 'instance01', export: true do
      end
    end

    it 'renames ec2 to EC2' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::Instance', 'instance01', export: false)
        .and_call_original

      resource :ec2_instance, 'instance01' do
      end

      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::Subnet', 'subnet01', export: false)
        .and_call_original

      resource :ec2_subnet, 'subnet01' do
      end
    end

    it 'renames ecs to ECS' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::ECS::Cluster', 'cluster01', export: false)
        .and_call_original

      resource :ecs_cluster, 'cluster01' do
      end

      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::ECS::Service', 'service', export: false)
        .and_call_original

      resource :ecs_service, 'service' do
      end
    end

    it 'renames ssm to SSM' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::SSM::Parameter', 'parameter01', export: false)
        .and_call_original

      resource :ssm_parameter, 'parameter01' do
      end
    end

    it 'renames task_definition to TaskDefinition' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::ECS::TaskDefinition', 'task01', export: false)
        .and_call_original

      resource :ecs_task_definition, 'task01' do
      end
    end

    it 'renames guard_duty_detector to GuardDuty::Detector' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::GuardDuty::Detector', 'detector01', export: false)
        .and_call_original

      resource :guard_duty_detector, 'detector01' do
      end
    end

    it 'renames ec2_volume_attachment to EC2::VolumeAttachment' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::VolumeAttachment', 'volumeattachment01', export: false)
        .and_call_original

      resource :ec2_volume_attachment, 'volumeattachment01' do
      end
    end

    it 'renames secret_manager to SecretManager' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::SecretsManager::Secret', 'secret01', export: false)
        .and_call_original

      resource :secrets_manager_secret, 'secret01' do
      end
    end

    it 'renames elastic_load_balancing_v2_load_balancer to ElasticLoadBalancingV2::LoadBalancer' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::ElasticLoadBalancingV2::LoadBalancer', 'lb01', export: false)
        .and_call_original

      resource :elastic_load_balancing_v2_load_balancer, 'lb01' do
      end
    end

    it 'renames certificate_manager_certificate to CertificateManager::Certificate' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::CertificateManager::Certificate', 'certificate01', export: false)
        .and_call_original

      resource :certificate_manager_certificate, 'certificate01' do
      end
    end

    it 'renames elastic_load_balancing_v2_listener to ElasticLoadBalancingV2::Listener' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::ElasticLoadBalancingV2::Listener', 'listener01', export: false)
        .and_call_original

      resource :elastic_load_balancing_v2_listener, 'listener01' do
      end
    end

    it 'renames elastic_load_balancing_v2_target_group to ElasticLoadBalancingV2::TargetGroup' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::ElasticLoadBalancingV2::TargetGroup', 'group01', export: false)
        .and_call_original

      resource :elastic_load_balancing_v2_target_group, 'group01' do
      end
    end

    it 'renames auto_scaling_scheduled_action to AutoScaling::ScheduledAction' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::AutoScaling::ScheduledAction', 'action01', export: false)
        .and_call_original

      resource :auto_scaling_scheduled_action, 'action01' do
      end
    end

    it 'renames log_group to LogGroup' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::Logs::LogGroup', 'logs01', export: false)
        .and_call_original

      resource :logs_log_group, 'logs01' do
      end
    end

    it 'renames eip to EIP' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::EIP', 'eip01', export: false)
        .and_call_original

      resource :ec2_eip, 'eip01' do
      end
    end

    it 'renames nat_gateway to NatGateway' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::NatGateway', 'nat01', export: false)
        .and_call_original

      resource :ec2_nat_gateway, 'nat01' do
      end
    end

    it 'renames internet_gateway to InternetGateway' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::InternetGateway', 'gateway01', export: false)
        .and_call_original

      resource :ec2_internet_gateway, 'gateway01' do
      end
    end

    it 'renames vpc_gateway_attachment to VPCGatewayAttachment' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::VPCGatewayAttachment', 'attachment01', export: false)
        .and_call_original

      resource :ec2_vpc_gateway_attachment, 'attachment01' do
      end
    end

    it 'renames vpc to VPC' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::VPC', 'vpc01', export: false)
        .and_call_original

      resource :ec2_vpc, 'vpc01' do
      end
    end

    it 'renames security_group to SecurityGroup' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::SecurityGroup', 'sg01', export: false)
        .and_call_original

      resource :ec2_security_group, 'sg01' do
      end
    end

    it 'renames iam to IAM' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::IAM::Role', 'role01', export: false)
        .and_call_original

      resource :iam_role, 'role01' do
      end
    end

    it 'renames eks to EKS' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EKS::Cluster', 'cluster01', export: false)
        .and_call_original

      resource :eks_cluster, 'cluster01' do
      end
    end

    it 'renames route_table to RouteTable' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::RouteTable', 'routetable01', export: false)
        .and_call_original

      resource :ec2_route_table, 'routetable01' do
      end
    end

    it 'renames subnet_route_table_association to SubnetRouteTableAssociation' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::SubnetRouteTableAssociation', 'association01', export: false)
        .and_call_original

      resource :ec2_subnet_route_table_association, 'association01' do
      end
    end

    it 'renames db_instance to DBInstance' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::RDS::DBInstance', 'db01', export: false)
        .and_call_original

      resource :rds_db_instance, 'db01' do
      end
    end

    it 'renames rds_db_subnet_group to RDS::DBSubnetGroup' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::RDS::DBSubnetGroup', 'subnetgroup01', export: false)
        .and_call_original

      resource :rds_db_subnet_group, 'subnetgroup01' do
      end
    end

    it 'renames rds_db_parameter_group to RDS::DBParameterGroup' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::RDS::DBParameterGroup', 'parametergroup01', export: false)
        .and_call_original

      resource :rds_db_parameter_group, 'parametergroup01' do
      end
    end

    it 'renames route_53_hosted_zone to Route53::HostedZone' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::Route53::HostedZone', 'zone01', export: false)
        .and_call_original

      resource :route_53_hosted_zone, 'zone01' do
      end
    end

    it 'renames route_53_record_set to Route53::RecordSet' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::Route53::RecordSet', 'record01', export: false)
        .and_call_original

      resource :route_53_record_set, 'record01' do
      end
    end

    it 'renames ec2_vpc_endpoint to AWS::EC2::VPCEndpoint' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::VPCEndpoint', 'endpoint01', export: false)
        .and_call_original

      resource :ec2_vpc_endpoint, 'endpoint01' do
      end
    end

    it 'renames ec2_flow_log to AWS::EC2::FlowLog' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::FlowLog', 'logs01', export: false)
        .and_call_original

      resource :ec2_flow_log, 'logs01' do
      end
    end

    it 'returns the new resource' do
      r = resource :ec2_instance, 'instance01' do
      end

      expect(r).to be_kind_of(AwsProvisioner::Resource)
    end

    it 'adds the new resource to the runtime resources' do
      r = resource :ec2_instance, 'instance01' do
      end

      expect(AwsProvisioner::Runtime.resource(:ec2_instance, 'instance01')).to eq(r)
    end

    context 'with simple properties' do
      it 'sets the ones declared in a block' do
        r = resource :ec2_instance, 'instance01' do
          image_id 'ami-123456'
          instance_type 't2.micro'
          key_name 'test_key'
        end

        expect(r.properties.to_h).to eq(
          image_id: 'ami-123456',
          instance_type: 't2.micro',
          key_name: 'test_key'
        )
      end
    end

    context 'with nested properties' do
      it 'sets the ones declared in a block' do
        r = resource :s3_bucket, 'bucket01' do
          access_control :authenticated_read
          accelerate_configuration do
            acceleration_status :enabled
          end
        end

        expect(r.properties.to_h).to eq(
          access_control: :authenticated_read,
          accelerate_configuration: {
            acceleration_status: :enabled
          }
        )
      end
    end
  end

  describe 'ref' do
    it 'returns a reference to a resource added' do
      resource_name = 'instance01'
      resource :ec2_instance, resource_name do
      end

      expect(ref(:ec2_instance, resource_name)).to eq('Ref' => resource_name)
    end

    it 'raises an error if the resource is not found' do
      expect do
        ref(:ec2_instance, 'some_unkown_resource')
      end.to raise_error(AwsProvisioner::DSL::ReferenceForUnkownResource)
    end
  end

  describe 'configure' do
    let(:config_file) { 'spec/support/aws_provisioner_config.yaml' }
    let(:environment) { 'testing' }

    before(:each) do
      allow(ENV).to receive(:[]).with('AWS_PROVISIONER_CONFIG').and_return(config_file)
      allow(ENV).to receive(:[]).with('AWS_PROVISIONER_ENVIRONMENT').and_return(environment)
    end

    it 'reads the contents of AWS_PROVISIONER_CONFIG file' do
      expect(File).to receive(:read).with(config_file).and_call_original

      AwsProvisioner::DSL.configure
    end

    it 'configures the environments from the values in the configuration file' do
      AwsProvisioner::Environment.configure({ production: {}, qa: {} }, :qa)

      expect do
        AwsProvisioner::DSL.configure
      end.to change(
        AwsProvisioner::Environment, :environments
      ).to(%i[testing qa staging production])
    end

    it 'adds a global environment predicate for each environment' do
      AwsProvisioner::DSL.configure

      expect(qa?).to be(false)
      expect(staging?).to be(false)
      expect(production?).to be(false)
      expect(testing?).to be(true)
    end

    it 'adds a current global which returns the current environment' do
      AwsProvisioner::DSL.configure

      expect(current).to eq(:testing)
    end

    it 'adds AWS instance type globals' do
      AwsProvisioner::DSL.configure

      expect(t1_micro).to eq('t1.micro')
      expect(m1_small).to eq('m1.small')
      expect(cr1_8xlarge).to eq('cr1.8xlarge')
      expect(u_12tb1_metal).to eq('u-12tb1.metal')
    end
  end
end
