module AwsProvisioner
  class Runtime
    @@templates = []

    class << self
      def templates
        @@templates
      end
    end
  end
end
