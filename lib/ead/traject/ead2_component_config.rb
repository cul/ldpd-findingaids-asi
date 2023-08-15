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

to_field 'date_range_isim', extract_xpath('./did/unitdate/@normal', to_text: false) do |_record, accumulator|
  range = Arclight::YearRange.new
  next range.years if accumulator.blank?

  ranges = accumulator.map(&:to_s)
  range << range.parse_ranges(ranges)
  accumulator.replace range.years
end
