require 'logger'
require 'colorize'
require 'singleton'

STDOUT.sync = true

module Logging

    class NullLogger < Logger
        def initialize(*args)
        end
        def add(*args,&block)
        end
    end

    class Log
        include Singleton

        @@null_logger = NullLogger.new
        @@logger = Logger.new(STDOUT)

        attr_accessor :silent

        def initialize
            @silent = false
        end

        def get_log
            @silent ? @@null_logger : @@logger
        end
    end

    def self.logger
        Log.instance.get_log
    end

    def logger
        Logging.logger
    end
end