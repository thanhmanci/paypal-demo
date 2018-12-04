class Payment < ActiveRecord::Base

  ALLOWED_PARAMS = [ :quantity]

  validates :token, uniqueness: true, on: :update
  validates :quantity, presence: true
  # validates :transaction_id, uniqueness: true, on: :update

  attr_reader :redirect_uri, :popup_uri
  def setup!(return_url, cancel_url)
    payment_request = payment_request self.quantity
    response = client.setup(
      payment_request,
      return_url,
      cancel_url,
      pay_on_paypal: true
    )
    self.token = response.token
    self.save! rescue false
    @redirect_uri = response.redirect_uri
    @popup_uri = response.popup_uri
    self
  end

  def cancel!
    self.canceled = true
    self.save! rescue false
    self
  end

  def complete!(payer_id = nil)
    payment_request = payment_request  self.quantity
    response = client.checkout!(self.token, payer_id, payment_request)
    self.payer_id = payer_id
    self.transaction_id = response.payment_info.first.transaction_id
    self.status = "completed"
    self.purchased_at = Time.now
    #TODO calculate expires_at

    self.save! rescue false
    self
  end

  def details
    client.details(self.token)
  end

  private
  def client
    Paypal::Express::Request.new PAYPAL_CONFIG
  end

  def payment_request quantity
    t_amount = quantity*amount #total amount
    item = {
      name: "paypal name bcc testing",
      description: "paypal name bcc testing",
      amount: t_amount,
      category: :Digital
    }
    request_attributes ={
      amount: t_amount,
      description: "Paypal instance for testing",
      items: [item]
    }
    Paypal::Payment::Request.new request_attributes
  end
end
