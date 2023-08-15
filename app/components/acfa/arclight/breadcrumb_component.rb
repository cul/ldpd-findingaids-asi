# frozen_string_literal: true

module Acfa::Arclight
  # Display the document hierarchy as "breadcrumbs"
  class BreadcrumbComponent < ::Arclight::BreadcrumbComponent
    def components
      return to_enum(:components) unless block_given?

      yield build_repository_link

      finding_aid_id = @document['parent_ssim'].detect { |pid| pid =~ /ldpd_\d+$/ }
      repo_id = @document['repository_id_ssi']
      components_link = helpers.repository_finding_aid_components_path(repository_id: repo_id, finding_aid_id: finding_aid_id, anchor: 'view_all')
      @document.parents.each do |parent|
        if parent.id =~ /ldpd_\d+$/
          tag_link = helpers.repository_finding_aid_path(repository_id: repo_id, id: finding_aid_id)
        else
          tag_link = components_link
        end
        yield tag.li(class: 'breadcrumb-item') { link_to(parent.label, tag_link) }
      end
    end

    def build_repository_link
      render Acfa::Arclight::RepositoryBreadcrumbComponent.new(document: @document)
    end
  end
end