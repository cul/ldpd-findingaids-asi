class AeonRequestsController < ApplicationController
  MAX_NUM_ALLOWED_REQUESTS = 100

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
    ids = params.fetch(:ids, [])
    if ids.length > MAX_NUM_ALLOWED_REQUESTS
      render plain: 'Exceeded maximum number of allowed requests.', status: :bad_request
      return
    end

    # TODO: Delete line below.  It's just for testing.
    #ids = "ldpd_8972723_aspace_17f77f5888ed9466208d646733b805c7", "ldpd_13202800_aspace_87a59b7912dd1d74ebf75f3939de6782"

    # TODO: Verify that use has not exceeded maximum number of allowed requests per repository.
    blacklight_repository = Blacklight.repository_class.new(blacklight_config)
    quote_escaped_ids = ids.map { |id| id.gsub('"', '\"') }
    solr_response = blacklight_repository.search(
      fq: %( id:("#{quote_escaped_ids.join('" OR "')}") ),
      fl: '*',
      rows: ids.length
    )

    @documents = solr_response.dig('response', 'docs').map { |doc| SolrDocument.new(doc) }
    @aeon_dll_url = params[:login_method] == 'shib' ? AEON[:shib_dll_url] : AEON[:non_shib_dll_url]
    @notes = params[:notes]
  end
end
