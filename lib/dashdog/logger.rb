require 'logger'
require 'singleton'

module Dashdog
  class TermColor
    class << self

      def green(msg)
        colorize 32, msg
      end

      def yellow(msg)
        colorize 33, msg
      end

      def red(msg)
        colorize 31, msg
      end

      def colorize(num, msg)
        "\e[#{num}m#{msg}\e[0m"
      end

    end
  end

  class Logger < Logger
    include Singleton

    def initialize
      super(STDERR)

      self.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end

      self.level = Logger::INFO
    end

    def debug(progname = nil, method_name = nil, msg)
      super(progname) { { method_name: method_name, message: msg } }
    end

    def info(msg)
      super { Dashdog::TermColor.green(msg) }
    end

    def warn(msg)
      super { Dashdog::TermColor.yellow(msg) }
    end

    def fatal(msg)
      super { Dashdog::TermColor.red(msg) }
    end

    def error(progname = nil, method_name = nil, msg, backtrace)
      super(progname) { { method_name: method_name, message: msg, backtrace: backtrace } }
    end

    module Helper

      def log(level, message)
        logger = Dashdog::Logger.instance
        logger.send(level, message)
      end

      def info(msg)
        log(:info, msg)
      end

      def warn(msg)
        log(:warn, msg)
      end

      def fatal(msg)
        log(:error, msg)
      end

      def debug(msg)
        log(:debug, msg)
      end

      module_function :log, :info, :warn, :fatal, :debug
    end
  end
end
