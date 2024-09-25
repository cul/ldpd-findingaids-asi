# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include Arclight::SolrDocument

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

  def requestable?
    return false unless repository_config&.request_types&.any?
    return false unless self.containers.present?
    return false if self['aeon_unavailable_for_request_ssi'] == 'true' # NOTE: 'true' is a string here
    true
  end

  def aeon_request
    @aeon_request ||= AeonLocalRequest.new(self)
  end
end
