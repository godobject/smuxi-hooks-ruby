# encoding: UTF-8
=begin
Copyright GodObject Team <dev@godobject.net>, 2015

This file is part of Smuxi hooks API for Ruby.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
=end

require 'pathname'
require 'set'
require 'yaml'

module GodObject
  module SmuxiHooks

    # Base class that implements basic features of a Smuxi plugin.
    #
    # @note This class is supposed to be an abstract base class and is not
    #   meant to produce instances directly.
    class Plugin

      # @return [String] name of the base configuration directory
      BASE_DIRECTORY_NAME = 'smuxi'

      # @return [String] name of the sub-directory containing the hook handlers
      HOOKS_DIRECTORY_NAME = 'hooks'

      # @return [String] name of the sub-directory containing plugin state
      STATE_DIRECTORY_NAME = 'hook-state'
   
      # @return [String] name of the file in which the permanent state is held
      STATE_FILE_NAME = 'state.yml'

      # @return [{String => Symbol}] maps Smuxi hook names to named of the
      #   method supposed to handle that hook
      HOOK_TABLE = {
        'engine/protocol-manager/on-connected'        => :connected,
        'engine/protocol-manager/on-disconnected'     => :disconnected,
        'engine/protocol-manager/on-message-received' => :message_received,
        'engine/protocol-manager/on-message-sent'     => :message_sent,
        'engine/protocol-manager/on-presence-status-changed' => :presence_status_changed,
        'engine/session/on-group-chat-person-added'   => :chat_person_added,
        'engine/session/on-group-chat-person-removed' => :chat_person_removed,
        'engine/session/on-group-chat-person-updated' => :chat_person_updated,
        'engine/session/on-event-message'             => :event_message 
      }

      # @return [{String => Symbol}] maps Smuxi environment variable names to
      #   instance variables which will inhert the value supplied by Smuxi
      VARIABLE_TABLE = {
        'SMUXI_CHAT_ID'   => :@chat_id,
        'SMUXI_CHAT_NAME' => :@chat_name,
        'SMUXI_CHAT_TYPE' => :@chat_type,
        'SMUXI_MSG'                     => :@message,
        'SMUXI_MSG_TYPE'                => :@message_type,
        'SMUXI_MSG_TIMESTAMP_UNIX'      => :@message_timestamp_unix,
        'SMUXI_MSG_TIMESTAMP_ISO_UTC'   => :@message_timestamp_iso_utc,
        'SMUXI_MSG_TIMESTAMP_ISO_LOCAL' => :@message_timestamp_iso_local,
        'SMUXI_SENDER'   => :@sender,
        'SMUXI_RECEIVER' => :@receiver,
        'SMUXI_PROTOCOL_MANAGER_TYPE'            => :@protocol_manager_type,
        'SMUXI_PROTOCOL_MANAGER_PROTOCOL'        => :@protocol_manager_protocol,
        'SMUXI_PROTOCOL_MANAGER_NETWORK'         => :@protocol_manager_network,
        'SMUXI_PROTOCOL_MANAGER_HOST'            => :@protocol_manager_host,
        'SMUXI_PROTOCOL_MANAGER_PORT'            => :@protocol_manager_port,
        'SMUXI_PROTOCOL_MANAGER_ME_ID'           => :@protocol_manager_me_id,
        'SMUXI_PROTOCOL_MANAGER_PRESENCE_STATUS' => :@protocol_manager_presence_status,
        'SMUXI_PRESENCE_STATUS_CHANGED_OLD_STATUS'  => :@presence_status_old,
        'SMUXI_PRESENCE_STATUS_CHANGED_NEW_STATUS'  => :@presence_status_new,
        'SMUXI_PRESENCE_STATUS_CHANGED_NEW_MESSAGE' => :@presence_status_new_message,
        'SMUXI_CMD'              => :@command,
        'SMUXI_CMD_PARAMETER'    => :@command_parameter,
        'SMUXI_CMD_CHARACTER'    => :@command_character,
        'SMUXI_FRONTEND_VERSION' => :@frontend_version,
        'SMUXI_ENGINE_VERSION'   => :@engine_version 
      }

      class << self

        # Decides whether to execute a plugin hook handler or plugin maintenance
        # features.
        #
        # In case the first command line argument is `install` or `uninstall`,
        # the plugin installation or uninstallation maintenance methods are
        # executed.
        #
        # Otherwise, the plugin expects to be called as a hook handler by Smuxi.
        #
        # @param [String] executable_path path of the plugin executable file
        # @param [{String => String}] environment the environment variables
        #   available to the plugin, defaults to the actual system environment
        # @param [Array<String>] arguments list of command line arguments given
        #   to the plugin, defaults to the actual command line arguments
        # @return [void]
        def execute(executable_path, environment = ENV, arguments = ARGV)
          case arguments.first
          when 'install'
            cli_install(executable_path)
          when 'uninstall'
            cli_uninstall(executable_path)
          else
            execute_hook(executable_path, environment)
          end
        end

        # The name of the hook executed is detected through the name of the
        # executable called. A plugin instance will be created and the hook
        # name is then used to decide which instance method is called on that.
        #
        # @param [String] executable_path path of the plugin executable file
        # @param [{String => String}] environment the environment variables
        #   available to the plugin, defaults to the actual system environment
        # @return [void]
        def execute_hook(executable_path, environment = ENV)
          split_pattern = /\/#{BASE_DIRECTORY_NAME}\/#{HOOKS_DIRECTORY_NAME}\//
          config_directory, relative_executable = executable_path.
                                                  split(split_pattern)

          base_directory      = Pathname.new(config_directory) +
                                BASE_DIRECTORY_NAME
          relative_executable = Pathname.new(relative_executable)
          script_name         = relative_executable.basename.to_s
          hook_name           = relative_executable.dirname.to_s
          state_directory     = base_directory +
                                STATE_DIRECTORY_NAME +
                                hook_name +
                                script_name

          state_file = state_directory + STATE_FILE_NAME

          if state_file.exist?
            state = YAML.load(state_file.read)
          else
            state = {}
          end

          instance = new(
            environment:     environment,
            base_directory:  base_directory,
            script_name:     script_name,
            hook_name:       hook_name,
            state_directory: state_directory,
            state:           state
          )

          if method_name = HOOK_TABLE[hook_name]
            instance.public_send(method_name)

            state_file.open('w') do |io|
              io.write(YAML.dump(instance.state))
            end
          else
            raise "Hook `#{hook_name}` unsupported"
          end
        end

        # Installs the plugin by placing symlinks to the plugin executable into
        # Smuxi's hook handler paths.
        #
        # @note This method outputs to STDOUT and exits the program after it
        #   finishes.
        #
        # @param [String] executable_path path of the plugin executable file
        # @return [void]
        def cli_install(executable_path)
          puts "Creating symlinks at the Smuxi plugin hook locations…"
          puts

          install(executable_path) do |hook_executable_file|
            puts "Creating `#{hook_executable_file}`"
          end

          puts
          puts "Plugin `#{name}` installed."

          exit
        end

        # Uninstalls the plugin by removing symlinks to the plugin executable
        # from Smuxi's hook handler paths.
        #
        # @note This method outputs to STDOUT and exits the program after it
        #   finishes.
        #
        # @param [String] executable_path path of the plugin executable file
        # @return [void]
        def cli_uninstall(executable_path)
          puts "Trying to remove hook symlinks…"
          puts
          
          uninstall(executable_path) do |hook_executable_file|
            puts "Removing `#{hook_executable_file}`"
          end

          puts
          puts "Plugin `#{name}` uninstalled."

          exit
        end

        # @return [Pathname] path to the base directory
        def base_directory_guess
          Pathname.new('~/.local/share').expand_path + BASE_DIRECTORY_NAME
        end

        # @return [Array<Symbol>] a list of the names of all hook handler
        #   instance methods implemented by this class
        def used_hook_methods
          instance_methods.to_set.intersection(HOOK_TABLE.values.to_set)
        end

        # @return [Array<String>] a list of the names of all hooks supported by
        #   this class
        def used_hook_names
          inverted_hook_table = HOOK_TABLE.invert

          used_hook_methods.map do |method_name|
            inverted_hook_table[method_name]
          end
        end

        # @return [Array<String>] a list of the Smuxi hook paths this plugin
        #   needs to be linked in
        # @param [Pathname] base_directory the Smuxi configuration directory.
        #   The hooks directory is expected to reside here
        def used_hook_paths(base_directory = base_directory_guess)
          hooks_directory = base_directory + HOOKS_DIRECTORY_NAME
          
          used_hook_names.map do |hook_name|
            hooks_directory + hook_name
          end
        end

        # Installs the plugin by placing symlinks to the plugin executable into
        # Smuxi's hook handler paths.
        #
        # @param [String] executable_path path of the plugin executable file
        # @param [Pathname] base_directory the configuration directory for
        #   Smuxi. The hooks sub-directory is expected to reside here
        # @return [void]
        def install(executable_path, base_directory = base_directory_guess, &block)
          executable_file = Pathname.new(executable_path).expand_path
          executable_name = executable_file.basename.to_s

          used_hook_paths(base_directory).each do |hook_path|
            hook_path.mkpath
            hook_executable_file = hook_path + executable_name 
            block.call(hook_executable_file) if block
            hook_executable_file.unlink if hook_executable_file.symlink?
            hook_executable_file.make_symlink(executable_file)
          end
        end

        # Uninstalls the plugin by removing symlinks to the plugin executable
        # from Smuxi's hook handler paths.
        #
        # @param [String] executable_path path of the plugin executable file
        # @param [Pathname] base_directory the configuration directory for
        #   Smuxi. The hooks sub-directory is expected to reside here
        # @yield [hook_executable
        # @return [void]
        def uninstall(executable_path, base_directory = base_directory_guess, &block)
          executable_file = Pathname.new(executable_path).expand_path
          executable_name = executable_file.basename.to_s

          used_hook_paths(base_directory).each do |hook_path|
            hook_executable_file = hook_path + executable_name
            block.call(hook_executable_file) if block
            hook_executable_file.unlink if hook_executable_file.symlink?
          end
        end

      end

      attr_reader :state

      # Initializes the plugin.
      #
      # Known variables' values from the supplied environment will be transferred
      # to the respective instance variables. 
      #
      # @see VARIABLE_TABLE
      #
      # @param [Hash] options
      # @option options [{String => String}] environment environment variables for the plugin execution
      # @option options [Pathname] base_directory the configuration directory for
      #   Smuxi. The hooks and hook-state sub-directories are expected to reside
      #   here
      # @option options [Pathname] state_directory the directory that Smuxi
      #   reserved for this plugin to store its state.
      # @option options [String] hook_name name of the Smuxi hook that is executed
      # @option options [String] script_name name of plugin hook executable, without path
      def initialize(options = {})
        @environment     = options[:environment]
        @base_directory  = options[:base_directory]
        @state_directory = options[:state_directory]
        @state           = options[:state]
        @hook_name       = options[:hook_name]
        @script_name     = options[:script_name]

        VARIABLE_TABLE.each do |environment_variable, instance_variable|
          instance_variable_set(instance_variable,
                                @environment[environment_variable])
        end
      end

      # Calls a command in Smuxi
      #
      # @param [String] type the command type
      # @param [Symbol, String] name the command name
      # @param [String] data the argument data added to the command
      # @return [void]
      def command(type, name, data = nil)
        command = "#{type} /#{name}"
        command += " #{data}" if data
        
        STDOUT.puts(command)
      end

      # Calls a session command in Smuxi
      #
      # @param [Symbol, String] name the command name
      # @param [String] data the argument data added to the command
      # @return [void]
      def session_command(name, data = nil)
        command('Session.Command', name, data)
      end

      # Calls a protocol manager command in Smuxi
      #
      # @param [Symbol, String] name the command name
      # @param [String] data the argument data added to the command
      # @return [void]
      def protocol_manager_command(name, data = nil)
        command('ProtocolManager.Command', name, data)
      end

      # Outputs a message to the Smuxi user
      #
      # @param [String] message the text message sent to the Smuxi user
      def puts(message)
        session_command(:echo, message)
      end

    end

  end
end
