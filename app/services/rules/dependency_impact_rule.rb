require "parser/current"

module Rules
  class DependencyImpactRule
    def initialize(ast_results, repo_path)
      @ast_results = ast_results
      @repo_path = repo_path
    end

    def detect
      flags = []

      removed_methods = []
      renamed_methods = {}
      changed_args_methods = {}

      # Step 1: Identify changes
      @ast_results.each do |result|
        old_methods = result[:old_methods]
        new_methods = result[:new_methods]

        old_names = old_methods.map { |m| m[:name] }
        new_names = new_methods.map { |m| m[:name] }

        # Removed methods
        removed_methods += (old_names - new_names)

        # Renamed methods (basic heuristic)
        old_methods.each do |old_m|
          new_methods.each do |new_m|
            if old_m[:body] == new_m[:body] && old_m[:name] != new_m[:name]
              renamed_methods[old_m[:name]] = new_m[:name]
            end
          end
        end

        # Argument changes
        old_methods.each do |old_m|
          new_m = new_methods.find { |m| m[:name] == old_m[:name] }
          next unless new_m

          if old_m[:args].length != new_m[:args].length
            changed_args_methods[old_m[:name]] = {
              old: old_m[:args].length,
              new: new_m[:args].length
            }
          end
        end
      end

      removed_methods.uniq!

      # Step 2: Scan entire repo using AST
      ruby_files = Dir.glob(File.join(@repo_path, "**/*.rb"))

      ruby_files.each do |file|
        # Skip test/spec files if needed (optional)
        next if file.include?("/spec/") || file.include?("/test/")

        # Check removed methods
        removed_methods.each do |method|
          if method_used_in_file?(file, method)
            flags << {
              type: "dependency_impact",
              message: "Method '#{method}' is removed but still used",
              file: file
            }
          end
        end

        # Check renamed methods
        renamed_methods.each do |old_name, new_name|
          if method_used_in_file?(file, old_name)
            flags << {
              type: "dependency_impact",
              message: "Method '#{old_name}' renamed to '#{new_name}' but still used",
              file: file
            }
          end
        end

        # Check argument changes
        changed_args_methods.each do |method, arg_info|
          if method_used_in_file?(file, method)
            flags << {
              type: "dependency_impact",
              message: "Method '#{method}' arguments changed (#{arg_info[:old]} → #{arg_info[:new]})",
              file: file
            }
          end
        end
      end

      flags
    end

    private

    # 🔥 AST-based method usage detection
    def method_used_in_file?(file, method_name)
      code = File.read(file)
      ast = Parser::CurrentRuby.parse(code)

      return false unless ast

      found = false

      traverse_ast(ast) do |node|
        next unless node.type == :send

        receiver, method, *args = *node

        # Normal method call: obj.method OR method()
        if method == method_name.to_sym
          found = true
          break
        end

        # Dynamic calls: send(:method), public_send(:method)
        if [ :send, :public_send ].include?(method)
          if args[0]&.type == :sym && args[0].children[0] == method_name.to_sym
            found = true
            break
          end
        end
      end

      found
    rescue Parser::SyntaxError
      false
    end

    # 🔁 Recursive AST traversal
    def traverse_ast(node, &block)
      return unless node.is_a?(Parser::AST::Node)

      yield node

      node.children.each do |child|
        traverse_ast(child, &block)
      end
    end
  end
end
