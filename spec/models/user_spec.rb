require 'rails_helper'

RSpec.describe User, type: :model do
  describe "Devise module inclusions" do
    it "includes :database_authenticatable" do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it "includes :validatable" do
      expect(User.devise_modules).to include(:validatable)
    end

    it "includes :timeoutable" do
      expect(User.devise_modules).to include(:timeoutable)
    end

    it "includes :omniauthable" do
      expect(User.devise_modules).to include(:omniauthable)
    end

    it "configures :cas as an omniauth_provider" do
      expect(User.omniauth_providers).to include(:cas)
    end
  end
end
