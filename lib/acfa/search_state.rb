# frozen_string_literal: true

module Acfa
  # This class extends the blacklight search state only
  # to link search results to legacy views of finding aids
  class SearchState < Blacklight::SearchState
    SERIES = /^\s*Series/
    ROMAN_SERIES = /^\s*Series ([clxvi]+)\:/i
    ARABIC_SERIES = /^\s*Series ([\d]+)\:/i

    def url_for_document(doc, options = {})

      if doc['aspace_path_ssi'] && (doc_repo = ::Arclight::Repository.find_by(slug: doc['repository_id_ssi']))&.attributes.fetch('aspace_base_uri', nil)
        return doc['aspace_path_ssi'] if doc['aspace_path_ssi'].starts_with?('http')

        File.join(doc_repo.aspace_base_uri, doc['aspace_path_ssi'])
      else
        super
      end
    end

    def self.series_to_dsc(unit_titles)
      return nil unless unit_titles

      series_title = unit_titles.detect { |title| title =~ SERIES }
      return nil unless series_title

      if (match = ROMAN_SERIES.match(series_title))
        roman_to_arabic(match[1])
      elsif (match = ARABIC_SERIES.match(series_title))
        match[1].to_i
      end
    end

    def self.roman_to_arabic(roman)
      roman = roman.upcase
      arabic = 0
      while roman[-1] && roman[-1] == 'I'
        arabic += 1
        roman = roman.slice(0..-2)
      end
      while roman[-1] && roman[-1] == 'V'
        arabic += 5
        roman = roman.slice(0..-2)
      end
      while roman[-1] && roman[-1] =~ /[IX]/
        arabic -= 1 if roman[-1] == 'I'
        arabic += 10 if roman[-1] == 'X'
        roman = roman.slice(0..-2)
      end
      while roman[-1] && roman[-1] =~ /[LIX]/
        arabic -= 1 if roman[-1] == 'I'
        arabic -= 10 if roman[-1] == 'X'
        arabic += 50 if roman[-1] == 'L'
        roman = roman.slice(0..-2)
      end
      while roman[-1] && roman[-1] =~ /[CLIX]/
        arabic -= 1 if roman[-1] == 'I'
        arabic -= 10 if roman[-1] == 'X'
        arabic -= 50 if roman[-1] == 'L'
        arabic += 100 if roman[-1] == 'C'
        roman = roman.slice(0..-2)
      end
      while roman[-1] && roman[-1] =~ /[DCLIX]/
        arabic -= 1 if roman[-1] == 'I'
        arabic -= 10 if roman[-1] == 'X'
        arabic -= 50 if roman[-1] == 'L'
        arabic -= 100 if roman[-1] == 'C'
        arabic += 500 if roman[-1] == 'D'
        roman = roman.slice(0..-2)
      end
      while roman[-1] && roman[-1] =~ /[MDCLIX]/
        arabic -= 1 if roman[-1] == 'I'
        arabic -= 10 if roman[-1] == 'X'
        arabic -= 50 if roman[-1] == 'L'
        arabic -= 100 if roman[-1] == 'C'
        arabic -= 500 if roman[-1] == 'D'
        arabic += 1000 if roman[-1] == 'M'
        roman = roman.slice(0..-2)
      end

      arabic
    end
  end
end