require 'omniauth/cul'

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Adding the line below so that if the auth endpoint POSTs to our cas endpoint, it won't
  # be rejected by authenticity token verification.
  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: :cas

  def app_cas_callback_endpoint
    "#{request.base_url}/users/auth/cas/callback"
  end

  # GET /users/auth/cas (go here to be redirected to the CAS login form)
  def passthru
    redirect_to Omniauth::Cul::Cas3.passthru_redirect_url(app_cas_callback_endpoint), allow_other_host: true
  end

  # GET /users/auth/cas/callback
  def cas
    user_id, affils = Omniauth::Cul::Cas3.validation_callback(request.params['ticket'], app_cas_callback_endpoint)

    # Custom auth logic for your app goes here.
    # The code below is provided as an example.  If you want to use Omniauth::Cul::PermissionFileValidator,
    # to validate see the later "Omniauth::Cul::PermissionFileValidator" section of this README.
    #
    if Omniauth::Cul::PermissionFileValidator.permitted?(user_id, affils)
      user = User.find_by(uid: user_id) || User.create!(
          uid: user_id,
          email: "#{user_id}@columbia.edu",
          password: Devise.friendly_token[0, 20] # Assign random string password, since the omniauth user doesn't need to know the unused local account password
      )
      sign_in_and_redirect user, event: :authentication # this will throw if @user is not activated
    else
      flash[:error] = 'Your account is not authorized for this application.'
      redirect_to root_path
    end
  end
end
