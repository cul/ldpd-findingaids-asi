# frozen_string_literal: true

require 'traject'

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

to_field 'callnum_ss', extract_xpath('/ead/archdesc/did/unitid[translate(., "0123456789", "")]')

to_field "container_information_ssm" do |record, accumulator, context|
  record.xpath("./did/container").each do |container_element|
    type = container_element.attributes["type"].to_s
    barcode_label = container_element.attributes["label"].to_s
    barcode_match = barcode_label.match(/\[(\d+?)\]/)
    barcode = barcode_match[1] if barcode_match
    text = [container_element.attribute("type"), container_element.text].join(" ").strip
    accumulator << {
      id: container_element.attributes["id"].to_s.gsub("aspace_", ""),
      barcode: barcode,
      label: text,
      parent: container_element.attribute("parent").to_s.gsub("aspace_", ""),
      type: type
    }.to_json
  end
end
