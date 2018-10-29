describe AwsProvisioner::Properties do
  it "will default a unset property to a empty properties" do
    properties = AwsProvisioner::Properties.new

    expect(properties.instance_type).to be_a(AwsProvisioner::Properties)
    expect(properties.instance_type.empty?).to be(true)
  end

  it "can set a property directly" do
    properties = AwsProvisioner::Properties.new

    expect do
      properties.instance_type = "t2.micro"
    end.to change(properties, :instance_type).to("t2.micro")
  end

  it "can read a property directly" do
    properties = AwsProvisioner::Properties.new
    properties.instance_type = "t2.micro"

    expect(properties.instance_type).to eq "t2.micro"
  end

  it "can set a nested property" do
    properties = AwsProvisioner::Properties.new

    expect do
      properties.accelerate_configuration.acceleration_status = :suspended
    end.to change { properties.accelerate_configuration.acceleration_status }
      .to(:suspended)
  end

  describe ".new" do
    it "can receive a hash of properties to start with" do
      properties = AwsProvisioner::Properties.new({
        instance_type: "t2.micro",
      })

      expect(properties.instance_type).to eq("t2.micro")
    end
  end

  describe "#empty?" do
    it "is true when no properties have been set" do
      properties = AwsProvisioner::Properties.new()

      expect(properties.empty?).to be(true)
    end

    it "is false when a property has been set" do
      properties = AwsProvisioner::Properties.new()

      expect do
        properties.instance_type = "t2.micro"
      end.to change(properties, :empty?).from(true).to(false)
    end

    it "is false if properties were set during initialization" do
      properties = AwsProvisioner::Properties.new({
        instance_type: "t2.micro",
      })

      expect(properties.empty?).to be(false)
    end
  end

  describe "#to_h" do
    it "returns a hash of the set properties" do
      properties = AwsProvisioner::Properties.new({
        instance_type: "t2.micro",
      })

      expect(properties.to_h).to eq({
        instance_type: "t2.micro",
      })
    end

    it "returns a hash of set properties transforming nested properties into hashes" do
      properties = AwsProvisioner::Properties.new
      properties.accelerate_configuration.acceleration_status = :suspended

      expect(properties.to_h).to eq({
        accelerate_configuration: {
          acceleration_status: :suspended,
        },
      })
    end
  end

  describe "#rename" do
    it "returns a new properties object with keys renamed in camel case" do
      properties = AwsProvisioner::Properties.new({
        instance_type: "t2.micro",
      }).rename

      expect(properties).to be_a(AwsProvisioner::Properties)
      expect(properties.InstanceType).to eq("t2.micro")
    end

    it "returns a new properties object with nested keys renamed in camel case" do
      properties = AwsProvisioner::Properties.new
      properties.accelerate_configuration.acceleration_status = :suspended
      properties = properties.rename

      expect(properties.AccelerateConfiguration.AccelerationStatus).to eq(:suspended)
    end
  end

  describe "#to_t" do
    it "reformats the properties into camel cased string keys in CFN template format" do
      properties = AwsProvisioner::Properties.new({
        instance_type: "t2.micro",
      })

      expect(properties.to_t).to eq({
        "InstanceType" => "t2.micro",
      })
    end

    it "reformats nested properties into camel cased string keys in CFN template format" do
      properties = AwsProvisioner::Properties.new({
        access_control: "AuthenticatedRead",
        accelerate_configuration: {
          acceleration_status: "Enabled",
        },
      })

      expect(properties.to_t).to eq({
        "AccessControl" => "AuthenticatedRead",
        "AccelerateConfiguration" => {
          "AccelerationStatus" => "Enabled",
        }
      })
    end
  end
end
