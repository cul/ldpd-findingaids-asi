# frozen_string_literal: true

require 'active_model'
require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

class Repository
  include ActiveModel::Model
  attr_reader :attributes, :id
  alias_method :slug, :id

  DEFAULTS = {
    name: '',
    url: '',
    has_fa_list: false,
    as_repo_id: nil,
    aeon_enabled: false,
    aeon_user_review_set_to_yes: false,
    request_types: {},
    contact_html: '',
    location_html: '',
    visit_note: nil
  }.freeze

  def initialize(id, properties = {})
    @id = id
    @attributes = DEFAULTS.merge(properties).with_indifferent_access
    if @attributes[:requestable_via_aeon]
      @attributes[:request_types] = {
        aeon_local_request: {
          site_code: @attributes[:aeon_site_code],
          user_review: @attributes[:aeon_user_review_set_to_yes]
        }
      }
    end
  end

  def name
    @attributes[:name]
  end

  def url
    @attributes[:url]
  end

  def request_types
    @attributes.fetch(:request_types, {})
  end

  def request_config_for_type(type)
    request_types.fetch(type, {})
  end

  def has_fa_list?
    @attributes[:has_fa_list]
  end

  def as_repo_id
    @attributes[:as_repo_id]
  end

  def aeon_enabled?
    @attributes.dig(:request_types, :aeon_local_request).present?
  end

  def aeon_site_code
    @attributes.dig(:request_types, :aeon_local_request, :site_code)
  end

  def aeon_user_review_set_to_yes?
    @attributes.dig(:request_types, :aeon_local_request, :user_review)
  end

  def checkbox_per_unittitle
    @attributes[:checkbox_per_unittitle]
  end

  def self.exists?(id)
    REPOS.key?(id)
  end

  def self.find(id)
    props = REPOS[id]
    raise ActiveRecord::RecordNotFound.new("Non-existent repo code (#{id})", self, :slug, id) unless props
    Repository.new(id, props)
  end

  def self.all
    REPOS.map { |repo_id, props| Repository.new(repo_id, props) }
  end

  def self.pluck(attribute)
    return REPOS.keys if attribute == :id
    all.map { |repo| repo.send attribute }
  end
end
