# frozen_string_literal: true

module Cul::Footer::Contact
  class InformationComponent < ViewComponent::Base
    def initialize(repository:)
      @config = repository.contact&.slice('email', 'phone') || {}
    end
    def contact_email_link(html_attrs = {})
      email = @config.fetch('email', nil)
      link_to email, "mailto:#{email}", html_attrs
    end
    def has_contact_email?
      @config.fetch('email', nil).present?
    end
    def contact_phone_link(html_attrs = {})
      phone = @config.fetch('phone', nil)
      link_to phone, "tel:#{phone}", html_attrs
    end
    def has_contact_phone?
      @config.fetch('phone', nil).present?
    end
  end
end
