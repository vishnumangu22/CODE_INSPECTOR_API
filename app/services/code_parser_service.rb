class CodeParserService
  def initialize(structured_diff)
    @diff = structured_diff
  end

  def parse
    {
      methods: extract_methods,
      dependencies: extract_dependencies
    }
  end

  private

  def extract_methods
    methods = []

    @diff.each do |change|
      code = change[:code].strip

      if code.start_with?("def ")
        methods << {
          file: change[:file],
          line: change[:line],
          type: change[:type],
          method: code
        }
      end
    end

    methods
  end

  def extract_dependencies
    dependencies = []
    @diff.each do |change|
      code = change[:code].strip

      if code.start_with?("require") || code.start_with?("import")
        dependencies << {
          file: change[:file],
          line: change[:line],
          type: change[:type],
          dependency: code
        }
      end
    end

    dependencies
  end
end
