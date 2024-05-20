module ApplicationHelper
  include Blacklight::LocalePicker::LocaleHelper

  def additional_locale_routing_scopes
    [blacklight, arclight_engine]
  end

  def has_breadcrumbs?
    detected = false
    breadcrumbs.tap { |links| detected = links.any? }
    detected
  end

  def repository_entry_url(repository_slug, **opts)
    search_action_url(f: { repository: [repository_slug] }, **opts)
  end
end
