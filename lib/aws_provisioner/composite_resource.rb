# frozen_string_literal: true

module AwsProvisioner
  class CompositeResource
    attr_reader :resources

    def initialize
      @resources = []
    end

    def add(resource)
      @resources << resource
    end
  end
end
