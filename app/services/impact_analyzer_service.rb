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
    score = 0

    flags.each do |flag|
      case flag[:type]

      when "impact"
        case flag[:message]
        when "Method removed"
          score += 5
        when "Argument changed"
          score += 4
        when "Logic changed"
          score += 3
        when "Method renamed"
          score += 2
        when "Method added"
          score += 1
        end

      when "dependency_impact"
        score += 6   # 🔥 correct place

      end
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
