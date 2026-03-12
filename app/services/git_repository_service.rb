class GitRepositoryService
  def initialize(repo_url, review_id)
    @repo_url = repo_url
    @review_id = review_id
  end

  def clone_repository
    repo_path = "/tmp/code_review_#{@review_id}"

    # Remove existing folder if present
    if Dir.exist?(repo_path)
      puts "Removing existing repo folder..."
      system("rm -rf #{repo_path}")
    end

    puts "Cloning repository..."

    success = system("git clone #{@repo_url} #{repo_path}")

    unless success
      raise "Repository cloning failed for #{@repo_url}"
    end

    # Fetch all branches to ensure diff works
    Dir.chdir(repo_path) do
      puts "Fetching branches..."
      system("git fetch --all")
    end

    puts "Repository cloned successfully to #{repo_path}"

    repo_path
  end
end
