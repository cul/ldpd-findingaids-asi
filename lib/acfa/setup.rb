module Acfa
  module Setup
    def self.configuration(root_dir, force: false)
      Dir.glob(File.join(root_dir, "config/templates/*.template.yml")).each do |template_yml_path|
        target_yml_path = File.join(root_dir, 'config', File.basename(template_yml_path).sub(".template.yml", ".yml"))
        next if File.exist?(target_yml_path) && !force
        FileUtils.touch(target_yml_path) # Create if it doesn't exist
        target_yml = YAML.load_file(target_yml_path, aliases: true) || YAML.load_file(template_yml_path, aliases: true)
        File.open(target_yml_path, 'w') {|f| f.write target_yml.to_yaml }
      end
      Dir.glob(File.join(root_dir, "config/templates/*.template.yml.erb")).each do |template_yml_path|
        target_yml_path = File.join(root_dir, 'config', File.basename(template_yml_path).sub(".template.yml.erb", ".yml"))
        next if File.exist?(target_yml_path) && !force
        FileUtils.touch(target_yml_path) # Create if it doesn't exist
        target_yml = YAML.load_file(target_yml_path, aliases: true) || YAML.load(ERB.new(File.read(template_yml_path)).result(binding), aliases: true)
        File.open(target_yml_path, 'w') {|f| f.write target_yml.to_yaml }
      end
    end

    def self.ead_fixtures(root_dir, force: false)
      ead_sample_fixture_dir = File.join(root_dir, 'test/fixtures/files/ead-sample-data')
      ead_fixture_dir = File.join(root_dir, 'test/fixtures/files/ead')
      FileUtils.mkdir_p(ead_fixture_dir)
      Dir.glob("#{ead_sample_fixture_dir}/*.xml").each do |ead_fixture_file|
        target_file_path = File.join(ead_fixture_dir, File.basename(ead_fixture_file))
        next if File.exist?(target_file_path) && !force
        puts "Creating fixture file: #{target_file_path}"
        FileUtils.cp(ead_fixture_file, target_file_path)
      end
    end
  end
end
