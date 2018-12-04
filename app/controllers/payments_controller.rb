class PaymentsController < ApplicationController
  # rescue_from Paypal::Exception::APIError, with: :paypal_api_error

  def new
    @payment = Payment.new
  end

  def create
    payment = Payment.new payment_params
    if payment.save
      payment.setup!(
        success_payments_url,
        cancel_payments_url
      )
      redirect_to payment.popup_uri
    else
      render :new
    end
  end

  def show
    @payment = Payment.find_by_transaction_id! params[:id]
  end

  def close_flow
  end

  def success
    handle_callback do |payment|
      payment.complete!(params[:PayerID])
      flash[:notice] = 'Payment Transaction Completed'
      close_popup_payments_url
      # payment_url(payment.transaction_id)
    end
  end

  def cancel
    handle_callback do |payment|
      payment.cancel!
      flash[:notice] = 'Payment Request Canceled'
      close_popup_payments_url
    end
  end

  private
  def handle_callback
    payment = Payment.find_by_token! params[:token]
    @redirect_uri = yield payment
    redirect_to @redirect_uri
  end

  def paypal_api_error(e)
    redirect_to cancel_payments_url, error: e.response.details.collect(&:long_message).join('<br />')
  end

  def payment_params
    params.require(:payment).permit Payment::ALLOWED_PARAMS
  end
end
