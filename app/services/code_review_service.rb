class CodeReviewService
  def initialize(review)
    @review = review
  end

  def call
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
        # Step 4: Get old version from base branch
        old_code = `git show origin/#{@review.base_branch}:#{file} 2>/dev/null`

        # Step 5: Get new version from compare branch
        new_code = `git show origin/#{@review.compare_branch}:#{file} 2>/dev/null`

        next if old_code.empty? && new_code.empty?

        # Step 6: Parse AST methods
        old_methods = AstParserService.new(old_code).parse_methods
        new_methods = AstParserService.new(new_code).parse_methods

        ast_results << {
          file: file,
          old_methods: old_methods,
          new_methods: new_methods
        }

        # Step 7: Run Syntax Analyzer
        syntax_errors += Analysis::SyntaxAnalyzerService
                          .new(file, new_code)
                          .detect

        # Step 8: Run Alternative Code Generator
        alternatives += Analysis::AlternativeCodeService
                          .new(file, new_code)
                          .generate
      end
    end

    puts "AST Parsed Methods:"
    puts ast_results

    # Step 9: Run Impact Analyzer
    analyzer = ImpactAnalyzerService.new(ast_results, repo_path)
    flags = analyzer.analyze

    puts "Impact Flags:"
    puts flags

    {
      message: "Code review completed",
      review_id: @review.id,
      flags: flags,
      syntax_errors: syntax_errors,
      alternatives: alternatives
    }
  end
end
