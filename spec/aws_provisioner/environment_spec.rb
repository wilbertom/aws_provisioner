describe AwsProvisioner::Environment do
  let(:environment) { :staging }

  before(:each) do
    AwsProvisioner::Environment.configure({
      production: {},
      staging: {},
    }, environment)
  end

  describe ".configure" do
    it "sets the environments that are valid" do
      expect do
        AwsProvisioner::Environment.configure({
          qa: {},
          testing: {},
          production: {},
        }, :qa)
      end.to change(AwsProvisioner::Environment, :environments).to([
        :qa, :testing, :production
      ])
    end

    it "sets the current environment" do
      expect do
        AwsProvisioner::Environment.configure({
          qa: {},
          testing: {},
          production: {},
        }, :qa)
      end.to change(AwsProvisioner::Environment, :current).to(:qa)
    end

    it "throws an exception if trying to set the current environment to something unknown" do
      expect do
        AwsProvisioner::Environment.configure({
          qa: {},
          testing: {},
          production: {},
        }, :something_else)
      end.to raise_error(AwsProvisioner::Environment::InvalidEnvironment)
    end

    it "throws an exception if trying to set the current environment to nil" do
      expect do
        AwsProvisioner::Environment.configure({
          qa: {},
          testing: {},
          production: {},
        }, nil)
      end.to raise_error(AwsProvisioner::Environment::InvalidEnvironment)
    end
  end

  describe ".environments" do
    it "returns a list of the environments configured" do
      expect(AwsProvisioner::Environment.environments).to match_array([
        :production, :staging,
      ])
    end
  end

  describe ".current" do
    context "with production" do
      let(:environment) { :production }

      it "returns production" do
        expect(AwsProvisioner::Environment.current).to eq(:production)
      end
    end

    context "with staging" do
      let(:environment) { :staging }

      it "returns staging" do
        expect(AwsProvisioner::Environment.current).to eq(:staging)
      end
    end
  end

  describe ".current?" do
    it "returns true for the current environment" do
      expect(AwsProvisioner::Environment.current?(:staging)).to be(true)
    end

    it "returns false for other environments" do
      expect(AwsProvisioner::Environment.current?(:production)).to be(false)
    end
  end
end
