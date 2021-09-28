# Following class describes the EAD element <physdesc> Physical Description
# (https://www.loc.gov/ead/tglib/elements/physdesc.html)
# and supplies class methods to retrieve pertinent child elements

module Ead
  module Elements
    class Bibliography

      XPATH = {
        head: './xmlns:head',
        bibref_title: './xmlns:bibref/xmlns:title',
        p: './xmlns:p'
      }.freeze

      class << self
        # returns: Nokogiri::XML::NodeSet of <head>
        # <head> Heading
        def head_node_set(input_element)
          input_element.xpath(XPATH[:head])
        end
        # returns: Nokogiri::XML::NodeSet of <title> direct childs of <bibref>
        # <bibref><title>
        # <bibref> Bibliographic Reference
        # <title> Title
        def bibref_title_node_set(input_element)
          input_element.xpath(XPATH[:bibref_title])
        end
        # returns: Nokogiri::XML::NodeSet of <p>
        # <p> Paragraph
        def p_node_set(input_element)
          input_element.xpath(XPATH[:p])
        end
      end
    end
  end
end
