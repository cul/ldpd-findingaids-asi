module FindingAidsHelper
  def apply_title_render_italic content
    titles_render_italic = content.xpath('./xmlns:title[@render="italic"]')
    titles_render_italic.each do |title_italic|
      title_italic.replace "<i>#{title_italic.text}</i>"
    end
    content
  end

  def apply_extref_type_simple content
    extrefs_type_simple = content.xpath('./xmlns:extref[@xlink:type="simple"]')
    extrefs_type_simple.each do |extref|
      href = "\"#{extref.attribute('href')}\""
      link_text = extref.text
      extref.replace "<a href=#{href}>#{link_text}</a>"
    end
    content
  end
end
