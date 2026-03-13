require "parser/current"

module Analysis
  class AlternativeCodeService
    def initialize(file, code)
      @file = file
      @code = code
    end

    def generate
      alternatives = []

      return alternatives if @code.nil? || @code.strip.empty?

      ast = Parser::CurrentRuby.parse(@code)

      traverse(ast, alternatives)

      alternatives
    rescue Parser::SyntaxError
      []
    end

    private

    def traverse(node, alternatives)
      return unless node.is_a?(Parser::AST::Node)

      if node.type == :send
        receiver, method_name, *args = *node

        if method_name == :first && receiver&.type == :block
          send_node = receiver.children[0]

          if send_node.type == :send && send_node.children[1] == :select
            collection = send_node.children[0].loc.expression.source
            block_source = receiver.loc.expression.source

            original = node.loc.expression.source
            suggested = block_source.sub(".select", ".find")

            alternatives << {
              type: "alternative",
              file: @file,
              original_code: original,
              suggested_code: suggested
            }
          end
        end
      end

      node.children.each do |child|
        traverse(child, alternatives)
      end
    end
  end
end
