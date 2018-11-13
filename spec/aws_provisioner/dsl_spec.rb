require 'aws_provisioner/dsl'

describe 'AwsProvisioner::DSL' do
  let(:name) { :example }
  let(:description) { 'Example template' }

  describe 'template' do
    it 'takes a optional description parameter which defaults to nil' do
      t = template name do
      end

      expect(t.description).to eq nil
    end

    it 'takes a optional name parameter which defaults to nil' do
      t = template do
      end

      expect(t.name).to eq nil
    end

    it 'creates a AwsProvisioner::Template with the passed name and description' do
      expect(AwsProvisioner::Template).to receive(:new).with(name, description: description)

      template name, description do
      end
    end

    it 'adds a template to the internal global templates variable' do
      expect do
        template name do
        end
      end.to change(AwsProvisioner::Runtime.templates, :count).by 1
    end

    it 'returns the template it adds to the internal global templates variable' do
      t = template name do
      end

      expect(AwsProvisioner::Runtime.templates).to include(t)
    end

    it 'can add resources directly on the block' do
      instance = resource :ec2_instance, 'instance01' do
      end

      t = template name do
        add instance
      end

      expect(t.resources).to include(instance)
    end
  end

  describe 'resource' do
    it 'creates a new resource with the AWS type transformed' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::Some::Aws::Resource', 'instance01', {})
        .and_call_original

      resource :some_aws_resource, 'instance01' do
      end
    end

    it 'renames ec2 to EC2' do
      expect(AwsProvisioner::Resource).to receive(:new)
        .with('AWS::EC2::Instance', 'instance01', {})
        .and_call_original

      resource :ec2_instance, 'instance01' do
      end
    end

    it 'returns the new resource' do
      r = resource :ec2_instance, 'instance01' do
      end

      expect(r).to be_kind_of(AwsProvisioner::Resource)
    end

    context 'with simple properties' do
      it 'sets the ones declared in a block' do
        r = resource :ec2_instance, 'instance01' do
          image_id 'ami-123456'
          instance_type 't2.micro'
          key_name 'test_key'
        end

        expect(r.properties.to_h).to eq(
          image_id: 'ami-123456',
          instance_type: 't2.micro',
          key_name: 'test_key'
        )
      end
    end

    context 'with nested properties' do
      it 'sets the ones declared in a block' do
        r = resource :s3_bucket, 'bucket01' do
          access_control :authenticated_read
          accelerate_configuration do
            acceleration_status :enabled
          end
        end

        expect(r.properties.to_h).to eq(
          access_control: :authenticated_read,
          accelerate_configuration: {
            acceleration_status: :enabled
          }
        )
      end
    end
  end

  describe 'configure' do
    let(:config_file) { 'spec/support/aws_provisioner_config.yaml' }
    let(:environment) { 'testing' }

    before(:each) do
      allow(ENV).to receive(:[]).with('AWS_PROVISIONER_CONFIG').and_return(config_file)
      allow(ENV).to receive(:[]).with('AWS_PROVISIONER_ENVIRONMENT').and_return(environment)
    end

    it 'reads the contents of AWS_PROVISIONER_CONFIG file' do
      expect(File).to receive(:read).with(config_file).and_call_original

      AwsProvisioner::DSL.configure
    end

    it 'configures the environments from the values in the configuration file' do
      AwsProvisioner::Environment.configure({ production: {}, qa: {} }, :qa)

      expect do
        AwsProvisioner::DSL.configure
      end.to change(
        AwsProvisioner::Environment, :environments
      ).to(%i[testing qa staging production])
    end

    it 'adds a global environment predicate for each environment' do
      AwsProvisioner::DSL.configure

      expect(qa?).to be(false)
      expect(staging?).to be(false)
      expect(production?).to be(false)
      expect(testing?).to be(true)
    end

    it 'adds a current global which returns the current environment' do
      AwsProvisioner::DSL.configure

      expect(current).to eq(:testing)
    end

    it 'adds AWS instance type globals' do
      AwsProvisioner::DSL.configure

      expect(t1_micro).to eq('t1.micro')
      expect(m1_small).to eq('m1.small')
      expect(cr1_8xlarge).to eq('cr1.8xlarge')
      expect(u_12tb1_metal).to eq('u-12tb1.metal')
    end
  end
end
