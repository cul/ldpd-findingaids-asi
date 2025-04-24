require 'faraday'

module Api
  class TurnstileValidationController < ApplicationController
    # Controller to provide token verification via Cloudflare's siteverify
    # see also https://developers.cloudflare.com/turnstile/get-started/server-side-validation/
    def turnstile_config
      @turnstile_config ||= Rails.application.config.bots&.turnstile || Struct.new
    end

    def validate_request(validation_url, validation_request_body)
      begin
        validation_response = Faraday.new(URI.new(validation_url)) do |conn|
          conn.use Faraday::Response::RaiseError
          conn.request :json
          conn.response :json
        end.post(url, validation_request_body)&.body
      rescue Faraday::Error => e
        Rails.logger.error "Turnstile Error: #{e}" if e
        validation_response = { 'success' => !!turnstile_config.fail_open }
      end
      validation_response
    end

    def cors_headers(origin)
      headers = { 'Allow' => 'OPTIONS,POST' }
      if origin.nil? || origin == Rails.application.config.default_host
        headers['Access-Control-Allow-Origin'] = options_headers['Origin']
        headers['Access-Control-Allow-Methods'] = 'OPTIONS,POST'
        # Chromium max preflight duration is 7200 seconds (2 hours)
        headers['Access-Control-Max-Age'] = '7200'
        # the request will need to be JSON, so allow Content-Type
        headers['Access-Control-Allow-Headers'] = 'Content-Type'
        headers['Access-Control-Allow-Credentials'] = 'true'
      end
      headers
    end

    # CORS preflight
    def options
      # this controller should allow POST (for verification) and OPTIONS (for preflight)
      options_headers = cors_headers(request.headers['Origin'])
      if options_headers['Access-Control-Allow-Origin']
        # return a 200
        options_status = :ok
      else
        # return a 405
        options_status = :method_not_allowed
      end
      head options_status, options_headers
    end

    def post
      response_headers = cors_headers(request.headers['Origin'])
      validation_url = turnstile_config&.validation_url
      if validation_url
        validation_request_body = {
          secret: Rails.application.config_for(:secrets).secret_key_turnstile,
          response: params["cf-turnstile-response"],
          remoteip: request.remote_ip
        }
        validation_response = validate_request(validation_url, validation_request_body)

        unless validation_response["success"]
          e = validation_response["error-codes"] && validation_response["error-codes"][0]
          Rails.logger.error "Turnstile Error: #{e}" if e
          # render a failure / false
          render json: { data: false }
        end
      else
          # render a success / true
          render json: { data: true }
      end
    end
  end
end