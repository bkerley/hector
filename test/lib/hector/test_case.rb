module Hector
  class TestCase < Test::Unit::TestCase
    undef_method :default_test

    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end

    def run(*)
      Hector.logger.info "--- #@method_name ---"
      super
      Hector.logger.info " "
    end

    def connection
      Hector::TestConnection.new("test")
    end

    def identity(username = "sam")
      Hector::Identity.find(username)
    end
  end
end
