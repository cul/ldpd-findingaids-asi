module FindingAidsHelper
  def apply_title_render_italic content
    titles_render_italic = content.xpath('./xmlns:title[@render="italic"]')
    titles_render_italic.each do |title_italic|
      title_italic.replace "<i>#{title_italic.text}</i>"
    end
    content
  end
end
