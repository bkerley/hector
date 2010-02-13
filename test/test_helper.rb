begin
  require "hector"
  require "test/unit"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

module Hector
  class TestCase < Test::Unit::TestCase
    undef_method :default_test

    def self.test(name, &block)
      define_method("test #{name.inspect}", &block)
    end

    def connection
      Hector::Connection.new("test").extend(TestConnection)
    end

    def identity(username = "username")
      Hector::Identity.new(username)
    end
  end

  module TestConnection
    def sent_data
      @sent_data ||= ""
    end

    def send_data(data)
      sent_data << data
    end

    def connection_closed?
      @connection_closed
    end

    def close_connection(after_writing = false)
      unbind unless connection_closed?
      @connection_closed = true
    end
  end
end
