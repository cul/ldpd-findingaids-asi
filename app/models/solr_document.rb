# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument

  include ActionView::Helpers::TextHelper
  include EadFormatHelpers

  # self.unique_key = 'id'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  attribute :title, :string, 'normalized_title_ssm'

  def repository_id
    self['repository_id_ssi']
  end

  def repository_config
    return unless repository_id

    @repository_config ||= Arclight::Repository.find_by(slug: repository_id)
  end

  def repository
    first('repository_ssm') || collection&.first('repository_ssm') ||
    first('repository_ssim') || collection&.first('repository_ssim')
  end

  # Use normalized_title_html_ssm to get HTML rendering of title
  def normalized_title
    value = first('normalized_title_html_ssm').to_s
    render_html_tags(value: value) if value.present?
  end

  def requestable?
    return false unless repository_config&.request_types&.any?
    return false unless self.containers.present?
    return false if self['aeon_unavailable_for_request_ssi'] == 'true' # NOTE: 'true' is a string here
    true
  end

  def aeon_request
    @aeon_request ||= AeonLocalRequest.new(self)
  end

  # Override to permit indexing of more xlink attributes via Acfa::DigitalObject subclass of Arclight::DigitalObject
  def digital_objects
    digital_objects_field = fetch('digital_objects_ssm', []).reject(&:empty?)
    return [] if digital_objects_field.blank?

    digital_objects_field.map do |object|
      Acfa::DigitalObject.from_json(object)
    end
  end
end
