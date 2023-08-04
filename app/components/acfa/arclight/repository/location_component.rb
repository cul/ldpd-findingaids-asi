# frozen_string_literal: true

module Acfa::Arclight::Repository
  class LocationComponent < ViewComponent::Base
  	attr_accessor :repository

    delegate :arclight_engine, to: :helpers

    def initialize(repository:)
    	@repository = (Arclight::Repository === repository) ? repository : Arclight::Repository.find_by(slug: repository.id)
    end
    def location_html
      content_tag :address do
        if repository.location_html.present?
          safe_concat(repository.location_html.html_safe)
        else
          safe_concat(location_building_element)
          location_address_elements.each do |location_address_element|
            safe_concat(location_address_element)
          end
        end
      end
    end

    def location_building_element
      if repository.location&.dig('street_address', 'building').present?
        content_tag :div, repository.location.dig('street_address', 'building').html_safe, class: 'al-repository-street-address-building'
      end
    end
    def location_address_elements
      elements = repository.location.dig('street_address', 'address')&.each_with_index do |content, ix|
        content_tag :div, content.html_safe, class: "al-repository-street-address-address#{ix + 1}"
      end || []
      city_state_zip_country = repository.location.dig('street_address', 'city_state_zip_country')
      elements << content_tag(:div, city_state_zip_country, class: "al-repository-street-address-city_state_zip_country") if city_state_zip_country
      elements
    end
  end
end
