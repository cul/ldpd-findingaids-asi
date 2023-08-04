require 'arclight'

class Arclight::Repository
  def id
    self.slug
  end

  def contact
    attributes[:contact]
  end

  def location
    attributes[:location]
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
