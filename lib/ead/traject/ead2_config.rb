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

def normalize_repository_id(mainagencycode, record)
  code = mainagencycode.sub(/^US-/, '').downcase
  case code
  when 'nnc-av'
    return 'nnc-a'
  when 'nnc-rb'
    if record.xpath('/ead/archdesc[@level=\'collection\']/did/unitid').detect {|x| x.text =~ /^UA/}
      return 'nnc-ua'
    else
      return 'nnc-rb'
    end
  when ''
    return 'nnc'
  else
    return code
  end
end

each_record do |record, context|
  context.clipboard[:repository_id] ||= normalize_repository_id(record.xpath('/ead/eadheader/eadid/@mainagencycode').text, record)
  if context.clipboard[:repository_id].present? && REPOS[context.clipboard[:repository_id]]
    context.clipboard[:repository] ||= Repository.find(context.clipboard[:repository_id]).name
  else
    context.skip!
  end
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
  accumulator.concat([context.clipboard[:repository_id]])
end

@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['date_range_ssim'].include?(index_step.field_name) }

to_field 'date_range_ssim', extract_xpath('/ead/archdesc/did/unitdate/@normal', to_text: false) do |_record, accumulator|
  range = Arclight::YearRange.new
  next range.years if accumulator.blank?

  ranges = accumulator.map(&:to_s)
  ranges.delete_if { |range| range =~ /\/9999/ && range != '9999/9999' }
  if ranges.blank?
    accumulator.replace ranges
    next range.years
  end
  range << range.parse_ranges(ranges)
  accumulator.replace range.years
end

to_field 'date_range_isim', extract_xpath('/ead/archdesc/did/unitdate/@normal', to_text: false) do |_record, accumulator|
  range = Arclight::YearRange.new
  next range.years if accumulator.blank?

  ranges = accumulator.map(&:to_s)
  ranges.delete_if { |range| range =~ /\/9999/ && range != '9999/9999' }
  if ranges.blank?
    accumulator.replace ranges
    next range.years
  end
  range << range.parse_ranges(ranges)
  accumulator.replace range.years
end


