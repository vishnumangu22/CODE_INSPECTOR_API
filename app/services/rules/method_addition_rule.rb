module Rules
  class MethodAdditionRule
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

        new_methods.each do |new_method|
          unless old_methods.any? { |m| m[:name] == new_method[:name] }
            flags << {
              type: "info",
              message: "New method added",
              file: file,
              method: new_method[:name],
              args: new_method[:args]
            }
          end
        end
      end

      flags
    end
  end
end
