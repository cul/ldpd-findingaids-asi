module AeonRequestHelper
  def checkout_url_for(login_method)
    case login_method
    when :shib
      "#{AEON[:aeon_shib_boom_url]}?target=#{ERB::Util.url_encode(redirectshib_aeon_request_url)}"
    when :nonshib
      redirectnonshib_aeon_request_url
    else
      raise ArgumentError,
            "Unknown login method: #{login_method}.  Only the following login methods are supported: :shib, :nonshib"
    end
  end

  def render_login_method_content(heading, description_above_login_button, login_method, description_below_login_button)
    (
      <<~HEREDOC
        <div>
          <h3 class="h4">#{heading}</h3>
          <p>#{description_above_login_button}</p>
          <a href="#{checkout_url_for(login_method)}" class="btn btn-secondary mb-3">
            Login
          </a>
          <p>#{description_below_login_button}</p>
        </div>
      HEREDOC
    ).html_safe
  end
end
