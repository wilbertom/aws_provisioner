require_relative 'property'
require_relative 'resource'

module AwsProvisioner
  module AWS
    module EC2
      class Instance < Resource
        property :image_id, [:string]
        property :instance_type, [:string]
        property :key_name, [:string]
      end
    end
  end
end
