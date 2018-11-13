# frozen_string_literal: true

describe AwsProvisioner::Resource do
  describe '#name' do
    it 'is set during initialization' do
      resource = AwsProvisioner::Resource.new 'AWS::Resource', 'SomeName', {}

      expect(resource.name).to eq 'SomeName'
    end

    it "can't be nil" do
      expect do
        AwsProvisioner::Resource.new :resource, nil, {}
      end.to raise_error(ArgumentError)
    end
  end

  describe '#type' do
    it 'is the first argument in the CFN format' do
      resource = AwsProvisioner::Resource.new('AWS::Resource', :name, {})

      expect(resource.type).to eq('AWS::Resource')
    end
  end

  describe '#to_h' do
    it 'returns each property renamed with the AWS type' do
      resource = AwsProvisioner::Resource.new 'AWS::Resource', 'SomeName',
                                              instance_type: 't2.micro',
                                              image_id: 'ami-123456',
                                              allow_self_management: true

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
      resource = AwsProvisioner::Resource.new 'AWS::Resource', 'SomeName',
                                              access_control: 'AuthenticatedRead',
                                              accelerate_configuration: {
                                                acceleration_status: 'Enabled'
                                              }

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
  end
end
