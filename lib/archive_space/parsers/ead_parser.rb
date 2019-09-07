module ArchiveSpace
  module Parsers
    class EadParser
      class << self
        def parse(xml_input, recover_mode = false)
          if recover_mode
            # The RECOVER parse option is set by default, where Nokogiri will attempt to recover from errors
            nokogiri_xml = Nokogiri::XML(xml_input)
          else
            # turn RECOVER parse option off. Will throw a Nokogiri::XML::SyntaxError if parsing error encountered
            nokogiri_document = Nokogiri::XML(xml_input) do |config|
              config.norecover
            end
          end
          nokogiri_document
        end
      end
    end
  end
end
