# frozen_string_literal: true

class Acfa::Document::GroupComponent < ::Arclight::GroupComponent

  def grouped_documents
    @grouped_docs ||= @group.docs.select { |doc| doc.id != @group.key}.slice(0, 3)
  end
end
