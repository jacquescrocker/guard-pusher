require 'guard'
require 'guard/guard'
require 'pusher'

module Guard
  class Pusher < Guard

    def self.configure(options)
      %w{app_id key secret}.inject(Hash.new) { |hash, key|
        hash[key] = options[key] || options[key.to_sym]
        hash
      }.each { |config, value|
        ::Pusher.send("#{config}=", value)
      }

      ::Pusher[options[:channel] || 'guard-pusher']

      rescue ::Pusher::ConfigurationError
    end

    def initialize(watchers = [], options = {})
      super

      @options = options
      @options[:channel] ||= 'guard-pusher'
      @options[:event] ||= 'guard'

      config = if File.file?('config/pusher.yml')
        YAML.load_file('config/pusher.yml')['development']
      else
        options
      end

      if self.class.configure(config)
        UI.info('Pusher is ready.', :reset => true)
      else
        UI.info("D'oh! Pusher not properly configured. Make sure to add app_id, key and secret.", :reset => true)
      end
    end

    def run_on_change(paths)
      UI.info "Pushing #{ paths.join(', ') }", :reset => true
      ::Pusher[@options[:channel]].trigger(@options[:event], {:paths => paths})
    end

  end
end
