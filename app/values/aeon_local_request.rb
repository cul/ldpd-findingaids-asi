# frozen_string_literal: true

# This class should be used to turn configuration into a URL and
# POST form specifically aimed at Aeon's external request
# endpoint (https://support.atlas-sys.com/hc/en-us/articles/360011820054-External-Request-Endpoint)
class AeonLocalRequest
  def initialize(solr_document)
    raise ArgumentError.new("solr_document cannot be nil") if solr_document.nil?
    @solr_document = solr_document
  end

  def repository_config
    @repository_config ||= @solr_document.repository_config
  end

  def repository_local_request_config
    @config ||= self.repository_config&.request_config_for_type('aeon_local_request')
  end

  def unprocessed?
    return false unless @solr_document['parent_access_restrict_tesm']

    @solr_document['parent_access_restrict_tesm'].find { |value| value.downcase.include?('unprocessed') } != nil
  end

  def digital?
    @solr_document['digital_objects_ssm'].present?
  end
  
  def grouping_field_value
    box_or_highest_requestable_level_label
  end

  def box_or_highest_requestable_level_label
    # A mapcase or drawer itself is not requestable, so for mapcases we return the second-level container
    # (which we are referring to here as the "highest requestable level") and we prefix it with the label,
    # so that the staff member processing this request knows that the secondary level is something
    # within a mapcase or drawer.
    if container_labels.length > 1 && mapcase_or_drawer?(container_labels.first)
      # This is a mapcase and we should group one level below it
      "#{container_labels.first}, #{container_labels[1]}"
    else
      # Otherwise we'll just use the top level container as the grouping field
      container_labels[0]
    end
  end
  
  def mapcase_or_drawer?(label)
    label.downcase.include?('mapcase') || label.downcase.include?('drawer')
  end

  def reference_number
    # NOTE: We have Barnard data in our solr index, and those record won't have a bibid,
    # but we don't currently send Barnard items to Aeon so we don't need to worry about
    # handling that case.  We can always assume that all relevant records have an
    # extractable bibid.
    return nil unless @solr_document['id']

    match_data = @solr_document['id'].match(/cul-(.+)_aspace.*/);
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
    return nil unless @solr_document['parent_unittitles_ssm'] && @solr_document['parent_unittitles_ssm'].length > 1

    @solr_document['parent_unittitles_ssm'][1]
  end

  def call_number
    @solr_document['call_number_ss']
  end

  def collection
    @solr_document['collection_ssim']&.first
  end

  def title
    @solr_document['title_ssm']&.first
  end

  def location
    @solr_document['collection_offsite_ssi'] == 'true' ? 'Offsite' : self.repository_config&.name
  end

  def form_attributes
    form_fields = {}
    form_fields['Site'] = self.repository_local_request_config['site_code'] if self.repository_local_request_config
    # We intentionally send collection name to the AEON "ItemTitle" field because this was requested by CUL staff.
    form_fields['ItemTitle'] = self.collection
    # NOTE about ItemAuthor field:
    # 1) Some documents may not have a creator_ssim value because we only index creator_ssim on some parent level documents.
    # 2) This might mean that in the future we'll want to extract the parent (or grandparent) container creator at index time.
    # 3) For now, we're not sure if it's useful to send the ItemAuthor data to AEON, so we'll leave this field commented out.
    # form_fields['ItemAuthor'] = @solr_document['creator_ssim']&.first
    form_fields['ItemDate'] = @solr_document['normalized_date_ssm']&.first
    form_fields['ReferenceNumber'] = reference_number
    form_fields['DocumentType'] = 'All'
    form_fields['ItemInfo1'] = 'Archival Materials' # Format/Genre in Aeon
    if self.digital?
      form_fields['ItemInfo3'] = 'DIGITIZED'
    elsif self.unprocessed?
      form_fields['ItemInfo3'] = 'UNPROCESSED'
    end
    # The UserReview field controls whether or not the request is directly submitted for processing
    # or is instead saved in a user’s Aeon account for submission at a later date.
    form_fields['UserReview'] = (repository_local_request_config && repository_local_request_config['user_review'].to_s == 'false') ? 'No' : 'Yes'
    # Labeled "Box / Volume" in AEON
    form_fields['ItemVolume'] = self.box_or_highest_requestable_level_label
    # Labeled "Barcode" in AEON
    form_fields['ItemNumber'] = self.barcode
    # "ItemSubTitle" is labeled "Series" in AEON.
    # We intentionally send the item title to the AEON "ItemSubTitle" field because this was requested by CUL staff.
    form_fields['ItemSubTitle'] = title
    # Labeled "Call Number" in AEON
    form_fields['CallNumber'] = self.call_number
    # This is different from the site code, and generally formatted as full library name like "Rare Book and Manuscript Library".
    form_fields['Location'] = self.location

    form_fields
  end
end
