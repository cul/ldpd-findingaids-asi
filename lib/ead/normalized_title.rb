# frozen_string_literal: true

# Override Arclight::NormalizedTitle to condense consecutive whitespace in the title
module ArclightOverrides
  # A utility class to normalize titles, typically by joining
  # the title and date, e.g., "My Title, 1990-2000"
  class NormalizedTitle < Arclight::NormalizedTitle
    # @param [String] `title` from the `unittitle`
    # @param [String] `date` from the `unitdate`
    def initialize(title, date = nil)
      if title.present?
        title_with_normalized_spaces = title.gsub(/\s{2,}/, ' ')
        title_without_trailing_comma = title_with_normalized_spaces.gsub(/\s*,\s*$/, '')
        @title = title_without_trailing_comma.strip
      end

      @date = date.strip if date.present?
    end
  end
end