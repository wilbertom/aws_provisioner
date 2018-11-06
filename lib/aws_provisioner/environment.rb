module AwsProvisioner
  class Environment
    class InvalidEnvironment < Exception; end

    @@environments = {}
    @@current = nil

    def self.configure(environments, current)
      if !environments.include?(current)
        raise InvalidEnvironment
      end

      @@environments = environments
      @@current = current
    end

    def self.environments
      @@environments.keys
    end

    def self.current
      @@current
    end

    def self.current?(environment)
      current == environment
    end
  end
end
