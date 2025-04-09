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
  
  def clio_link(args)
    bibid = args[:value]&.first
    "<a href=\"https://clio.columbia.edu/catalog/#{bibid}\" class=\"external-link\">View in CLIO</a>".html_safe
  end

end
