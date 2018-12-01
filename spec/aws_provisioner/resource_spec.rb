# frozen_string_literal: true

describe AwsProvisioner::Resource do
  describe '#name' do
    it 'is set during initialization' do
      resource = AwsProvisioner::Resource.new('AWS::Resource', 'SomeName')

      expect(resource.name).to eq 'SomeName'
    end

    it "can't be nil" do
      expect do
        AwsProvisioner::Resource.new('AWS::Resource', nil)
      end.to raise_error(ArgumentError)
    end
  end

  describe '#type' do
    it 'is the first argument in the CFN format' do
      resource = AwsProvisioner::Resource.new('AWS::Resource', :name)

      expect(resource.type).to eq('AWS::Resource')
    end
  end

  describe '#ref' do
    it 'returns a reference to the resource' do
      resource = AwsProvisioner::Resource.new('AWS::Resource', :name)

      expect(resource.ref).to eq('Ref' => 'name')
    end
  end

  describe '#export' do
    it 'is a optional keyword argument' do
      resource = AwsProvisioner::Resource.new('AWS::Resource', :name, export: true)

      expect(resource.export).to be(true)
    end

    it 'defaults to false' do
      resource = AwsProvisioner::Resource.new('AWS::Resource', :name)

      expect(resource.export).to eq(false)
    end
  end

  describe '#to_h' do
    it 'returns each property renamed with the AWS type' do
      resource = AwsProvisioner::Resource.new(
        'AWS::Resource',
        'SomeName',
        hash: {
          instance_type: 't2.micro',
          image_id: 'ami-123456',
          allow_self_management: true
        }
      )

      expect(resource.to_h).to eq(
        'Properties' => {
          'InstanceType' => 't2.micro',
          'ImageId' => 'ami-123456',
          'AllowSelfManagement' => true
        },
        'Type' => 'AWS::Resource'
      )
    end

    it 'returns nested properties renamed with the AWS type' do
      resource = AwsProvisioner::Resource.new(
        'AWS::Resource',
        'SomeName',
        hash: {
          access_control: 'AuthenticatedRead',
          accelerate_configuration: {
            acceleration_status: 'Enabled'
          }
        }
      )

      expect(resource.to_h).to eq(
        'Properties' => {
          'AccessControl' => 'AuthenticatedRead',
          'AccelerateConfiguration' => {
            'AccelerationStatus' => 'Enabled'
          }
        },
        'Type' => 'AWS::Resource'
      )
    end

    it 'adds any dependencies to the CFN depends on attribute' do
      resource1 = AwsProvisioner::Resource.new('AWS::Resource', :name1)
      resource2 = AwsProvisioner::Resource.new('AWS::Resource', :name2)

      resource1.dependencies << resource2

      expect(resource1.to_h).to eq(
        'Properties' => {},
        'Type' => 'AWS::Resource',
        'DependsOn' => [:name2]
      )
    end
  end

  describe '#dependencies' do
    it 'is empty by default' do
      resource = AwsProvisioner::Resource.new('AWS::Resource', :name)

      expect(resource.dependencies).to be_empty
    end

    it 'resources can be added' do
      resource1 = AwsProvisioner::Resource.new('AWS::Resource', :name1)
      resource2 = AwsProvisioner::Resource.new('AWS::Resource', :name2)
      resource3 = AwsProvisioner::Resource.new('AWS::Resource', :name3)

      expect do
        resource1.dependencies = [resource2, resource3]
      end.to change(resource1, :dependencies).from([]).to([resource2, resource3])
    end
  end
end
