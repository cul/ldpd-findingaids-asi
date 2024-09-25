# frozen_string_literal: true

class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def authenticate_request_token
    authenticate_or_request_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(INDEX_API['remote_request_api_key'], token)
    end
  end
end
