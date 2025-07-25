Arclight::Repository.class_eval do
  def id
    attributes[:id] || self.slug
  end

  # override for more structured contact info than an html blob
  def contact
    attributes[:contact]
  end

  # override for more structured contact info than an html blob
  def location
    attributes[:location]
  end

  # local method
  def exclude_from_home?
    @attributes[:exclude_from_home]
  end

  # local method
  def aeon_enabled?
    @attributes.dig(:request_types, :aeon_local_request).present?
  end

  # local method
  def aeon_site_code
    @attributes.dig(:request_types, :aeon_local_request, :site_code)
  end

  # local method
  def aeon_user_review_set_to_yes?
    @attributes.dig(:request_types, :aeon_local_request, :user_review)
  end

  # Override to pull repository configs from an environment keyed top-level hash
  def self.from_yaml(file)
    repos = {}
    data = YAML.safe_load(File.read(file), aliases: true)[Rails.env]
    data.each_key do |slug|
      repos[slug] = new(data[slug].merge(slug: slug))
    end
    repos
  end
end
