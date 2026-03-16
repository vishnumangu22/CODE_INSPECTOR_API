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

    # Run all rules
    rules.each do |rule|
      flags += rule.new(@ast_results, @repo_path).detect
    end

    # Calculate risk score
    risk_score = calculate_risk(flags)

    {
      flags: flags,
      risk_score: risk_score,
      risk_level: risk_level(risk_score)
    }
  end

  private

  def calculate_risk(flags)
    weights = {
      "method_removed" => 5,
      "argument_change" => 4,
      "logic_change" => 3,
      "dependency_change" => 2,
      "method_added" => 1,
      "method_rename" => 2
    }

    score = 0

    flags.each do |flag|
      score += weights[flag[:type]] || 0
    end

    score
  end

  def risk_level(score)
    case score
    when 0..2
      "low"
    when 3..6
      "medium"
    else
      "high"
    end
  end
end
