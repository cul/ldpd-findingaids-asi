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

  def grouping_field_value
    box_or_highest_requestable_level_label
  end

  def box_or_highest_requestable_level_label
    # A mapcase itself is not requestable, so for mapcases we return the second-level container
    # (which we are referring to here as the "highest requestable level") and we prefix it with "mapcase, "
    # so that the staff member processing this request knows that the secondary level is something
    # within a mapcase.
    if container_labels.length > 1 && container_labels.first.downcase.include?('mapcase')
      # This is a mapcase and we should group one level below it
      "mapcase, #{container_labels[1]}"
    else
      # Otherwise we'll just use the top level container as the grouping field
      container_labels[0]
    end
  end

  def reference_number
    # NOTE: We have Barnard data in our solr index, and those record won't have a bibid,
    # but we don't currently send Barnard items to Aeon so we don't need to worry about
    # handling that case.  We can always assume that all relevant records have an
    # extractable bibid.
    match_data = @solr_document['id'].match(/ldpd_(.+)_aspace.*/);
    match_data.nil? ? nil : match_data[1]
  end

  def container_labels
    @container_labels ||= container_information.map {|container| container['label']}
  end

  def container_information
    @container_information ||= @solr_document.fetch('container_information_ssm', []).map {|info_json| JSON.parse(info_json) }
  end

  def barcode
    @barcode ||= container_information.map {|container| container['barcode']}.find { |barcode| barcode.present? }
  end

  def folder_number
    @folder_number ||= container_information.map {|container| container['label']}.find { |label|
      label.downcase.include?('folder')
    }
  end

  def series
    return @solr_document['parent_unittitles_ssm'][1] if @solr_document['parent_unittitles_ssm'].length > 1
    nil
  end

  def call_number
    @solr_document['call_number_ss']
  end

  def form_attributes
    form_fields = {}
    form_fields['Site'] = self.repository_local_request_config['site_code']
    # NOTE: We might need to truncate this field later on if values are too long
    form_fields['ItemTitle'] = @solr_document['title_ssm']&.first
    # NOTE about ItemAuthor field:
    # 1) Some documents may not have a creator_ssim value because we only index creator_ssim on some parent level documents.
    # 2) This might mean that in the future we'll want to extract the parent (or grandparent) container creator at index time.
    # 3) For now, we're not sure if it's useful to send the ItemAuthor data to AEON, so we'll leave this field commented out.
    # form_fields['ItemAuthor'] = @solr_document['creator_ssim']&.first
    form_fields['ItemDate'] = @solr_document['normalized_date_ssm']&.first
    form_fields['ReferenceNumber'] = reference_number
    form_fields['DocumentType'] = 'All'
    form_fields['ItemInfo1'] = 'Archival Materials' # Format/Genre in Aeon
    form_fields['ItemInfo3'] = 'UNPROCESSED' if self.unprocessed?
    # The UserReview field controls whether or not the request is directly submitted for processing
    # or is instead saved in a user’s Aeon account for submittal at a future date.
    form_fields['UserReview'] = repository_local_request_config['user_review'].to_s == 'false' ? 'No' : 'Yes'
    # Labeled "Box / Volume" in AEON
    form_fields['ItemVolume'] = self.box_or_highest_requestable_level_label
    # Labeled "Barcode" in AEON
    form_fields['ItemNumber'] = self.barcode
    # Labeled "Series" in AEON
    form_fields['ItemSubTitle'] = self.series
    # Labeled "Call Number" in AEON
    form_fields['CallNumber'] = self.call_number
    # This is different from the site code, and generally formatted as full library name like "Rare Book and Manuscript Library".
    form_fields['Location'] = self.repository_config.name

    form_fields
  end
end
