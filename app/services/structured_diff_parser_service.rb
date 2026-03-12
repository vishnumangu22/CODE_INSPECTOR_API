class StructuredDiffParserService
  def initialize(repo_path, base_branch, compare_branch)
    @repo_path = repo_path
    @base_branch = base_branch
    @compare_branch = compare_branch
  end

  def parse
    results = []

    Dir.chdir(@repo_path) do
      diff_output = `git diff origin/#{@base_branch} origin/#{@compare_branch}`

      current_file = nil
      line_number = 0

      diff_output.each_line do |line|
        if line.start_with?("diff --git")
          current_file = line.split(" b/").last.strip
        end

        if line.start_with?("@@")
          match = line.match(/\+(\d+)/)
          line_number = match[1].to_i if match
        end

        if line.start_with?("+") && !line.start_with?("+++")
          results << {
            file: current_file,
            line: line_number,
            type: "added",
            code: line[1..].strip
          }
          line_number += 1
        end

        if line.start_with?("-") && !line.start_with?("---")
          results << {
            file: current_file,
            line: line_number,
            type: "removed",
            code: line[1..].strip
          }
        end
      end
    end



    results
  end
end
