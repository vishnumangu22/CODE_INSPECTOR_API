require "parser/current"

module Analysis
  class AlternativeCodeService
    RULES = [

      # 1️⃣ select.first → find
      {
        name: "select_first_to_find",
        match: ->(node) {
          receiver, method = *node
          node.type == :send &&
          method == :first &&
          receiver&.type == :block &&
          receiver.children[0]&.type == :send &&
          receiver.children[0].children[1] == :select
        },
        transform: ->(node) {
          receiver = node.children[0]
          receiver.loc.expression.source.sub(".select", ".find")
        }
      },

      # 2️⃣ map.flatten → flat_map
      {
        name: "map_flatten_to_flat_map",
        match: ->(node) {
          receiver, method = *node
          node.type == :send &&
          method == :flatten &&
          receiver&.type == :block &&
          receiver.children[0]&.type == :send &&
          receiver.children[0].children[1] == :map
        },
        transform: ->(node) {
          receiver = node.children[0]
          receiver.loc.expression.source.sub(".map", ".flat_map")
        }
      },

      # 3️⃣ select.size → count
      {
        name: "select_size_to_count",
        match: ->(node) {
          receiver, method = *node
          node.type == :send &&
          method == :size &&
          receiver&.type == :block &&
          receiver.children[0]&.type == :send &&
          receiver.children[0].children[1] == :select
        },
        transform: ->(node) {
          receiver = node.children[0]
          receiver.loc.expression.source.sub(".select", ".count")
        }
      },

      # 4️⃣ select.any? → any?
      {
        name: "select_any_to_any",
        match: ->(node) {
          receiver, method = *node
          node.type == :send &&
          method == :any? &&
          receiver&.type == :block &&
          receiver.children[0]&.type == :send &&
          receiver.children[0].children[1] == :select
        },
        transform: ->(node) {
          receiver = node.children[0]
          receiver.loc.expression.source.sub(".select", "")
        }
      },

      # 5️⃣ reject.empty? → none?
      {
        name: "reject_empty_to_none",
        match: ->(node) {
          receiver, method = *node
          node.type == :send &&
          method == :empty? &&
          receiver&.type == :block &&
          receiver.children[0]&.type == :send &&
          receiver.children[0].children[1] == :reject
        },
        transform: ->(node) {
          receiver = node.children[0]
          receiver.loc.expression.source
                  .sub(".reject", ".none?")
                  .sub(".empty?", "")
        }
      }

    ]

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

      RULES.each do |rule|
        next unless rule[:match].call(node)

        original = node.loc.expression.source
        suggested = rule[:transform].call(node)

        alternatives << {
          type: "alternative",
          file: @file,
          rule: rule[:name],
          original_code: original,
          suggested_code: suggested
        }
      end

      node.children.each do |child|
        traverse(child, alternatives)
      end
    end
  end
end
