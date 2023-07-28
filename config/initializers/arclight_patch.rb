require 'arclight'

class Arclight::Repository
  # Override to pull repository configs from an environment keyed top-level hash
  def self.from_yaml(file)
    repos = {}
    data = YAML.safe_load(File.read(file))[Rails.env]
    data.each_key do |slug|
      repos[slug] = new(data[slug].merge(slug: slug))
    end
    repos
  end
end
