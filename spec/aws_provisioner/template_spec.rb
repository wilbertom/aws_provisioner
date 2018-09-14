describe AwsProvisioner::Template do
  let(:ec2_instance_resource) do
     AwsProvisioner::AWS::EC2::Instance.new "MyEC2Instance", {
      image_id: "ami-0ff8a91507f77f867",
      instance_type: "t2.micro",
      key_name: "test_key",
    }
  end

  describe "#name" do
    it "defaults to nil" do
      template = AwsProvisioner::Template.new

      expect(template.name).to be nil
    end

    it "is the first argument" do
      template = AwsProvisioner::Template.new :example

      expect(template.name).to be :example
    end

    it "can be assigned later on" do
      template = AwsProvisioner::Template.new

      template.name = :new_example

      expect(template.name).to be :new_example
    end
  end

  describe "#format_version" do
    it "defaults to the latest documented version" do
      template = AwsProvisioner::Template.new

      expect(template.format_version).to eq "2010-09-09"
    end
  end

  describe "#description" do
    it "defaults to nil" do
      template = AwsProvisioner::Template.new

      expect(template.description).to be nil
    end

    it "can be set during initialization" do
      template = AwsProvisioner::Template.new description: "A simple template"

      expect(template.description).to eq "A simple template"
    end
  end

  describe "#resources" do
    it "defaults to an empty list" do
      template = AwsProvisioner::Template.new

      expect(template.resources).to be_empty
    end

    it "can be added in a block" do
      template = AwsProvisioner::Template.new do |t|
        t.add ec2_instance_resource
      end

      expect(template.resources).to contain_exactly ec2_instance_resource
    end
  end

  describe "#add" do
    it "adds resource" do
      template = AwsProvisioner::Template.new
      template.add(ec2_instance_resource)

      expect(template.resources).to contain_exactly ec2_instance_resource
    end
  end

  describe "#to_h" do
    it "defaults to a empty template hash" do
      template = AwsProvisioner::Template.new description: "A empty template"

      expect(template.to_h).to eq ({
        "AWSTemplateFormatVersion" => "2010-09-09",
        "Description" => "A empty template",
        "Resources" => {},
      })
    end

    it "also creates hashes of resources added" do
      template = AwsProvisioner::Template.new description: "A empty template" do |t|
        t.add ec2_instance_resource
      end

      expect(template.to_h).to eq ({
        "AWSTemplateFormatVersion" => "2010-09-09",
        "Description" => "A empty template",
        "Resources" => {
          "MyEC2Instance" => {
            "Type" => "AWS::EC2::Instance",
            "ImageId" => "ami-0ff8a91507f77f867",
            "InstanceType" => "t2.micro",
            "KeyName" => "test_key"
          }
        },
      })
    end
  end
end
