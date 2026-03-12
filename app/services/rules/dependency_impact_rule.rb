module Rules
  class DependencyImpactRule
    def initialize(ast_results, repo_path)
      @ast_results = ast_results
      @repo_path = repo_path
    end

    def detect
      flags = []

      @ast_results.each do |file_data|
        file = file_data[:file]

        changed_methods = extract_changed_methods(file_data)

        changed_methods.each do |method|
          affected_files = find_method_usages(method, file)

          next if affected_files.empty?

          flags << {
            type: "impact",
            message: "Method change affects other files",
            file: file,
            method: method,
            affected_files: affected_files
          }
        end
      end

      flags
    end

    private

    def extract_changed_methods(file_data)
      old_methods = file_data[:old_methods] || []
      new_methods = file_data[:new_methods] || []

      changed = []

      old_methods.each do |old_method|
        new_method = new_methods.find { |m| m[:name] == old_method[:name] }

        next unless new_method

        if old_method[:args] != new_method[:args] ||
           old_method[:body] != new_method[:body]
          changed << old_method[:name]
        end
      end

      changed
    end

    def find_method_usages(method, current_file)
      affected = []

      Dir.glob(File.join(@repo_path, "**/*.rb")).each do |file_path|
        next if File.basename(file_path) == current_file

        content = File.read(file_path)

        if content.include?("#{method}(")
          affected << File.basename(file_path)
        end
      end

      affected.uniq
    end
  end
end
