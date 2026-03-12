module Rules
  class ArgumentChangeRule
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

          if old_method[:args] != new_method[:args]
            flags << {
              type: "impact",
              message: "Method arguments changed",
              file: file,
              method: old_method[:name],
              old_args: old_method[:args],
              new_args: new_method[:args]
            }
          end
        end
      end

      flags
    end
  end
end
