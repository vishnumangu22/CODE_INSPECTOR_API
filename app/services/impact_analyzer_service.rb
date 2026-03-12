class ImpactAnalyzerService
  def initialize(ast_results, repo_path)
    @ast_results = ast_results
    @repo_path = repo_path
  end

  def analyze
    flags = []

    rules = [
      Rules::ArgumentChangeRule,
      Rules::MethodRemovalRule,
      Rules::MethodAdditionRule,
      Rules::LogicChangeRule,
      Rules::MethodRenameRule,
      Rules::DependencyImpactRule
    ]

    rules.each do |rule|
      flags += rule.new(@ast_results, @repo_path).detect
    end

    flags
  end
end
