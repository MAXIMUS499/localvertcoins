class Users::ReviewsController < Users::BaseController

  def create
    service = ReviewService.new(current_user, review_params)
    service.create
    redirect_to request.referer,
      notice: service.message
  end

  private

  def review_params
    params.require(:review).permit(:tone, :offer_id)
  end
end
