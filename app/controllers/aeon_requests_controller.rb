class AeonRequestsController < ApplicationController
  MAX_NUM_ALLOWED_REQUESTS = 100

  # TODO: Delete this (and the associated view) after multi-item Aeon testing is complete
  def test_submission
  end

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
    # If someone visits the checkout url without a valid login_method param, redirect to the select_account page
    # so that a login method can be selected.
    redirect_to action: 'select_account' unless Acfa::LoginMethods::ALLOWED_LOGIN_METHODS.include?(params[:login_method])
  end

  # POST /aeon_requests/create
  def create
    ids = params.fetch(:ids, [])
    if ids.length > MAX_NUM_ALLOWED_REQUESTS
      render plain: 'Exceeded maximum number of allowed requests.', status: :bad_request
      return
    end

    # TODO: Verify that use has not exceeded maximum number of allowed requests per repository.
    blacklight_repository = Blacklight.repository_class.new(blacklight_config)
    quote_escaped_ids = ids.map { |id| id.gsub('"', '\"') }
    solr_response = blacklight_repository.search(
      fq: %( id:("#{quote_escaped_ids.join('" OR "')}") ),
      fl: '*',
      rows: ids.length
    )

    @aeon_requests = solr_response.dig('response', 'docs').map { |doc| SolrDocument.new(doc) }.map { |doc| doc.aeon_request }
    @aeon_dll_url = params[:login_method] == 'shib' ? AEON[:shib_dll_url] : AEON[:non_shib_dll_url]
    @note = params[:note]

    # If a user navigates to the checkout page without any items in their cart, redirect to account selection page
    if @aeon_requests.length < 1
      redirect_to action: 'select_account'
      return
    end
  end
end
