# frozen_string_literal: true
class AeonRequest
  attr_reader :solr_document
  def initialize(solr_document)
    @solr_document = solr_document
  end

  def requestable?
    solr_document["components"].blank? && container_locations.present?
  end

  def container_locations
    solr_document.fetch("containers_ssim", [])
  end



end