class Api::V1::CodeReviewsController < ApplicationController
  def create
    review = CodeReview.create!(review_params.merge(status: "pending"))

    begin
      result = CodeReviewService.new(review).call
      render json: result
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.permit(:repo_url, :base_branch, :compare_branch)
  end
end
