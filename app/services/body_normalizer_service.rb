class BodyNormalizerService
  def initialize(body)
    @body = body
  end

  def normalize
    return "" if @body.nil?

    normalized = @body.dup

    # Remove comments
    normalized = normalized.gsub(/#.*$/, "")

    # Remove extra spaces
    normalized = normalized.gsub(/\s+/, " ")

    # Remove leading/trailing spaces
    normalized.strip
  end
end
