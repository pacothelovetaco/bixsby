# Bixsby Server
#
# @author Justin Leavitt
#
# @since 0.0.1
require "socket"
require "securerandom"
require 'programb'
require 'json'
require 'bixsby/console'

# Add new <bixsby> AIML tag
#
# programB is made for AIML which has standards that must
# be followed, but adding a new AIML tag here makes things a little
# easier for plugins.
module Programb
  class Kernel
    def process_bixsby(element, session_id)
      log.debug("Processing..#{element.text}")
      element.text
    end
  end
end


module Bixsby
  class Server
    def initialize(ip, port)
      @server                = TCPServer.open(ip, port)
      @connections           = {}
      @connections[:clients] = {}
      @bixsby                = nil
      wake_bixsby
    end
    
    private

    ##
    # Main loop, loads modules, loads aiml, and waits for user input.
    #
    # @return [Void]
    def wake_bixsby
      # Initiate new ProgramB instance
      # Load in properties and add new AIML node to ProgramB
      bixsby_print "Loading ProgramB version #{Programb::VERSION}"
      @bixsby = Programb::Kernel.new("./config/properties.yml")
      @bixsby.parser["bixsby"] = @bixsby.method(:process_bixsby)

      # Load modules and AIML
      # Loads the guts for Bixsby
      load_modules
      load_aiml

      # Start loop for server commands
      @console = Console.new

      bixsby_print "Good day sir, I am up and running.\nType '\\h' to see a list of my commands."

      # Main loop
      # Listens for connections and initates a new thread for the client.
      loop {
        Thread.start(@server.accept) do |client|
          session_id = set_session
          
          bixsby_print "Established new connection: #{Time.now.to_s}, session_id: #{session_id}, client: #{client.peeraddr.last}"
           
          @connections[:clients][session_id] = client
          
          greeting_msg = @bixsby.respond("Hello")
          formatted_response = package_response(session_id, greeting_msg)

          client.puts(formatted_response)
          bixsby_listen(client)
        end
      }
    end

    ##
    # Initializes all modules in the plugins folder
    #
    # @return [Void]
    def load_modules
      Dir["./plugins/**/lib/*.rb"].each do |file| 
        require file.split(".rb")[0]
        file_name = File.basename(file, ".rb").split('_').collect(&:capitalize).join
        self.class.send(:include, Object.const_get(file_name))
        bixsby_print "Loading Module #{file_name}"
      end
    end
    
    ##
    # Formats a response to send to clients
    #
    # @param [String] session_id
    # @param [String] bixsby_response
    #
    # @return [JSON]
    def package_response(session_id, bixsby_response)
      {
        session_id: session_id, 
        response: bixsby_response 
      }.to_json
    end
    
    ##
    # Loads and parses AIML files, the brains for Bixsby
    #
    # @return [Void]
    def load_aiml
      begin
        bixsby_print "Loading cognitive processes ..."
        
        start_time = Time.now

        # Parse AIML
        @bixsby.learn("aiml/bixsby")

        # Parse AIML for installed modules
        Dir['plugins/**/**/aiml'].each do |file|
          @bixsby.learn(file)
        end
        
        end_time = Time.now

        bixsby_print "Finished loading cognitive processes in #{(end_time - start_time).round}s"
      rescue => e
        raise "Error loading AIML. \n\n #{e.message}"
      end
    end
    
    ##
    # Outputs messages to the server
    # 
    BIXSBY_OUTPUT_TAG = "[bixsby]"
    #
    # @param [String] message
    #
    # @return [Void]
    def bixsby_print(message)
      puts "#{BIXSBY_OUTPUT_TAG} #{message}"
    end

    # Creates a unique id to be used as the session id for the client.
    #
    # @return [String]
    def set_session
      session_id = SecureRandom.hex(4)
      @connections[:clients].each do |other_session, other_client|
        if session_id == other_session
          # session_id is not unique
          set_session
        end
      end
      session_id
    end
    
    ##
    # Sends a message to the client
    #
    # @param [String] session_id the client's session_id
    # @param [String] message the string to send to the client, most cases this
    #                         is a response from Bixsby                        
    # @return [Void]
    def bixsby_say(session_id, message)
      @connections[:clients].each do |client_session, client|
        formatted_response = package_response(session_id, message)
        client.puts(formatted_response) if client_session == session_id
      end
    end

    ##
    # Sends a message to all connected clients
    #
    # @param [String] message the string to send to the client, most cases this
    #                         is a response from Bixsby                        
    # @return [Void]
    def bixsby_say_to_all(message)
      @connections[:clients].each do |client_session, client|
        p client
        formatted_response = package_response(client_session, message)
        client.puts(formatted_response)
      end
    end

    
    ##
    # Listens for input from a connected client. Also removes the client when
    # it disconnects.
    #
    # When a client sends an input to the server, Bixsby is asked to respond.
    # The response is first checked to see if it is a method contained in
    # a loaded module and executes it. If not, the response is simply passed back 
    # to the client.
    #
    # @param [Socket] client
    #
    # @retrun [Void]
    def bixsby_listen(client)
      loop {
        # Remove client if disconnected
        if client.eof?
          remove_client(client)
        end
        
        # Unpack JSON input from client
        client_response = JSON.parse(client.gets.chomp)
        session_id = client_response["session_id"]
        input = client_response["input"]

        # Ask Bisby to respond to input
        response = @bixsby.respond(input)
        
        # If response is a method, pass to module, else just
        # send the response
        method = response.gsub(/\s+/, "").split(",")[0]
        args   = response.gsub(/\s+/, "").split(",")[1..-1]
        
        if self.respond_to?(method)
          begin
            send(method, session_id, *args) 
          rescue => e
            bixsby_say(session_id, "#{e.message}\n#{e.backtrace}")
          end
        else
          bixsby_say(session_id, response)
        end
      }
    end
    
    ##
    # Removes a client from the connections list when it disconnects
    #
    # @param [Socket] client
    #
    # @return [Void]
    def remove_client(client)
      session_id = @connections[:clients].key(client)
      @connections[:clients].delete(session_id)
      bixsby_print "Client #{client.peeraddr.last} disconnected." 
    end
  end
end
