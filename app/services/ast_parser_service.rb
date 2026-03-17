require "ripper"

class AstParserService
  def initialize(code)
    @code = code
    @lines = code.split("\n")
  end

  def parse_methods
    ast = Ripper.sexp(@code)
    methods = []

    traverse(ast, methods)

    methods
  end

  private

  def traverse(node, methods)
    return unless node.is_a?(Array)

    if node[0] == :def
      method_name = node[1][1]
      params = extract_params(node[2])

      line_number = node[1][2][0] - 1

      body = extract_method_body(line_number)

      methods << {
        name: method_name,
        args: params,
        body: body
      }
    end

    node.each do |child|
      traverse(child, methods)
    end
  end

  def extract_params(param_node)
    return [] unless param_node.is_a?(Array)

    params = []

    param_node.each do |element|
      if element.is_a?(Array)
        if element[0] == :@ident
          params << element[1]
        else
          params += extract_params(element)
        end
      end
    end

    params
  end

  def extract_method_body(start_line)
    body_lines = []
    depth = 0

    @lines[start_line..].each do |line|
      depth += 1 if line.strip.start_with?("def")
      depth -= 1 if line.strip == "end"

      body_lines << line unless line.strip.start_with?("def") || line.strip == "end"

      if depth == 0
        break
      end
    end

    body_lines.join("\n").strip
  end
end
