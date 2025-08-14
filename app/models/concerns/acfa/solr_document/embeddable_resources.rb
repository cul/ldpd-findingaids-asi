# Embeddable resources include digital objects that can be embedded in the UI, such as IIIF manifests or HathiTrust digital objects.
module Acfa::SolrDocument::EmbeddableResources
  def embeddable?(object)
    return true if object.role =~ /iiif-manifest/
    include_patterns.any? do |pattern|
      puts "Checking embeddable for object with href: #{object.href} against pattern"
      object.href =~ pattern
    end
  end

  # Override of parent class, which only selects the first resource
  # @see https://github.com/projectblacklight/arclight/blob/v1.1.4/app/components/arclight/embed_component.rb
  def embeddable_resources
    resources&.select { |object| embeddable?(object) } || []
  end

  # IIF manifests include DOI and Internet Archive resources
  def embeddable_resources_iiif_manifests
    @embeddable_resources_iiif_manifests ||= begin
      iiif_manifests = embeddable_resources.map { |r| manifest_for(r, false) }.compact
      if iiif_manifests.empty?
        iiif_manifests.concat embeddable_resources.map { |r| manifest_for(r, true) }.compact
      end
      iiif_manifests
    end
  end

  # Hathi resources are not IIIF manifests, but can be embedded
  def embeddable_hathi_resources
    @embeddable_hathi_resources ||= embeddable_resources.select do |r|
      r.href.include?('hdl.handle.net') && r.role != 'iiif-manifest'
    end
  end

  # DOI or Internet Archive or HathiTrust
  def include_patterns
    [/\/(10\.7916\/[A-Za-z0-9\-\.]+)/, /\/\/archive\.org\/details\//, /\/\/hdl\.handle\.net\//]
  end

  def manifest_for(object, permissive = true)
    return object.href if object.role =~ /iiif-manifest/
    return unless permissive

    return doi_manifest(object.href) if object.href =~ /\/10\.7916\//
    return ia_manifest(object.href) if object.href =~ /\/\/archive\.org\//
  end

  def doi_manifest(href)
    doi = /\/(10\.7916\/[A-Za-z0-9\-\.]+)/.match(href)[1]
    "#{CONFIG[:mirador_base_url]}/iiif/3/presentation/#{doi}/manifest"
  end

  def ia_manifest(href)
    ia_id = href.split("archive.org/details/").last&.split('/')
    ia_id = ia_id&.first
    "https://iiif.archive.org/iiif/3/#{ia_id}/manifest.json" if ia_id
  end
end