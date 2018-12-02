# frozen_string_literal: true

describe AwsProvisioner::Template do
  let(:ec2_instance_resource) do
    AwsProvisioner::Resource.new(
      'AWS::EC2::Instance',
      'MyEC2Instance',
      hash: {
        image_id: 'ami-0ff8a91507f77f867',
        instance_type: 't2.micro',
        key_name: 'test_key'
      }
    )
  end

  let(:s3_bucket_resource) do
    AwsProvisioner::Resource.new(
      'AWS::S3::Bucket',
      'bucket.example.com',
      hash: {
        access_control: 'AuthenticatedRead',
        accelerate_configuration: {
          acceleration_status: 'Enabled'
        }
      },
      export: true
    )
  end

  let(:ec2_vpc_resource) do
    AwsProvisioner::Resource.new(
      'AWS::EC2::VPC',
      'vpc',
      hash: {
        cidr_block: '10.0.0.0/16',
        enable_dns_support: false,
        enable_dns_hostnames: true
      }
    )
  end

  let(:ec2_internet_gateway_resource) do
    AwsProvisioner::Resource.new(
      'AWS::EC2::InternetGateway',
      'gateway',
      hash: {}
    )
  end

  let(:ec2_vpc_gateway_attachment_resource) do
    AwsProvisioner::Resource.new(
      'AWS::EC2::VPCGatewayAttachment',
      'attachment',
      hash: {
        internet_gateway_id: ec2_internet_gateway_resource.ref,
        vpc_id: ec2_vpc_resource.ref
      }
    )
  end

  let(:ec2_eip_resource) do
    ec2_eip_resource = AwsProvisioner::Resource.new(
      'AWS::EC2::EIP',
      'eip',
      hash: {
        domain: 'vpc'
      }
    )

    ec2_eip_resource.dependencies << ec2_internet_gateway_resource

    ec2_eip_resource
  end

  describe '#name' do
    it 'defaults to nil' do
      template = AwsProvisioner::Template.new

      expect(template.name).to be nil
    end

    it 'is the first argument' do
      template = AwsProvisioner::Template.new :example

      expect(template.name).to be :example
    end

    it 'can be assigned later on' do
      template = AwsProvisioner::Template.new

      template.name = :new_example

      expect(template.name).to be :new_example
    end
  end

  describe '#format_version' do
    it 'defaults to the latest documented version' do
      template = AwsProvisioner::Template.new

      expect(template.format_version).to eq '2010-09-09'
    end
  end

  describe '#description' do
    it 'defaults to nil' do
      template = AwsProvisioner::Template.new

      expect(template.description).to be nil
    end

    it 'can be set during initialization' do
      template = AwsProvisioner::Template.new description: 'A simple template'

      expect(template.description).to eq 'A simple template'
    end
  end

  describe '#resources' do
    it 'defaults to an empty list' do
      template = AwsProvisioner::Template.new

      expect(template.resources).to be_empty
    end
  end

  describe '#exports' do
    it 'defaults to an empty list' do
      template = AwsProvisioner::Template.new

      expect(template.exports).to be_empty
    end

    it 'returns exported resources' do
      template = AwsProvisioner::Template.new

      template.add(s3_bucket_resource)

      expect(template.exports).to contain_exactly(s3_bucket_resource)
    end

    it 'does not returns unexported resources' do
      template = AwsProvisioner::Template.new

      template.add(ec2_instance_resource)

      expect(template.exports).to be_empty
    end
  end

  describe '#add' do
    it 'adds resource' do
      template = AwsProvisioner::Template.new
      template.add(ec2_instance_resource)

      expect(template.resources).to contain_exactly ec2_instance_resource
    end

    it 'adds all resources in a composite' do
      template = AwsProvisioner::Template.new
      composite = AwsProvisioner::CompositeResource.new
      composite.add(ec2_instance_resource)
      composite.add(s3_bucket_resource)

      template.add(composite)

      expect(template.resources).to contain_exactly(ec2_instance_resource, s3_bucket_resource)
    end

    it 'adds all resources in composites recursively' do
      template = AwsProvisioner::Template.new

      composite1 = AwsProvisioner::CompositeResource.new
      composite1.add(ec2_instance_resource)
      composite1.add(s3_bucket_resource)
      composite2 = AwsProvisioner::CompositeResource.new
      composite2.add(ec2_vpc_resource)
      composite1.add(composite2)

      template.add(composite1)

      expect(template.resources).to contain_exactly(
        ec2_instance_resource,
        s3_bucket_resource,
        ec2_vpc_resource
      )
    end
  end

  describe '#to_h' do
    it 'defaults to a empty template hash' do
      template = AwsProvisioner::Template.new description: 'A empty template'

      expect(template.to_h).to eq(
        'AWSTemplateFormatVersion' => '2010-09-09',
        'Description' => 'A empty template',
        'Resources' => {},
        'Outputs' => {}
      )
    end

    it 'also creates hashes of resources added' do
      template = AwsProvisioner::Template.new description: 'A empty template'
      template.add(ec2_instance_resource)

      expect(template.to_h).to eq(
        'AWSTemplateFormatVersion' => '2010-09-09',
        'Description' => 'A empty template',
        'Resources' => {
          'MyEC2Instance' => {
            'Properties' => {
              'ImageId' => 'ami-0ff8a91507f77f867',
              'InstanceType' => 't2.micro',
              'KeyName' => 'test_key'
            },
            'Type' => 'AWS::EC2::Instance'
          }
        },
        'Outputs' => {

        }
      )
    end
  end

  describe '#compile' do
    it 'can transform a template to a JSON format' do
      template = AwsProvisioner::Template.new description: 'A empty template'
      template.add(ec2_vpc_resource)
      template.add(ec2_internet_gateway_resource)
      template.add(ec2_vpc_gateway_attachment_resource)
      template.add(ec2_eip_resource)
      template.add(ec2_instance_resource)
      template.add(s3_bucket_resource)

      template_json = <<~TEMPLATE
        {
          "AWSTemplateFormatVersion": "2010-09-09",
          "Description": "A empty template",
          "Resources": {
            "vpc": {
              "Properties": {
                "CidrBlock": "10.0.0.0/16",
                "EnableDnsSupport": false,
                "EnableDnsHostnames": true
              },
              "Type": "AWS::EC2::VPC"
            },
            "gateway": {
              "Properties": {
              },
              "Type": "AWS::EC2::InternetGateway"
            },
            "attachment": {
              "Properties": {
                "InternetGatewayId": {
                  "Ref": "gateway"
                },
                "VpcId": {
                  "Ref": "vpc"
                }
              },
              "Type": "AWS::EC2::VPCGatewayAttachment"
            },
            "eip": {
              "Properties": {
                "Domain": "vpc"
              },
              "Type": "AWS::EC2::EIP",
              "DependsOn": [
                "gateway"
              ]
            },
            "MyEC2Instance": {
              "Properties": {
                "ImageId": "ami-0ff8a91507f77f867",
                "InstanceType": "t2.micro",
                "KeyName": "test_key"
              },
              "Type": "AWS::EC2::Instance"
            },
            "bucket.example.com": {
              "Properties": {
                "AccessControl": "AuthenticatedRead",
                "AccelerateConfiguration": {
                  "AccelerationStatus": "Enabled"
                }
              },
              "Type": "AWS::S3::Bucket"
            }
          },
          "Outputs": {
            "bucket.example.com": {
              "Value": {
                "Ref": "bucket.example.com"
              },
              "Export": {
                "Name": "bucket.example.com"
              }
            }
          }
        }
      TEMPLATE

      expect(template.compile(:json)).to eq(template_json.strip)
    end

    it 'can transform a template to a YAML format' do
      template = AwsProvisioner::Template.new description: 'A empty template'
      template.add(ec2_vpc_resource)
      template.add(ec2_internet_gateway_resource)
      template.add(ec2_vpc_gateway_attachment_resource)
      template.add(ec2_eip_resource)
      template.add(ec2_instance_resource)
      template.add(s3_bucket_resource)

      template_yaml = <<~TEMPLATE
        ---
        AWSTemplateFormatVersion: '2010-09-09'
        Description: A empty template
        Resources:
          vpc:
            Properties:
              CidrBlock: 10.0.0.0/16
              EnableDnsSupport: false
              EnableDnsHostnames: true
            Type: AWS::EC2::VPC
          gateway:
            Properties: {}
            Type: AWS::EC2::InternetGateway
          attachment:
            Properties:
              InternetGatewayId:
                Ref: gateway
              VpcId:
                Ref: vpc
            Type: AWS::EC2::VPCGatewayAttachment
          eip:
            Properties:
              Domain: vpc
            Type: AWS::EC2::EIP
            DependsOn:
            - gateway
          MyEC2Instance:
            Properties:
              ImageId: ami-0ff8a91507f77f867
              InstanceType: t2.micro
              KeyName: test_key
            Type: AWS::EC2::Instance
          bucket.example.com:
            Properties:
              AccessControl: AuthenticatedRead
              AccelerateConfiguration:
                AccelerationStatus: Enabled
            Type: AWS::S3::Bucket
        Outputs:
          bucket.example.com:
            Value:
              Ref: bucket.example.com
            Export:
              Name: bucket.example.com
      TEMPLATE

      expect(template.compile(:yaml)).to eq(template_yaml)
    end
  end
end
