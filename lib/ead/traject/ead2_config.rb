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
require_relative 'ead2_shared'

# Arclight::Repository expects repositories.yml not to have environment keys
# so we must monkey patch
require 'arclight/repository'
load_config_file "app/overrides/arclight/repository_override.rb"

settings do
  provide 'component_traject_config', File.join(__dir__, 'ead2_component_config.rb')
end

def normalize_repository_id(mainagencycode, record)
  code = mainagencycode.sub(/^US-/, '').downcase
  case code
  when 'nnc-av'
    return 'nnc-a'
  when 'nnc-oh'
    return 'nynycoh'
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
    logger.warn "no repository config found for code '#{context.clipboard[:repository_id]}'; skipping #{settings['command_line.filename']}"
    context.skip!
  end
end

load_config_file "#{Arclight::Engine.root}/lib/arclight/traject/ead2_config.rb"

extend TrajectPlus::Macros

to_field 'collection_sort' do |_record, accumulator, context|
  accumulator.concat context.output_hash.fetch('normalized_title_ssm', []).slice(0,1)
end

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
    ead_id.sub!(/^ldpd_/,'')
    ead_id.gsub!(/[^A-Za-z0-9]/,'-')
    if ead_id
      if ead_id =~ /^(in)?\d/
        accumulator.concat ["cul-#{ead_id}"]
      else
        accumulator.concat [ead_id]
      end
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

@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['date_range_isim'].include?(index_step.field_name) }


to_field 'date_range_isim', extract_xpath('/ead/archdesc/did/unitdate/@normal', to_text: false) do |_record, accumulator|
  range = Arclight::YearRange.new
  next range.years if accumulator.blank?

  ranges = accumulator.map(&:to_s)
  ranges.delete_if { |range| range =~ /\/9999/ && range != '9999/9999' }
  if ranges.blank?
    accumulator.replace ranges
    next range.years
  end
  begin
    range << ranges.map do |date|
      range.parse_range(date)
    rescue ArgumentError
      nil
    end.compact.flatten.sort.uniq
  end
  years = range.years
  if years.blank? || (years.max - years.min) > 1000
    accumulator.replace []
    next []
  end
  accumulator.replace years
end

to_field 'aspace_path_ssi', extract_xpath('/ead/archdesc/did/unitid[@type = \'aspace_uri\']') do |_record, accumulator|
  accumulator.slice!(1..-1)
  accumulator
end

@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['language_ssim'].include?(index_step.field_name) }
to_field 'language_material_ssm', extract_xpath('/ead/archdesc/did/langmaterial')
to_field 'language_ssim', extract_xpath('/ead/archdesc/did/langmaterial/language')

# delete upstream digital_objects_ssm rule
# this is not present in ASpace exports and is further overridden in ead2_component_config.rb
@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['digital_objects_ssm'].include?(index_step.field_name) }

@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['extent_ssm'].include?(index_step.field_name) }

to_field 'extent_ssm' do |record, accumulator|
  # Add each physdesc separately to the accumulator
  accumulator.concat(extents_per_physdesc(record.xpath('/ead/archdesc/did/physdesc')))
end

to_field 'call_number_ss', extract_xpath('/ead/archdesc/did/unitid[translate(., "0123456789", "")][not(@type)]'), first_only

to_field 'bibid_ss', extract_xpath('/ead/archdesc/did/unitid[translate(., "0123456789", "") = ""]'), first_only

# include digital objects with multiple file versions
@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['has_online_content_ssim'].include?(index_step.field_name) }
to_field 'has_online_content_ssim', extract_xpath('.//dao|.//daogrp') do |_record, accumulator|
  accumulator.replace([accumulator.any?])
end

