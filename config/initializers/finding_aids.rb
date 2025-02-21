CONFIG = HashWithIndifferentAccess.new(Rails.application.config_for(:finding_aids))
# REPOS contains info about the individual repositories, for example if aeon is used or not.
# REPOS is indexed by the repository ID used by ArchiveSpace to indentify the individual repository.
REPOS = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/repositories.yml", aliases: true)[Rails.env]).freeze
AEON = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/aeon.yml", aliases: true)[Rails.env]).freeze
ARCHIVESSPACE = HashWithIndifferentAccess.new(Rails.application.config_for(:archivesspace))
