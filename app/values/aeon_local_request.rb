# frozen_string_literal: true

# This class should be used to turn configuration into a URL and
# POST form specifically aimed at Aeon's external request
# endpoint (https://support.atlas-sys.com/hc/en-us/articles/360011820054-External-Request-Endpoint)
class AeonLocalRequest
  def initialize(solr_document)
    @solr_document = solr_document
  end

  def repository_config
    @repository_config ||= @solr_document.repository_config
  end

  def repository_local_request_config
    @config ||= self.repository_config.request_config_for_type('aeon_local_request')
  end

  def unprocessed?
    @solr_document['parent_access_restrict_tesm'].find { |value| value.downcase.include?('unprocessed') } != nil
  end

  def grouping_field(container_names)
    if container_names.length > 1 && container_names.first.downcase.include?('mapcase')
      # This is a mapcase and we should group one level below it
      container_names[1]
    else
      # Otherwise we'll just use the top level container as the grouping field
      container_names[0]
    end
  end

  def reference_number
    # NOTE: Barnard items won't have a bibid, so we might need to update this later
    match_data = @solr_document['id'].match(/ldpd_(.+)_aspace.*/);
    match_data.nil? ? nil : match_data[0]
  end

  def container_info
    @container_info ||= JSON.parse(@solr_document['container_information_ssm'])
  end

  def

  def barcode
    @barcode ||= container_info.find do |container|
      container['barcode'].present?
    end.first
  end

  def box_number
    @box_number ||= container_info.find do |container|
      container['label'].present? && container['label'].downcase.include?('box')
    end.first
  end

  def series
    @solr_document['parent_unittitles_ssm'][1] if @solr_document['parent_unittitles_ssm'].length > 1
    nil
  end

  def call_number
    @doc['call_number_ss']
  end

  def form_attributes
    form_fields = {}
    form_fields['GroupingField'] = grouping_field(@solr_document.containers)
    # form_fields['GroupingField'] = self.repository_local_request_config['site_code']  # for testing
    form_fields['Site'] = self.repository_local_request_config['site_code']
    # NOTE: We might need to truncate this field later on if values are too long
    form_fields['ItemTitle'] = @solr_document['title_ssm']&.first
    # NOTE: Some documents may not have a creator because they're meant to inherit creator from a parent container document.
    # NOTE: This might mean that in the future we'll want to extract the parent (or grandparent) container creator at index time.
    form_fields['ItemAuthor'] = @solr_document['creator_ssim']&.first
    form_fields['ItemDate'] = @solr_document['normalized_date_ssm']&.first
    form_fields['ReferenceNumber'] = reference_number # TODO: This is currently sending the entire record identifier, and not just the bibid.  Need to fix.
    form_fields['DocumentType'] = 'All'
    form_fields['ItemInfo1'] = 'Archival Materials' # Format/Genre in Aeon
    form_fields['ItemInfo3'] = 'UNPROCESSED' if self.unprocessed?
    # The UserReview field controls whether or not the request is directly submitted for processing
    # or is instead saved in a user’s Aeon account for submittal at a future date.
    form_fields['UserReview'] = repository_local_request_config['user_review'].to_s == 'false' ? 'No' : 'Yes'

    # TODO: Test out submission of newly added fields below

    # Labeled "Box / Volume" in AEON
    form_fields['ItemVolume'] = box_number
    # Labeled "Barcode" in AEON
    form_fields['ItemNumber'] = barcode
    # Labeled "Series" in AEON
    form_fields['ItemSubTitle'] = series
    # Labeled "Call Number" in AEON
    form_fields['CallNumber'] = call_number
    # This is different from the site code, and generally formatted as full library name like "Rare Book and Manuscript Library".
    form_fields['Location'] = repository_config['name']

    form_fields
  end

  # def url
  #   config['request_url'].to_s
  # end

  # def form_mapping
  #   static_mappings.merge(dynamic_mappings)
  # end

  # def static_mappings
  #   config['request_mappings']['static']
  # end

  # def dynamic_mappings
  #   config['request_mappings']['accessor'].transform_values do |v|
  #     @solr_document.send(v.to_sym)
  #   end
  # end

  # def url_params
  #   config['request_mappings']['url_params'].to_query
  # end
end
