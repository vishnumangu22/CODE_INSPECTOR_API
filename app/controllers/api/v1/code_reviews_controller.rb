class Api::V1::CodeReviewsController < ApplicationController
  def create
    review = CodeReview.create!(review_params.merge(status: "pending"))

    result = CodeReviewService.new(review).call

    render json: {
      message: "Code review completed",
      review_id: review.id,
      flags: result
    }
  end

  private

  def review_params
    params.permit(:repo_url, :base_branch, :compare_branch)
  end
end
