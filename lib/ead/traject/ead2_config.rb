# frozen_string_literal: true

require 'logger'
require 'traject'
require 'traject/nokogiri_reader'
require 'traject_plus'
require 'traject_plus/macros'
require 'arclight/level_label'
require 'arclight/normalized_date'
require 'arclight/normalized_title'
require 'active_model/conversion' ## Needed for Arclight::Repository
require 'active_support/core_ext/array/wrap'
require 'arclight/digital_object'
require 'arclight/year_range'

# Arclight::Repository expects repositories.yml not to have environment keys
# so we must monkey patch
require 'arclight/repository'
load_config_file "config/initializers/arclight_patch.rb"

settings do
  provide 'component_traject_config', File.join(__dir__, 'ead2_component_config.rb')
end

each_record do |_record, context|
  context.clipboard[:repository_id] = ENV.fetch('REPOSITORY_ID', nil)
end

load_config_file "#{Arclight::Engine.root}/lib/arclight/traject/ead2_config.rb"

extend TrajectPlus::Macros

## Arclight fails hard when indexed components have blank parent IDs, so
## we must catch at index any circumstance where eadid is blank
# to_field 'id', extract_xpath('/ead/eadheader/eadid'), strip, gsub('.', '-')
# to_field 'ead_ssi', extract_xpath('/ead/eadheader/eadid')

def eadid_from_url_or_text(field_name)
  lambda do |record, accumulator, context|
    ead_id = record.xpath('/ead/archdesc/did/unitid[1]').text&.strip
    ead_id = record.xpath('/ead/eadheader/eadid/text()').first&.to_s if ead_id.blank?
    if ead_id.blank?
      ead_url = record.xpath('/ead/eadheader/eadid/@url').first
      ead_id = /ldpd_(\d+)\/?/.match(ead_url.to_s)&.[](1)
    end
    if ead_id
      accumulator.concat ["ldpd_#{ead_id}"]
    else
      logger.warn "no id found; skipping #{settings['command_line.filename']}"
      context.skip!
    end
  end
end

# def create_field_step
#   ToFieldStep.new(field_name, procs, block, Traject::Util.extract_caller_location(caller.first))
# end

# Remove the default arclight eadid and id field definitions and put ours in front of the list
@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['id', 'ead_ssi'].include?(index_step.field_name) }
to_field 'ead_ssi', eadid_from_url_or_text('ead_ssi')
# put the new step at the front
@index_steps.unshift @index_steps.pop
to_field 'id', eadid_from_url_or_text('id'), strip, gsub('.', '-')
# put the new step at the front
@index_steps.unshift @index_steps.pop

to_field 'repository_id_ssi' do |record, accumulator, context|
  accumulator.concat([settings['repository']]) if settings['repository']
end
