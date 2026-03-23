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
      "Method removed" => 5,
      "Argument changed" => 4,
      "Logic changed" => 3,
      "Dependency changed" => 2,
      "Method added" => 1,
      "Method renamed" => 2
    }

    score = 0

    flags.each do |flag|
      score += weights[flag[:message]] || 0
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
