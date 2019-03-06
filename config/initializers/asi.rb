ASI_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/archivespace.yml")[Rails.env]).freeze
