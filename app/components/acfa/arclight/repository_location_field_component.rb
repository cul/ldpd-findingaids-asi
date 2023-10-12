# frozen_string_literal: true

module Acfa::Arclight
  # Render the repository location card as a metadata field
  # This is a Blacklight metadata field rendering component, and not the component for general location rendering
  class RepositoryLocationFieldComponent < ::Arclight::RepositoryLocationComponent
    delegate :arclight_engine, to: :helpers
    def location_html
      content_tag :address do
        if repository.location_html.present?
          safe_concat(repository.location_html.html_safe)
        else
          safe_concat(location_url_element)
          safe_concat(location_building_element)
          location_address_elements.each do |location_address_element|
            safe_concat(location_address_element)
          end
        end
      end
    end
    def location_url_element
      if repository.location&.fetch('link', nil).present?
        content_tag :div, class: 'al-repository-url' do
          link_to repository.location.dig('link', 'label'), repository.location.dig('link', 'url')
        end
      end
    end
    def location_building_element
      if repository.location&.dig('street_address', 'building').present?
        content_tag :div, repository.location.dig('street_address', 'building').html_safe, class: 'al-repository-street-address-building'
      end
    end
    def location_address_elements
      ix = -1
      elements = (repository.location.dig('street_address', 'address') || []).map do |content|
        ix += 1
        content_tag :div, content.html_safe, class: "al-repository-street-address-address#{ix}"
      end
      city_state_zip_country = repository.location.dig('street_address', 'city_state_zip_country')
      elements << content_tag(:div, city_state_zip_country, class: "al-repository-street-address-city_state_zip_country") if city_state_zip_country
      elements
    end
  end
end
