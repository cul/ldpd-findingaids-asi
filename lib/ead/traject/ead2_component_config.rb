# frozen_string_literal: true

require 'traject'
require_relative 'ead2_shared'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

load_config_file "#{Arclight::Engine.root}/lib/arclight/traject/ead2_component_config.rb"

settings do
  # provide 'root' # the root EAD collection indexing context
  # provide 'parent' # the immediate parent component (or collection) indexing context
  # provide 'counter' # a global component counter to provide a global sort order for nested components
  # provide 'depth' # the current nesting depth of the component
  provide 'component_traject_config', __FILE__
end

to_field 'repository_id_ssi' do |record, accumulator, context|
  if settings[:root]&.clipboard
    repository_id = settings[:root].clipboard[:repository_id]
    accumulator.concat([repository_id]) if repository_id
  end
end

@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['date_range_isim'].include?(index_step.field_name) }

to_field 'date_range_isim', extract_xpath('./did/unitdate/@normal', to_text: false) do |_record, accumulator|
  range = Arclight::YearRange.new
  next range.years if accumulator.blank?

  ranges = accumulator.map(&:to_s)
  ranges.delete_if { |range| range =~ /\/9999/ && range != '9999/9999' }
  if ranges.blank?
    accumulator.replace [ranges]
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

@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['language_ssim'].include?(index_step.field_name) }
to_field 'language_material_ssm', extract_xpath('./did/langmaterial')
to_field 'language_ssim', extract_xpath('./did/langmaterial/language')

to_field 'collection_sort' do |_rec, accumulator, _context|
  accumulator.concat((settings[:root].output_hash['normalized_title_ssm'] || []).slice(0,1))
end

# Get the <accessrestrict> from the closest ancestor that has one (includes top-level)
@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['parent_access_restrict_tesm'].include?(index_step.field_name) }
to_field 'parent_access_restrict_tesm' do |record, accumulator|
  accumulator.concat Array
    .wrap(record.xpath('(./ancestor::*[accessrestrict])[last()]/accessrestrict/*[local-name()!="head"]')
    .map(&:text))
end

# Extract call number, which is the first did/unitit that is NOT all-numeric
to_field 'call_number_ss', extract_xpath('/ead/archdesc/did/unitid[translate(., "0123456789", "")][not(@type)]'), first_only

to_field "container_information_ssm" do |record, accumulator, context|
  record.xpath("./did/container").each do |container_element|
    type = container_element.attributes["type"].to_s
    barcode_label = container_element.attributes["label"].to_s
    barcode_match = barcode_label.match(/\[([^\]]+)\]/)
    barcode = barcode_match[1] if barcode_match
    text = [container_element.attribute("type"), container_element.text].join(" ").strip
    container_information = {
      id: container_element.attributes["id"].to_s.gsub("aspace_", ""),
      barcode: barcode,
      label: text,
      parent: container_element.attribute("parent").to_s.gsub("aspace_", ""),
      type: type
    }
    accumulator << container_information.to_json
  end
end

to_field "aeon_unprocessed_ssi", extract_xpath("/ead/archdesc/accessrestrict") do |_record, accumulator|
  unprocessed_regex = /vetted|unprocessed/i
  accumulator.replace([accumulator.map {|value| value.match(unprocessed_regex) }.any?])
end

to_field "collection_offsite_ssi", extract_xpath("/ead/archdesc/accessrestrict") do |_record, accumulator|
  offsite_regex = /off[\s-]?site/i
  accumulator.replace([accumulator.map {|value| value.match(offsite_regex) }.any?])
end

to_field "aeon_unavailable_for_request_ssi", extract_xpath("./accessrestrict/p") do |_record, accumulator|
  unavailable_for_request = /restricted|closed|missing/i
  accumulator.replace([accumulator.map {|value| value.match(unavailable_for_request) }.any?])
end

# delete upstream digital_objects_ssm rule because we need to override
@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['digital_objects_ssm'].include?(index_step.field_name) }

to_field 'digital_objects_ssm' do |record, accumulator, context|
  record.xpath('./daogrp/daoloc|./did/daogrp/daoloc').each do |daoloc|
    href = (daoloc.attributes['href'] || daoloc.attributes['xlink:href'])&.value
    next unless href && href =~ /^http/
    label = daoloc.parent.attributes['title']&.text ||
            daoloc.parent.attributes['xlink:title']&.text ||
            daoloc.xpath('./parent::daogrp/daodesc/p')&.text
    role = (daoloc.attributes['role'] || daoloc.attributes['xlink:role'])&.value
    type = (daoloc.attributes['type'] || daoloc.attributes['xlink:type'])&.value
    accumulator << Acfa::DigitalObject.new(label: label, href: href, role: role, type: type).to_json
  end
  record.xpath('./dao|./did/dao').each do |dao|
    href = (dao.attributes['href'] || dao.attributes['xlink:href'])&.value
    next unless href && href =~ /^http/
    label = dao.attributes['title']&.value ||
            dao.attributes['xlink:title']&.value ||
            dao.xpath('daodesc/p')&.text
    role = (dao.attributes['role'] || dao.attributes['xlink:role'])&.value
    type = (dao.attributes['type'] || dao.attributes['xlink:type'])&.value
    accumulator << Acfa::DigitalObject.new(label: label, href: href, role: role, type: type).to_json
  end
end

@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['extent_ssm'].include?(index_step.field_name) }

to_field 'extent_ssm' do |record, accumulator|
  # Add each physdesc separately to the accumulator
  accumulator.concat(extents_per_physdesc(record.xpath('./did/physdesc')))
end

# include digital objects with multiple file versions
@index_steps.delete_if { |index_step| index_step.is_a?(ToFieldStep) && ['has_online_content_ssim'].include?(index_step.field_name) }
to_field 'has_online_content_ssim', extract_xpath('.//dao|.//daogrp') do |_record, accumulator|
  accumulator.replace([accumulator.any?])
end
