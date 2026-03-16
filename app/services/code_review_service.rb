class CodeReviewService
  def initialize(review)
    @review = review
  end

  def call
    begin
      puts "Starting code review..."

      # Step 1: Clone repository
      repo_path = GitRepositoryService.new(@review.repo_url, @review.id).clone_repository
      puts "Repository cloned at: #{repo_path}"

      # Step 2: Generate structured diff
      diff_parser = StructuredDiffParserService.new(
        repo_path,
        @review.base_branch,
        @review.compare_branch
      )

      structured_diff = diff_parser.parse

      puts "Structured Diff:"
      puts structured_diff

      # Step 3: Identify changed Ruby files
      changed_files = structured_diff.map { |change| change[:file] }.uniq
      ruby_files = changed_files.select { |file| file.end_with?(".rb") }

      puts "Changed Ruby Files:"
      puts ruby_files

      ast_results = []
      syntax_errors = []
      alternatives = []

      Dir.chdir(repo_path) do
        ruby_files.each do |file|
          old_code = `git show origin/#{@review.base_branch}:#{file} 2>/dev/null`
          new_code = `git show origin/#{@review.compare_branch}:#{file} 2>/dev/null`

          next if old_code.empty? && new_code.empty?

          change_type =
            if old_code.empty? && !new_code.empty?
              :new_file
            elsif !old_code.empty? && new_code.empty?
              :deleted_file
            else
              :modified_file
            end

          old_methods = old_code.empty? ? [] : AstParserService.new(old_code).parse_methods
          new_methods = new_code.empty? ? [] : AstParserService.new(new_code).parse_methods

          ast_results << {
            file: file,
            change_type: change_type,
            old_methods: old_methods,
            new_methods: new_methods
          }

          unless new_code.empty?
            syntax_errors += Analysis::SyntaxAnalyzerService
                              .new(file, new_code)
                              .detect

            alternatives += Analysis::AlternativeCodeService
                              .new(file, new_code)
                              .generate
          end
        end
      end

      puts "AST Parsed Methods:"
      puts ast_results

      analyzer = ImpactAnalyzerService.new(ast_results, repo_path)
      impact_result = analyzer.analyze

      puts "Impact Flags:"
      puts impact_result

      # ✅ Update status to completed
      @review.update(status: "completed")

      {
        message: "Code review completed",
        review_id: @review.id,
        flags: impact_result[:flags],
        risk_score: impact_result[:risk_score],
        risk_level: impact_result[:risk_level],
        syntax_errors: syntax_errors,
        alternatives: alternatives
      }

    rescue => e
      @review.update(status: "failed")
      raise e
    end
  end
end
