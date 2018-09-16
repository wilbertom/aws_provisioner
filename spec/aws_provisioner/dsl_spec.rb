require 'aws_provisioner/dsl'

describe "AwsProvisioner::DSL" do
  let(:name) { :example }
  let(:description) { "Example template" }

  describe "template" do
    it "takes a optional description parameter which defaults to nil" do
      t = template name do

      end

      expect(t.description).to eq nil
    end

    it "takes a optional name parameter which defaults to nil" do
      t = template do

      end

      expect(t.name).to eq nil
    end

    it "creates a AwsProvisioner::Template with the passed name and description" do
      expect(AwsProvisioner::Template).to receive(:new).with(name, description: description)

      template name, description: description do

      end
    end

    it "adds a template to the internal global templates variable" do
      expect do
        template name do

        end
      end.to change(AwsProvisioner::Runtime.templates, :count).by 1
    end

    it "returns the template it adds to the internal global templates variable" do
      t = template name do

      end

      expect(AwsProvisioner::Runtime.templates).to include(t)
    end

    it "can add resources directly on the block" do
      instance = resource :ec2_instance, "instance01" do

      end

      t = template name do
        add instance
      end

      expect(t.resources).to include(instance)
    end
  end

  describe "resource" do
    it "delegates creating a resource to the underlying AWS type" do
      expect(AwsProvisioner::AWS::EC2::Instance).to receive(:new).with("instance01", {})

      resource :ec2_instance, "instance01" do

      end
    end

    it "returns the new resource" do
      r = resource :ec2_instance, "instance01" do

      end

      expect(r).to be_kind_of(AwsProvisioner::Resource)
    end

    it "raises an error when resource type is unknown" do
      expect do
        resource :some_unkown_resource, "instance01" do

        end
      end.to raise_error(AwsProvisioner::DSL::UnkownResourceType)
    end

    it "sets the properties declared in the block" do
      r = resource :ec2_instance, "instance01" do
        image_id "ami-123456"
        instance_type "t2.micro"
        key_name "test_key"
      end

      expect(r.properties).to eq({
        image_id: "ami-123456",
        instance_type: "t2.micro",
        key_name: "test_key",
      })
    end
  end
end