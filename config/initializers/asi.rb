require 'clio/bib_ids'
CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/finding_aids.yml")[Rails.env]).freeze
AS_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/archivespace.yml")[Rails.env]).freeze
# REPOS contains info about the individual repositories, for example if aeon is used or not.
# REPOS is indexed by the repository ID used by ArchiveSpace to indentify the individual repository.
REPOS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/repositories.yml", aliases: true)[Rails.env]).freeze
AEON = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/aeon.yml")[Rails.env]).freeze
FileUtils.mkdir_p(CONFIG[:ead_cache_dir]) unless File.directory?(CONFIG[:ead_cache_dir])
FileUtils.mkdir_p(CONFIG[:html_cache_dir]) unless File.directory?(CONFIG[:html_cache_dir])
