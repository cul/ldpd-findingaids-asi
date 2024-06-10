# frozen_string_literal: true

# This class should be used to turn configuration into a URL and
# POST form specifically aimed at Aeon's external request
# endpoint (https://support.atlas-sys.com/hc/en-us/articles/360011820054-External-Request-Endpoint)
class AeonLocalRequest
  def initialize(solr_document)
    @solr_document = solr_document
  end

  def config
    @config ||= @solr_document.repository_config.request_config_for_type('aeon_local_request')
  end

  def unprocessed?
    @solr_document['parent_access_restrict_tesm'].find { |value| value.downcase.include?('unprocessed') } != nil
  end

  def form_attributes
    # I'm not sure that we want to parse EAD XML every time we generate this, but it might be
    # the only way to get all of the fields of information that we need right now.
    # TODO: Look into indexing additional fields, if needed.
    bib_id = @solr_document['id'].delete_prefix('ldpd_').to_i

    # series_num, component_title, container_info_string, container_info_barcode =
    #   container_info.split(CONFIG[:container_info_delimiter])
    form_fields = {}
    form_fields['Site'] = self.config['site_code']
    form_fields['ItemTitle'] = @solr_document['normalized_title_ssm']&.first
    form_fields['ItemAuthor'] = @solr_document['creator_ssim']&.first # Is this correct?
    form_fields['ItemDate'] = @solr_document['normalized_date_ssm']&.first # Is this correct?
    form_fields['ItemDate'] = @solr_document['normalized_date_ssm']&.first # Is this correct?
    form_fields['ReferenceNumber'] = bib_id
    form_fields['DocumentType'] = 'All'
    form_fields['ItemInfo1'] = 'Archival Materials'
    form_fields['ItemInfo1'] = 'UNPROCESSED' if self.unprocessed?

    form_fields

    # 'ItemVolume' => container_info_string,
    # 'ItemNumber' => container_info_barcode, if container_info_barcode
    # 'ItemSubTitle' => component_title.prepend(@series_titles[series_num]),
    # 'CallNumber' => @call_number,
    # 'Location' => @location,

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
