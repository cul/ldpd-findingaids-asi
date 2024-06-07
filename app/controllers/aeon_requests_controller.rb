class AeonRequestsController < ApplicationController
  # GET /aeon_requests/redirectshib
  def redirectshib
    redirect_to checkout_aeon_request_url(login_method: 'shib')
  end

  def redirectnonshib
    redirect_to checkout_aeon_request_url(login_method: 'nonshib')
  end

  # POST /aeon_requests/login
  # All cart requests are submitted to this page, where a user chooses
  # whether to check out using uni auth or external (aeon) auth.
  def select_account
  end

  # GET /aeon_requests/checkout
  def checkout
  end

  # POST /aeon_requests/create
  def create
    # TODO: Delete if not used
  end
end
