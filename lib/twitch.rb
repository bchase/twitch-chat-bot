require 'socket'
require 'logger'


module Twitch
  class Bot
    def initialize(user:, token:, channel:)
      @user     = user
      @token    = token
      @channel  = channel

      @commands = {}

      @logger = Logger.new(STDOUT)
    end

    def connect(&listeners)
      register(&listeners)

      init_socket
      connect_user
      connect_channel

      listen
    end

    private

    attr_reader :user, :token, :channel, :commands
    attr_reader :socket, :logger

    def listen
      loop do
        socket_lines.each do |line|
          logger.info "RECV <<< #{line}"

          handle_line(line)
        end
      end
    end

    def register(&block)
      instance_exec(&block) # TODO separate scope w/ just `command` & `respond`

      logger.info "COMMANDS: #{commands.keys.join(', ')}"
    end
    def command(cmd, &handler)
      commands[cmd.to_s] = -> (args) { instance_exec(args, &handler) }
    end

    def respond(text)
      logger.info "SEND >>> #{text}"

      socket.puts("PRIVMSG ##{channel} #{text}")
    end

    def handle_line(line)
      if cmd = Command.parse(line)
        logger.info "COMMAND @#{cmd.msg.user}: !#{cmd.name} #{cmd.args}"

        if handler = commands[cmd.name]
          handler.call(cmd.args)
        end
      end
    end

    def init_socket
      @socket = TCPSocket.new('irc.chat.twitch.tv', 6667)
    end

    def socket_lines
      IO.select([socket])[0].map(&:gets)
    end

    def connect_user
      logger.info 'Connecting user...'
      socket.puts("PASS #{token}")
      socket.puts("NICK #{user}")
      logger.info 'Connected user!'
    end

    def connect_channel
      logger.info 'Connecting channel...'
      socket.puts("JOIN ##{channel}")
      logger.info 'Connected channel!.'
    end

    Message = Struct.new :raw, :user, :text do
      def self.parse(str)
        user = str[/^:([^!]+)/, 1]
        text = str[/PRIVMSG #[^\s]+ :(.+)/, 1]

        new(str, user, text) if user && text
      end
    end

    Command = Struct.new :msg, :name, :args do
      def self.parse(str)
        msg = Message.parse(str)

        if msg && (match = msg.text.match(/^[!]([^\s]+)(\s+(.*))?/))
          cmd, args = match[1], match[3]
          new(msg, cmd, args)
        end
      end
    end
  end
end
