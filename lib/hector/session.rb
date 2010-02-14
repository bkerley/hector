module Hector
  class Session
    attr_reader :nickname, :connection, :identity

    class << self
      def nicknames
        sessions.keys
      end

      def find(nickname)
        sessions[normalize(nickname)]
      end

      def create(nickname, connection, identity)
        if find(nickname)
          raise NicknameInUse, nickname
        else
          returning new(nickname, connection, identity) do |session|
            sessions[normalize(nickname)] = session
          end
        end
      end

      def destroy(nickname)
        sessions.delete(normalize(nickname))
      end

      def normalize(nickname)
        if nickname =~ /^\w[\w-]{0,15}$/
          nickname.downcase
        else
          raise ErroneousNickname, nickname
        end
      end

      def reset!
        @sessions = nil
      end

      protected
        def sessions
          @sessions ||= {}
        end
    end

    def initialize(nickname, connection, identity)
      @nickname = nickname
      @connection = connection
      @identity = identity
    end

    def receive(request)
      @request = request
      if respond_to?(request.event_name)
        send(request.event_name)
      end
    ensure
      @request = nil
    end

    def welcome
      respond_with("001", nickname, :text => "Welcome to IRC")
    end

    def on_quit
      connection.close_connection
    end

    def destroy
      self.class.destroy(nickname)
    end

    protected
      attr_reader :request

      def respond_with(*args)
        connection.respond_with(*args)
      end
  end
end
