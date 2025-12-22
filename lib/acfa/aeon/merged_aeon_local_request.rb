# Groups solr documents into groups for Aeon,
class Acfa::Aeon::MergedAeonLocalRequest
  DEFAULT_DELIMETER = '; '

  MERGE_RULES = {
    'Site' => :first,
    'ItemTitle' => :first,
    # 'ItemAuthor' => DEFAULT_DELIMETER, # This is commented out because we're not currently sending ItemAuthor to Aeon
    'ItemDate' => DEFAULT_DELIMETER,
    'ReferenceNumber' => :first,
    'DocumentType' => :first,
    'ItemInfo1' => :first,
    'ItemInfo3' => :first,
    'UserReview' => :first,
    'ItemVolume' => :first,
    # Every box should have one barcode, so it's fine to use the first value only
    'ItemNumber' => :first,
    # It's possible, but infrequent, for two items in the same box to have different
    # ItemSubTitle (a.k.a. "series") values, so to keep our Aeon submission cleaner
    # (to avoid concatenating and repeating the same series over and over) we're only
    # going to send the first one.
    'ItemSubTitle' => DEFAULT_DELIMETER,
    # Call number is at the collection level, so first value is fine here
    'CallNumber' => :first,
    # All items in the same box are from the same repository, so first value is fine here
    'Location' => :first,
    'TopContainerID' => :first
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
