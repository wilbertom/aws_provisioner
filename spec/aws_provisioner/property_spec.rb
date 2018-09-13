describe AwsProvisioner::Property do
  describe "#name" do
    it "is the first argument" do
      property = AwsProvisioner::Property.new(:name, [:string])

      expect(property.name).to eq :name
    end
  end

  describe "#template_name" do
    it "upper camel casses simple names" do
      property = AwsProvisioner::Property.new(:name, [:string])

      expect(property.template_name).to eq "Name"
    end

    it "upper camel casses names with a underscore" do
      property = AwsProvisioner::Property.new(:image_id, [:string])

      expect(property.template_name).to eq "ImageId"
    end

    it "upper camel casses names with multiple underscores" do
      property = AwsProvisioner::Property.new(:some_other_property, [:string])

      expect(property.template_name).to eq "SomeOtherProperty"
    end
  end

  describe "#type" do
    it "returns string when specified" do
      property = AwsProvisioner::Property.new(:name, [:string])

      expect(property.type).to be :string
    end

    it "returns boolean when specified" do
      property = AwsProvisioner::Property.new(:name, [:boolean])

      expect(property.type).to be :boolean
    end

    it "throws an error if the type can't be found" do
      expect do
        AwsProvisioner::Property.new(:name, [])
      end.to raise_error(ArgumentError)
    end
  end

  describe "#required?" do
    it "is false by default" do
      property = AwsProvisioner::Property.new(:name, [:string])

      expect(property.required?).to be false
    end

    it "can be specified" do
      property = AwsProvisioner::Property.new(:name, [:required, :string])

      expect(property.required?).to be true
    end
  end

  describe "#valid?" do
    context "string" do
      it "is false when a string is of the wrong type" do
        properties = {name: 1234}
        property = AwsProvisioner::Property.new(:name, [:required, :string])

        expect(property.valid?(properties)).to be false
      end

      it "is true when a string is correctly passed" do
        properties = {name: "hello"}
        property = AwsProvisioner::Property.new(:name, [:required, :string])

        expect(property.valid?(properties)).to be true
      end
    end

    context "required" do
      it "is false when a required property is missing" do
        properties = {}
        property = AwsProvisioner::Property.new(:name, [:required, :string])

        expect(property.valid?(properties)).to be false
      end

      it "is true if a optional property is missing" do
        properties = {}
        property = AwsProvisioner::Property.new(:name, [:string])

        expect(property.valid?(properties)).to be true
      end

      it "is false if a optional property is a invalid type" do
        properties = {name: 123}
        property = AwsProvisioner::Property.new(:name, [:string])

        expect(property.valid?(properties)).to be false
      end
    end

    context "boolean" do
      it "is false when a boolean is of the wrong type" do
        properties = {name: 1234}
        property = AwsProvisioner::Property.new(:name, [:required, :boolean])

        expect(property.valid?(properties)).to be false
      end

      it "is true when a boolean is correctly passed" do
        properties = {name: true}
        property = AwsProvisioner::Property.new(:name, [:required, :boolean])

        expect(property.valid?(properties)).to be true
      end
    end
  end

  describe "spec parsing" do
    it "order doesn't matter" do
      property_1 = AwsProvisioner::Property.new(:name, [:required, :string])
      property_2 = AwsProvisioner::Property.new(:name, [:string, :required])

      expect(property_1.required?).to eq(property_2.required?)
      expect(property_1.type).to eq(property_2.type)
    end
  end
end
