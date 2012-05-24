class Spree::BillingIntegration::PaypalExpress < Spree::BillingIntegration
  preference :login, :string
  preference :password, :password
  preference :signature, :string
  preference :review, :boolean, :default => false
  preference :no_shipping, :boolean, :default => false
  preference :currency, :string, :default => 'USD'
  preference :allow_guest_checkout, :boolean, :default => false

  attr_accessible :preferred_login, :preferred_password, :preferred_signature, :preferred_review, :preferred_no_shipping, :preferred_currency, :preferred_allow_guest_checkout, :preferred_server, :preferred_test_mode

  def provider_class
    ActiveMerchant::Billing::PaypalExpressGateway
  end
  
  def payment_profiles_supported?
    true
  end

  def capture(payment, source, gateway_options)
    authorization = find_authorization(payment)
    provider.capture(
      (payment.amount * 100).round, 
      authorization.params["transaction_id"], 
      :currency => payment.payment_method.preferred_currency
    )
  end

  private

  def find_authorization(payment)
    logs = payment.log_entries.all(:order => 'created_at DESC')
    logs.each do |log|
      details = YAML.load(log.details) # return the transaction details
      if (details.params['payment_status'] == 'Pending' && details.params['pending_reason'] == 'authorization')
        return details
      end
    end
    return nil
  end
  
  
end
