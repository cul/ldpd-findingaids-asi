# Following class describes the EAD element <did>
# (see https://www.loc.gov/ead/tglib/elements/did.html)
# and supplies class methods to retrieve child elements
# of the <did>

module Ead
  module Elements
    class Controlaccess

      XPATH = {
        corpname: './xmlns:corpname',
        genreform: './xmlns:genreform',
        occupation: './xmlns:occupation',
        persname: './xmlns:persname',
        subject: './xmlns:subject',
      }.freeze

      class << self
        # returns: array of Nokogiri::XML::Element instances for <<corpname> Corporate Namet>
        # <corpname> Corporate Name<corpname> Corporate Name
        def corpname_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:corpname])
        end

        # returns: array of Nokogiri::XML::Element instances for <genreform>
        # <genreform> Genre/Physical Characteristic
        def genreform_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:genreform])
        end

        # returns: array of Nokogiri::XML::Element instances for <occupation>
        # <occupation> Occupation
        def occupation_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:occupation])
        end

        # returns: array of Nokogiri::XML::Element instances for <persname>
        # <persname> Personal Name
        def persname_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:persname])
        end

        # returns: array of Nokogiri::XML::Element instances for <subject>
        # <subject> Subject
        def subject_array(nokogiri_element)
          nokogiri_element.xpath(XPATH[:subject])
        end
      end
    end
  end
end
