# frozen_string_literal: true

module Acfa::Arclight
  class BreadcrumbsHierarchyComponent < Arclight::BreadcrumbsHierarchyComponent
    def repository
      return tag.span(t('arclight.show_breadcrumb_label')) if document.repository_config.blank?

      link_to(document.repository_config.name, helpers.repository_entry_url(document.repository_config.slug))
    end
  end
end