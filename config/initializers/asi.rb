CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/finding_aids.yml")[Rails.env]).freeze
# REPOS contains info about the individual repositories, for example if aeon is used or not.
# REPOS is indexed by the repository ID used by ArchiveSpace to indentify the individual repository.
REPOS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/repositories.yml", aliases: true)[Rails.env]).freeze