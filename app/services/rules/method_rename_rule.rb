module Rules
  class MethodRenameRule
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
          new_methods.each do |new_method|
            next if old_method[:name] == new_method[:name]

            old_body = BodyNormalizerService.new(old_method[:body]).normalize
            new_body = BodyNormalizerService.new(new_method[:body]).normalize

            if old_method[:args] == new_method[:args] && old_body == new_body
              flags << {
                type: "impact",
                message: "Method renamed",
                file: file,
                old_method: old_method[:name],
                new_method: new_method[:name],
                args: old_method[:args]
              }
            end
          end
        end
      end

      flags
    end
  end
end
