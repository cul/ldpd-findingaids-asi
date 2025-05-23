# frozen_string_literal: true

class Users::DevelopmentController < ApplicationController
  # POST /users/development/sign_in_developer
  # Log in with a development account instead of the default CAS login.
  # Used only in the development environment, as a convenience.
  def sign_in_developer
    return unless Rails.env.development?

    unless user_signed_in?
      dev_user = User.find_by(
        uid: DEVELOPMENT_USER_CONFIG[:uid]
      ) || User.create!(DEVELOPMENT_USER_CONFIG)

      sign_in(dev_user, scope: :user)
    end

    redirect_to after_sign_in_path
  end
end
