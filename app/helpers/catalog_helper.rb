# frozen_string_literal: true

module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # Override Blacklight's render_search_to_page_title_filter to fix an issue where
  # facet_configuration_for_field fails to find the config when the Blacklight
  # facet key (e.g. 'repository') differs from the Solr field name (e.g.
  # 'repository_id_ssi'). This causes helper_method (like :repository_label)
  # to be ignored in the page <title>, showing repository slugs instead of full names.
  def render_search_to_page_title_filter(facet, values)
    facet_config = blacklight_config.facet_fields[facet] || facet_configuration_for_field(facet)
    filter_label = facet_field_label(facet_config.key)
    filter_value = if values.size < 3
                     values.map { |value| facet_item_presenter(facet_config, value, facet).label }.to_sentence
                   else
                     t('blacklight.search.page_title.many_constraint_values', values: values.size)
                   end
    t('blacklight.search.page_title.constraint', label: filter_label, value: filter_value)
  end
end