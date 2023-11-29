# frozen_string_literal: true

module Acfa
  class TopNavbarComponent < Blacklight::TopNavbarComponent
    def logo_link(title: application_name)
      link_to(blacklight_config.logo_link, class: 'mb-0 navbar-brand navbar-logo') do
        'Archival Collections<span class="d-none d-s-inline"> at Columbia University</span>'.html_safe
      end
    end
  end
end
