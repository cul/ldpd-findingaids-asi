module ArchiveSpace
  module Ead
    module MarcHelper
      BASE_REPO_SUBFIELDS = [['a','Columbia University.  '], ['e','New York, NY.']]
      DEFAULT_SUBAREAS = {
        'nnc-rb' => 'Rare Book and Manuscript Library.',
        'nnc-a'  => 'Avery Architecture and Fine Arts Library. Department of Drawings and Archives.',
        'nnc-m'  => 'Health Sciences Library. Archives and Special Collections.',
        'nnc-ua' => 'Columbia University Archives.',
        'nnc-ut' => 'Burke Library Archives.'
      }

      def self.clio_url_for(bib_id, format = nil)
        url = "https://clio.columbia.edu/catalog/#{bib_id}"
        url << ".#{format}" if format
        url
      end

      def self.clio_marc_for(bib_id)
        raise "no or nil bib id given for clio fetch" unless bib_id
        marc21_url = clio_url_for(bib_id, "marc")
        marc_record = MARC::Record.new_from_marc(URI(marc21_url).read)
      end

      def clio_url_for(bib_id, format = nil)
        MarcHelper.clio_url_for(bib_id, format)
      end

      def field852_for(marc)
        repo_code = repository_code(marc)
        marc['852'] || Marc::DataField.new('852','8',' ', BASE_REPO_SUBFIELDS + ['b', DEFAULT_SUBAREAS[repo_code]])
      end

      def stub_ead(marc, buffer = "")
        print_element(ead_elements(marc).first, buffer)
      end

      def print_element(element, buffer = "")
        buffer << '<' << element[:name]
        if element[:attrs].present?
          element[:attrs].each do |k, v|
            buffer << ' ' << k.to_s << '="' << v.to_s << '"'
          end
        end
        if element[:children] or element[:value]
          buffer << '>'
          if element[:children]
            element[:children].each { |child| print_element(child, buffer) }
          else
            buffer << element[:value].to_s
          end
          buffer << '</' << element[:name] << '>'
        else
          buffer << ' />'
        end
      end

      # stub ead from a bib id per the legacy ACFA app
      # the stub data was generated historically from stub ead (see ead path) generated from MARC (see marc logic):
      def ead_elements(marc)
        elements = []
        ead = {
          name: 'ead',
          attrs: {
            audience: "external",
            xmlns: "urn:isbn:1-931666-22-9",
            :"xmlns:xlink" => "http://www.w3.org/1999/xlink"
          },
          children: []
        }
        ead[:children].concat ead_header_elements(marc)
        ead[:children].concat archdesc_elements(marc)
        elements << ead
        elements
      end

      # TODO: import stub headers by repository code if necessary
      def ead_header_elements(marc)
        elements = [{ name: 'eadheader' }]
        # eadheader/filedesc/publicationstmt/publisher
        last = %w(filedesc publicationstmt publisher).inject(elements[0]) do |parent, tag|
          parent[:children] ||= []
          parent[:children] << { name: tag }
          parent[:children][-1]
        end
        repo_code = repository_code(marc)
        unless REPOS[repo_code]
          Rails.logger.warn("unknown repository_code #{repo_code}")
          return elements
        end

        last[:value] = CGI.escapeHTML(REPOS[repo_code]['name'])
        last = %w(profiledesc creation).inject(elements[0]) do |parent, tag|
          parent[:children] ||= []
          parent[:children] << { name: tag }
          parent[:children][-1]
        end
        last[:value] = "This stub finding aid was produced from CLIO data on <date>#{Time.now.utc}</date>."
        elements
      end

      # nnc-rb, nnc-a, nnc-m, nnc-ua, nnc-ut, nnc-ea, nynycoh
      def repository_code(marc)
        canonical_values = REPOS.keys
        sf = marc['040'].subfields.detect {|s| s.code == 'a' }
        return nil unless sf
        sf = sf.value.downcase
        return sf if canonical_values.include?(sf)
        # TODO identify variants used in the legacy script
        return 'nnc-a' if sf.eql?('nnc-av')
        if sf.eql?('zcu')
          # OCLC identifer for CUL, look in holdings sublocation
          return 'nnc-a' if marc['852'] && (marc['852']['b'].to_s.downcase == 'avr')
        end
        if marc['996']
          name = marc['996']['a']
          code, attrs = REPOS.detect {|code, attrs| attrs['name'] == name }
          return code
        end
      end

      def archdesc_elements(marc)
        elements = []
        archdesc = {
          name: 'archdesc',
          attrs: {
            level: "collection",
            relatedencoding: "MARC21"
          },
          children: []
        }
        archdesc[:children].concat accessrestrict_elements(marc)
        archdesc[:children].concat otherfindaid_elements(marc)
        archdesc[:children].concat did_elements(marc)
        archdesc[:children].concat bioghist_elements(marc)
        archdesc[:children].concat scopecontent_elements(marc)
        archdesc[:children].concat controlaccess_elements(marc)
        elements << archdesc
        elements
      end

      def accessrestrict_elements(marc)
        accessrestrict = { name: 'accessrestrict', children: [] }
        # each '506 1'$a is a p child element
        marc.fields('506').select {|f| f.indicator1 == '1'}.each do |field|
          next unless field['a']
          accessrestrict[:children] << {
            name: 'p',
            value: field['a']
          }
        end
        if accessrestrict[:children][0]
          accessrestrict[:children].unshift(name: 'head', value: 'Restrictions on Access')
        end
        [accessrestrict]
      end

      # ead/archdesc/otherfindaid[@encodinganalog]/p/extref/@*[local-name() = 'href']
      def otherfindaid_elements(marc)
        elements = []
        marc.fields('856').each do |field|
          next unless field.indicator1 == '4' and field.indicator2 == '2'
          next if field['u'] =~ Regexp.compile("ldpd_#{marc['001']}")
          elements << {
            name: 'otherfindaid',
            attrs: { encodinganalog: '856' },
            children: [
              {
                name: 'p',
                children: [
                  {
                    name: 'extref',
                    value: field['3'].present? ? field['3'] : field['z'],
                    attrs: { href: field['u'], :"xlink:type" => 'simple' }
                  }
                ]
              }
            ]
          }
        end
        elements
      end

      def did_elements(marc)
        elements = []
        did = {
          name: 'did',
          attrs: {},
          children: []
        }
        did[:children].concat unitid_elements(marc)
        did[:children].concat unittitle_elements(marc)
        did[:children].concat origination_elements(marc)
        did[:children].concat unitdate_elements(marc)
        did[:children].concat repository_elements(marc)
        did[:children].concat physdesc_elements(marc)
        did[:children].concat langmaterial_elements(marc)
        elements << did
        elements
      end

      ## (link to CLIO)
      ## bib id
      ### ead xpath: ead/archdesc/did/unitid[@type = 'clio']
      ## repository code
      ### ead xpath: ead/archdesc/did/unitid[1]/@repositorycode
      ## Call Number
      ### ead xpath: ead/archdesc/did/unitid[@type = 'call_num'][string-length(./text()) &gt; 0][1]
      def unitid_elements(marc)
        elements = []
        elements << {
          name: 'unitid',
          attrs: { type: 'clio', repositorycode: repository_code(marc), encodinganalog: '001' },
          value: marc['001'].value
        }
        marc.fields('852').each do |field|
          next unless field['h'].present?
          elements << {
            name: 'unitid',
            attrs: { type: 'call_num', repositorycode: repository_code(marc) },
            value: field['h']
          }
        end
        elements
      end

      ### ead xpath: ead/archdesc/did/unittitle
      def unittitle_elements(marc)
        elements = []
        marc.fields('245').each do |field|
          next unless field['a'].present?
          title = field['a'].to_s + field['k'].to_s
          title.sub!(/\,$/,'')
          sort_title = field['a'].dup
          if field.indicator2 =~ /\d+/
            sort_title = sort_title[field.indicator2.to_i..-1]
          end
          sort_title << field['k'].to_s
          sort_title.sub!(/\,$/,'')
          elements << {
            name: 'unittitle',
            attrs: { encodinganalog: "245$a", altrender: sort_title },
            value: title
          }
        end
        elements
      end

      ## Creator
      ### ead xpath: ead/archdesc/did/origination
      def origination_elements(marc)
        elements = []
        origination = {
          name: 'origination',
          attrs: { label: 'Creator'},
          children: []
        }
        candidate_tags = {
          '100' => 'persname',
          '110' => 'corpname',
          '111' => 'corpname',
          '130' => 'title'
        }
        tag, label = candidate_tags.detect { |t,l| marc.fields(t).present? }
        return elements unless tag
        reject_codes = ['0','2']
        values = marc.fields(tag).map {|f| f.subfields.select {|s| !reject_codes.include?(s.code.to_s)}.map(&:value) }

        origination[:children] << {
          name: label,
          attrs: { encodinganalog: tag },
          value: values.flatten.join(' ')
        }
        elements << origination
        elements
      end

      ## repository
      ### ead path: ead/archdesc/did/repository/corpname/subarea
      def repository_elements(marc)
        field852 = field852_for(marc)
        repository = {
          name: 'repository',
          encodinganalog: '852',
          children: []
        }
        repository[:children] << {
          name: 'corpname',
          value: "#{field852['a']}"
        }
        repository[:children] << {
          name: 'address',
          children: [{ name: "addressline", value: field852['e']}]
        }
        [repository]
      end

      ## Physical Description
      ### ead xpath: ead/archdesc/did/physdesc
      def physdesc_elements(marc)
        physdesc = { name: 'physdesc', children: [] }
        extent_value = marc.fields('300').map { |field| field.subfields.map(&:value).join(' ') }.join(' ')
        physdesc[:children] << {
            name: 'extent',
            encodinganalog: '300',
            value: extent_value,
            attrs: { altrender: "materialtype spaceoccupied" }
        } if extent_value.present?
        extent_value = marc.fields('338').map { |field| field.subfields.map(&:value).join(' ') }.join(' ')
        physdesc[:children] << {
            name: 'extent',
            encodinganalog: '338',
            value: extent_value,
            attrs: { altrender: "carrier" }
        } if extent_value.present?
        [physdesc]
      end

      ## Language
      ### ead xpath: ead/archdesc/did/langmaterial
      def langmaterial_elements(marc)
        langmaterial = { name: 'langmaterial', children: [] }
        lang_codes = marc['041']
        if lang_codes
          lang_codes.subfields.select {|sf| sf.code == 'a' }.map(&:value).each do |lang_code|
            langmaterial[:children] << {
              name: 'language',
              attrs: { langcode: lang_code },
              value: ISO_639.find(lang_code).english_name
            }
          end
        else
            langmaterial[:children] << {
              name: 'language',
              attrs: { langcode: 'und' },
              value: 'undetermined'
            }
        end
        [langmaterial]
      end

      ## Biographical Note
      ### ead xpath: ead/archdesc/bioghist/p
      ### marc logic: 545 field values concatenated with ' '
      def bioghist_elements(marc)
        element = {
          name: 'bioghist',
          attrs: { encodinganalog: '545' }
        }
        element[:children] = marc.fields('545').map do |field|
          {
            name: 'p',
            value: field.subfields.map(&:value).join(' ')
          }
        end
        [element]
      end

      ## Scope and Contents
      ### ead xpath: ead/archdesc/scopecontent/p
      ### marc logic: 520 field values concatenated with ' '
      def scopecontent_elements(marc)
        element = {
          name: 'scopecontent',
          attrs: { encodinganalog: '520' }
        }
        element[:children] = marc.fields('520').map do |field|
          {
            name: 'p',
            value: field.subfields.map(&:value).join(' ')
          }
        end
        [element]
      end

      ## Subjects
      ### ead xpath: ead/archdesc/controlaccess/*
      ### ead xpath: ./corpname
      ### marc logic:
      #### [610,611,710,711,697] field subfield values where code not in [0,2]
      ### ead xpath: ./persname
      ### marc logic:
      #### [600,700] field subfield values where code not in [0,2]
      ### ead xpath: ./geogname
      ### marc logic:
      #### 651 field subfield values where code not in [0,2]
      ### ead xpath: ./subject
      ### marc logic:
      #### 650 field subfield values where code not in [0,2]
      ### ead xpath: ./genreform
      ### marc logic:
      #### 655 field subfield values where code not in [0,2]
      ### ead xpath: ./occupation
      ### marc logic:
      #### 656 field subfield values where code is not 2
      ### ead xpath: ./function
      ### marc logic:
      #### 657 field values
      ### ead xpath: ./title
      ### marc logic: [630] field values, [730] subfield values
      def controlaccess_elements(marc)
        elements = []
        # corpname
        elements.concat controlaccess_elements_for_tags(marc, ['610','611','710','711','697'], 'corpname')
        # persname
        elements.concat controlaccess_elements_for_tags(marc, ['600','700'], 'persname')
        # geogname
        elements.concat controlaccess_elements_for_tags(marc, ['651'], 'geogname')
        # subject
        elements.concat controlaccess_elements_for_tags(marc, ['650'], 'subject')
        # genreform
        elements.concat controlaccess_elements_for_tags(marc, ['655'], 'genreform')
        # occupation
        elements.concat controlaccess_elements_for_tags(marc, ['656'], 'occupation',['2'])
        # function
        functions = marc.fields('657').map do |field|
          { name: 'function', value: field.subfields.map(&:value).join(' '), attrs: { encodinganalog: '657' } }
        end.to_a
        elements.concat functions
        # title
        titles = marc.fields('630').map do |field|
          { name: 'title', value: field.subfields.map(&:value).join(' '), attrs: { encodinganalog: '630' } }
        end.to_a
        elements.concat titles
        titles = marc.fields('730').map do |field|
          { name: 'title', value: field.subfields.map(&:value).join(' '), attrs: { encodinganalog: '730' } }
        end.to_a
        elements.concat titles
        controlaccess = {
          name: 'controlaccess',
          children: elements
        }
        [controlaccess]
      end

      def controlaccess_elements_for_tags(marc, tags, element_name, reject_codes = ['0','2'])
        elements = []
        tags.each do |tag|
          marc.fields(tag).each do |field|
            value = controlaccess_subfield_values(field, reject_codes)
            if value.present?
              elements << { name: element_name, value: value, attrs: { encodinganalog: tag } }
            end
          end
        end
        elements
      end

      def controlaccess_subfield_values(field, reject_codes = ['0','2'])
        subfields = field.subfields.select {|sf| !reject_codes.include?(sf.code) }
        value = subfields[0].value.dup
        subfields[1..-1].each do |sf|
          if ['d','q'].include?(sf.code)
            value << ' ' << sf.value
          else
            value << '--' << sf.value
          end
        end
        value
      end

      def unitdate_elements(marc)
        elements = []
        bedate = marc['008'].value[7...11]
        bedate << "/#{marc['008'].value[11...15]}" if marc['008'].value[11] != ' '
        elements << {
          name: 'unitdate',
          value: marc['245']['f'],
          attrs: {
            encodinganalog: '245$f',
            normal: bedate,
            type: 'inclusive',
          }
        }
        marc.fields('245').select { |f| f['g'] }.each do |field|
          elements << {
            name: 'unitdate',
            value: field['g'],
            attrs: {
              encodinganalog: '245$g',
              type: 'bulk'
            }
          }
        end
        elements
      end
    end
  end
end
