class CodeReview < ApplicationRecord
  validates :repo_url, presence: true
  validates :base_branch, presence: true
  validates :compare_branch, presence: true
end
