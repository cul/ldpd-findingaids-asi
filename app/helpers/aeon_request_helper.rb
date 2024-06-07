module AeonRequestHelper
  def checkout_url_for(login_method)
    case login_method
    when :shib
      AEON[:aeon_shib_boom_url]
    when :nonshib
      redirectnonshib_aeon_request_url
    else
      raise ArgumentError,
            "Unknown login method: #{login_method}.  Only the following login methods are supported: :shib, :nonshib"
    end
  end

  def checkout_hidden_fields_for(login_method)
    case login_method
    when :shib
      (
        %(
          <input type="hidden" name="target" value="#{redirectshib_aeon_request_url}" />
        )
      ).html_safe
    when :nonshib
      '<input type="hidden" name="login_method" value="nonshib" />'.html_safe
    else
      raise ArgumentError,
            "Unknown login method: #{login_method}.  Only the following login methods are supported: :shib, :nonshib"
    end
  end

  def render_login_method_content(heading, description_above_login_button, login_method, description_below_login_button)
    (
      <<~HEREDOC
        <form method="GET" action="#{checkout_url_for(login_method)}" data-turbo="false">
          <!-- <input type="hidden" name="#{request_forgery_protection_token}" value="#{form_authenticity_token}" /> -->
          #{checkout_hidden_fields_for(login_method)}
          <h3 class="h4">#{heading}</h3>
          <p>#{description_above_login_button}</p>
          <button type="submit" class="btn btn-secondary mb-3">
            Login
          </button>
          <p>#{description_below_login_button}</p>
        </form>
      HEREDOC
    ).html_safe
  end
end
