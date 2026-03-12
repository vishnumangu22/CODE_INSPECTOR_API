module Rules
  class LogicChangeRule
    def initialize(ast_results, repo_path)
      @ast_results = ast_results
      @repo_path = repo_path
    end

    def detect
      flags = []

      @ast_results.each do |file_data|
        file = file_data[:file]
        old_methods = file_data[:old_methods] || []
        new_methods = file_data[:new_methods] || []

        old_methods.each do |old_method|
          new_method = new_methods.find { |m| m[:name] == old_method[:name] }
          next unless new_method

          old_body = BodyNormalizerService.new(old_method[:body]).normalize
          new_body = BodyNormalizerService.new(new_method[:body]).normalize

          next if old_body.empty? || new_body.empty?

          if old_body != new_body
            flags << {
              type: "warning",
              message: "Method implementation changed",
              file: file,
              method: old_method[:name],
              old_body: old_body,
              new_body: new_body
            }
          end
        end
      end

      flags
    end
  end
end
