module Rules
  class MethodRemovalRule
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
          unless new_methods.any? { |m| m[:name] == old_method[:name] }
            flags << {
              type: "impact",
              message: "Method removed",
              file: file,
              method: old_method[:name],
              args: old_method[:args]
            }
          end
        end
      end

      flags
    end
  end
end
