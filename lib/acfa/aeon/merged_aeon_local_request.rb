# Groups solr documents into groups for Aeon,
class Acfa::Aeon::MergedAeonLocalRequest
  DEFAULT_DELIMETER = '; '

  MERGE_RULES = {
    'Site' => :first,
    'ItemTitle' => DEFAULT_DELIMETER,
    'ItemAuthor' => DEFAULT_DELIMETER,
    'ItemDate' => DEFAULT_DELIMETER,
    'ReferenceNumber' => DEFAULT_DELIMETER,
    'DocumentType' => :first,
    'ItemInfo1' => :first,
    'ItemInfo3' => DEFAULT_DELIMETER,
    'UserReview' => :first,
    'ItemVolume' => :first,
    'ItemNumber' => :first,
    'ItemSubTitle' => DEFAULT_DELIMETER,
    'CallNumber' => :first,
    'Location' => :first
  }

  def initialize(aeon_local_requests)
    @aeon_local_requests = aeon_local_requests
  end

  def form_attributes
    @form_attributes ||= begin
      combined_form_attributes = {}
      @aeon_local_requests.each do |aeon_local_request|
        aeon_local_request.form_attributes.each do |name, value|
          combined_form_attributes[name] ||= []
          combined_form_attributes[name] << value if value.present?
        end
      end

      # Apply merge rules
      combined_form_attributes.keys.each do |name|
        merge_rule = MERGE_RULES[name]
        if merge_rule == :first
          combined_form_attributes[name] = combined_form_attributes[name].first
        else
          combined_form_attributes[name] = combined_form_attributes[name].join(merge_rule || DEFAULT_DELIMETER)
        end
      end

      combined_form_attributes
    end
  end
end
