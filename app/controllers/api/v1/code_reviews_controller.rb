class Api::V1::CodeReviewsController < ApplicationController
  def create
    review = CodeReview.create!(review_params.merge(status: "pending"))

    result = CodeReviewService.new(review).call

    render json: result
  end

  private

  def review_params
    params.permit(:repo_url, :base_branch, :compare_branch)
  end
end
