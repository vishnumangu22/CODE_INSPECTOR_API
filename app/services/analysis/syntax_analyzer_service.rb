module Analysis
  class SyntaxAnalyzerService
    def initialize(file, code)
      @file = file
      @code = code
    end

    def detect
      errors = []

      return errors if @code.nil? || @code.strip.empty?

      begin
        RubyVM::InstructionSequence.compile(@code)
      rescue SyntaxError => e
        errors << {
          type: "syntax_error",
          file: @file,
          error: extract_error_message(e.message)
        }
      end

      errors
    end

    private

    def extract_error_message(message)
      message.split("\n").first
    end
  end
end
