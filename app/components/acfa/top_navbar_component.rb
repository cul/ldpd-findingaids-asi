# frozen_string_literal: true

module Acfa
  class TopNavbarComponent < Blacklight::TopNavbarComponent
    def logo_link(title: application_name)
      link_to title, blacklight_config.logo_link, class: 'mb-0 navbar-brand navbar-logo'
    end
  end
end
