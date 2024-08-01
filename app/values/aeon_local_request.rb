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

  def form_attributes
    # series_num, component_title, container_info_string, container_info_barcode =
    #   container_info.split(CONFIG[:container_info_delimiter])



    puts repository_config.inspect
    puts repository_local_request_config.inspect

    form_fields = {}
    form_fields['GroupingField'] = grouping_field(@solr_document.containers)
    form_fields['Site'] = self.repository_local_request_config['site_code']
    # NOTE: We might need to truncate this field later on if values are too long
    form_fields['ItemTitle'] = @solr_document['title_ssm']&.first
    # NOTE: Some documents may not have a creator because they're meant to inherit creator from a parent container document.
    # NOTE: This might mean that in the future we'll want to extract the parent (or grandparent) container creator at index time.
    form_fields['ItemAuthor'] = @solr_document['creator_ssim']&.first
    form_fields['ItemDate'] = @solr_document['normalized_date_ssm']&.first
    form_fields['ReferenceNumber'] = reference_number
    form_fields['DocumentType'] = 'All'
    form_fields['ItemInfo1'] = 'Archival Materials' # Format/Genre in Aeon
    form_fields['ItemInfo3'] = 'UNPROCESSED' if self.unprocessed?
    # The UserReview field controls whether or not the request is directly submitted for processing
    # or is instead saved in a user’s Aeon account for submittal at a future date.
    form_fields['UserReview'] = repository_local_request_config.fetch('user_review', false)

    # The container_info_string is already in solr, and is an array that we can break apart for some of fields below

    # form_fields['ItemVolume'] = container_info_string, # Box number, in solr already, TODO: Check field name

    # This is the barcode -- where does this come from in solr? (maybe we need to index it?)
    # form_fields['ItemNumber'] = container_info_barcode, if container_info_barcode

    # form_fields['ItemSubTitle']  component_title.prepend(@series_titles[series_num]),
    # form_fields['CallNumber'] = @call_number, # We can extract call number from EAD and add to solr (note: this is NOT the bib id)
    # This is different from the site code, and generally formatted as full library name liek "Rare Book and Manuscript Library"  As an example, these are formatted like "gax" (for graphic arts).

    # Probably look at repository.name (example: "C.V. Starr East Asian Library")
    # form_fields['Location'] = @location

    form_fields

    # <%= hidden_field_tag :Site, @aeon_site_code %>
    # <% @selected_containers.each_with_index do |container_info, index| %>
    #   <% series_num, component_title, container_info_string, container_info_barcode =
    #       container_info.split(CONFIG[:container_info_delimiter]) %>
    #   <%= hidden_field_tag :Request, "request_#{index}" %>
    #   <%= hidden_field_tag "ItemVolume_request_#{index}", container_info_string %>
    #   <%= hidden_field_tag("ItemNumber_request_#{index}", container_info_barcode) if container_info_barcode %>
    #   <%= hidden_field_tag "ItemTitle_request_#{index}", @item_title %>
    #   <%= hidden_field_tag "ItemAuthor_request_#{index}", @author %>
    #   <%= hidden_field_tag "ItemDate_request_#{index}", @item_date %>
    #   <%= hidden_field_tag "ItemSubTitle_request_#{index}", component_title.prepend(@series_titles[series_num]) %>
    #   <%= hidden_field_tag "ReferenceNumber_request_#{index}", @bib_id %>
    #   <%= hidden_field_tag "CallNumber_request_#{index}", @call_number %>
    #   <%= hidden_field_tag "Location_request_#{index}", @location %>
    #   <%= hidden_field_tag "DocumentType_request_#{index}", 'All' %>
    #   <%= hidden_field_tag "ItemInfo1_request_#{index}", 'Archival Materials' %>
    # <% end %>
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
