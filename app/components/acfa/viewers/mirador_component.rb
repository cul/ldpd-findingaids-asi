# frozen_string_literal: true

module Acfa::Viewers
  # Display the document hierarchy as "breadcrumbs"
  class MiradorComponent < Arclight::EmbedComponent
    attr_accessor :document

    def embeddable?(object)
      include_patterns.any? do |pattern|
        object.href =~ pattern
      end
    end

    def include_patterns
      [/\/(10\.7916\/[A-Za-z0-9\-\.]+)/, /\/\/archive\.org\/details\//]
    end

    def manifest_for(object)
      return doi_manifest(object.href) if object.href =~ /\/10\.7916\//
      return ia_manifest(object.href) if object.href =~ /\/\/archive\.org\//
    end

    def doi_manifest(href)
      doi = /\/(10\.7916\/[A-Za-z0-9\-\.]+)/.match(href)[1]
      "https://dlc-staging.library.columbia.edu/iiif/3/presentation/#{doi}/manifest"
    end

    def ia_manifest(href)
      ia_id = href.split("archive.org/details/").last&.split('/')
      ia_id = ia_id&.first
      "https://iiif.archive.org/iiif/2/#{ia_id}/manifest.json" if ia_id
    end
  end
end