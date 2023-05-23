# frozen_string_literal: true

module AIRefactor
  class Logger
    def initialize(verbose: false, debug: false)
      @verbose = verbose
      @debug = debug
    end

    def info(message)
      puts message
    end

    def debug(message)
      return unless @debug
      puts message.colorize(:light_black)
    end

    def verbose(message)
      return unless @verbose
      puts "[#{message}]".colorize(:light_blue)
    end

    def warn(message)
      puts message.colorize(:yellow)
    end

    def success(message)
      puts message.colorize(color: :green, mode: :bold)
    end

    def error(message, bold: false)
      puts message.colorize(color: :red, mode: bold ? :bold : :default)
    end
  end
end
