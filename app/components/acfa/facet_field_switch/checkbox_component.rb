# frozen_string_literal: true

module Acfa::FacetFieldSwitch
  class CheckboxComponent < ::Blacklight::FacetItemComponent
    def presenter
      @facet_item
    end

    def render_facet_value
      content_tag(:div, class: "form-check form-switch") do
        concat check_box_tag("toggle-#{presenter.facet_field}", presenter.value, presenter.selected?,
          id: "toggle-#{presenter.facet_field}", class: "form-check-input", type: "checkbox", role: "switch",
          data: { href: href }, onchange: "window.location = this.dataset.href;"
        )
        label = label_tag("toggle-#{presenter.facet_field}", class: "form-check-label", for: "toggle-#{presenter.facet_field}") do
          concat content_tag(:span, presenter.label, class: "facet-label ps-0")
          concat content_tag(:span, t('blacklight.search.facets.count', number: number_with_delimiter(presenter.hits)), class: "facet-count")
        end
        concat(label)
      end
    end

    def render_selected_facet_value
      content_tag(:div, class: "form-check form-switch selected") do
        concat check_box_tag("toggle-#{presenter.facet_field}", presenter.value, presenter.selected?,
          id: "toggle-#{presenter.facet_field}", class: "form-check-input", type: "checkbox", role: "switch",
          data: { href: href }, onchange: "window.location = this.dataset.href;"
        )
        label = label_tag("toggle-#{presenter.facet_field}", class: "form-check-label", for: "toggle-#{presenter.facet_field}") do
          concat content_tag(:span, presenter.label, class: "facet-label ps-0")
          concat content_tag(:span, t('blacklight.search.facets.count', number: number_with_delimiter(presenter.hits)), class: "facet-count")
        end
        concat(label)
      end
    end
  end
end