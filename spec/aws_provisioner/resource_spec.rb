describe AwsProvisioner::Resource do
  class SubclassResource < AwsProvisioner::Resource
    property :instance_type, [:required, :string]
    property :image_id, [:string]
    property :allow_self_management, [:boolean]
  end

  describe ".property" do
    class AnotherSubclassResource < AwsProvisioner::Resource; end

    it "delegates to the AwsProvisioner::Property class" do
      expect(AwsProvisioner::Property).to receive(:new).with(
        :property_1, [:required, :string]
      ).and_call_original

      AnotherSubclassResource.property(:property_1, [:required, :string])
    end

    it "adds the property to the class properties" do
      expect do
        AnotherSubclassResource.property(:property_2, [:required, :string])
      end.to change { AnotherSubclassResource.property_specs.count }.by(1)
    end
  end

  describe "#name" do
    it "is set during initialization" do
      resource = AwsProvisioner::Resource.new "SomeName", {}

      expect(resource.name).to eq "SomeName"
    end

    it "can't be nil" do
      expect do
        AwsProvisioner::Resource.new nil, {}
      end.to raise_error(ArgumentError)
    end
  end

  describe "#type" do
    module AwsProvisioner::AWS::Service
      class AnotherResource < AwsProvisioner::Resource
      end
    end

    it "is the same as the AWS type when nested in the AWS module" do
      resource = AwsProvisioner::AWS::Service::AnotherResource.new(:name, {})

      expect(resource.type).to eq("AWS::Service::AnotherResource")
    end
  end

  describe "#properties" do
    it "returns a hash of the properties set so far" do
      resource = SubclassResource.new "SomeName", {
        instance_type: "t2.micro",
        image_id: "ami-123456",
      }

      expect(resource.properties).to eq ({
        instance_type: "t2.micro",
        image_id: "ami-123456",
      })
    end

    it "ignores but keeps unknown properties" do
      resource = SubclassResource.new "SomeName", {
        instance_type: "t2.micro",
        image_id: "ami-123456",
        something_else: "abcdefg",
      }

      expect(resource.properties).to eq ({
        instance_type: "t2.micro",
        image_id: "ami-123456",
        something_else: "abcdefg",
      })
    end
  end

  describe "#valid?" do
    it "fails if a property is invalid" do
      resource = SubclassResource.new "SomeName", {
        instance_type: "t2.micro",
        image_id: 123456,
        allow_self_management: true
      }

      expect(resource.valid?).to be false
    end

    it "fails if a unkown property is passed" do
      resource = SubclassResource.new "SomeName", {
        instance_type: "t2.micro",
        image_id: "ami-123456",
        something_else: "abcdefg",
      }

      expect(resource.valid?).to be false
    end

    it "fails if a required property is missing" do
      resource = SubclassResource.new "SomeName", {
        image_id: "ami-123456",
        allow_self_management: false
      }

      expect(resource.valid?).to be false
    end

    it "passes if all properties are valid" do
      resource = SubclassResource.new "SomeName", {
        instance_type: "t2.micro",
        image_id: "ami-123456",
        allow_self_management: true,
      }

      expect(resource.valid?).to be true
    end
  end

  describe "#to_h!" do
    it "returns each property renamed with the AWS type" do
      resource = SubclassResource.new "SomeName", {
        instance_type: "t2.micro",
        image_id: "ami-123456",
        allow_self_management: true,
      }

      expect(resource.to_h!).to eq({
        "InstanceType" => "t2.micro",
        "ImageId" => "ami-123456",
        "AllowSelfManagement" => true,
        "Type" => "SubclassResource",
      })
    end

    it "throws an exception if properties are invalid" do
      resource = SubclassResource.new "SomeName", {}

      expect do
        resource.to_h!
      end.to raise_error(AwsProvisioner::Property::InvalidProperty)
    end
  end
end
