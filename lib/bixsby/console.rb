# Console
#
# Controls basic commands for the server while it is running.
#
# @author Justin Leavitt
#
# @since 0.0.1
require 'readline'

module Bixsby
  class Console

    def initialize
      start_server_console
    end

    # Holds available commands
    #
    COMMANDS = {
      'q' => Proc.new { abort("Powering down sir. Good bye...")},
      'h' => Proc.new {
              puts " List of commands:"
              puts " \\h   List help menu"
              puts " \\q   Shutdown server"
            }
    }
    
    ##
    # Opens a loop for accepting commands.
    #
    # @return [Void]
    def start_server_console
      Thread.new do
        while buffer = Readline.readline("> ", true) 
          input = buffer.chomp.strip
          exec_server_command(input)
        end
      end
    end

    ##
    # Executes command issued from the server.
    #
    # @param [String] command
    # @param [Array] arguments
    #
    # @return [Void]
    def exec_server_command(command, *arguments)
      raise unless COMMANDS.include?(command.split("\\")[1])
      COMMANDS[command.split("\\")[1]].call(*arguments)
    rescue
      "Command does not exist"
    end
  end
end
