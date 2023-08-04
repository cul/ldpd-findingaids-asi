# frozen_string_literal: true

module Cul::Footer::Contact
  class LocationComponent < ViewComponent::Base
    def initialize(repository:)
      @name = repository.name
      @config = repository.location&.slice('link', 'street_address') || {}
    end
    def repository_name
      @name
    end
    def has_location_link?
      @config['link']
    end
    def location_link(classes:)
      link_to @config.dig('link', 'label') || @name, @config.dig('link', 'url'), class: classes
    end

    def in_person_location_data
      street_address = @config.fetch('street_address', {})
      location_data = []
      if street_address['building']
        location_data << ['building', street_address['building']]
      end
      street_address.fetch('address', []).each_with_index do |line, ix|
        location_data << ["address#{ix}", line]
      end
      if street_address['city_state_zip_country']
        location_data << ['city_state_zip_country', street_address['city_state_zip_country']]
      end
      location_data
    end
  end
end
