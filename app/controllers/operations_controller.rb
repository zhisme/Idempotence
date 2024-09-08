class OperationsController < ApplicationController
  before_action :validate_number, :validate_idempotency_key

  def create 
    interaction = Operations::CreateInteraction.run(number: permit_params[:number], idempotency_key: permit_params[:idempotency_key])

    if interaction.valid?
      render json: { total: interaction.result }, status: :ok
    else
      render json: { errors: interaction.errors.to_a }, status: :conflict
    end
  end

  private

  def permit_params
    params.permit(:number, :idempotency_key)
  end

  def validate_number
    if permit_params[:number].to_i <= 0
     return render json: { errors: ['Number must be a positive integer'] }, status: :bad_request
    end

  end

  def validate_idempotency_key
    if permit_params[:idempotency_key].present? && REDIS.get(permit_params[:idempotency_key])
      return render json: { total: REDIS.get(permit_params[:idempotency_key]).to_i }, status: :ok
    end
  end
end
