require "parser/current"

module Analysis
  class SyntaxAnalyzerService
    def initialize(file, code)
      @file = file
      @code = code
    end

    def detect
      errors = []

      return errors if @code.nil? || @code.strip.empty?

      buffer = Parser::Source::Buffer.new(@file)
      buffer.source = @code

      parser = Parser::CurrentRuby.new

      # Handle parser diagnostics safely
      parser.diagnostics.consumer = lambda do |diagnostic|
        errors << {
          type: "syntax_error",
          file: @file,
          line: diagnostic.location.line,
          column: diagnostic.location.column,
          error: diagnostic.message
        }
      end

      parser.parse(buffer)

      errors
    rescue Parser::SyntaxError => e
      errors << {
        type: "syntax_error",
        file: @file,
        error: e.message.split("\n").first
      }
      errors
    end
  end
end
