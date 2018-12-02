# frozen_string_literal: true

describe AwsProvisioner::CompositeResource do
  describe '#add' do
    it 'adds a resource' do
      resource = AwsProvisioner::Resource.new('AWS::Resource', 'SomeName')
      composite = AwsProvisioner::CompositeResource.new

      expect do
        composite.add(resource)
      end.to change(composite, :resources).from([]).to([resource])
    end
  end
end
