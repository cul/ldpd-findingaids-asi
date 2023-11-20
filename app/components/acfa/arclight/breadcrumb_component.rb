# frozen_string_literal: true

module Acfa::Arclight
  # Display the document hierarchy as "breadcrumbs"
  class BreadcrumbComponent < ::Arclight::BreadcrumbComponent
    CU_FA_ROOT_NAME = /ldpd_\d+$/
    BA_FA_ROOT_NAME = /ldpd_[BS]C\d*(-\d*)?$/
    def components
      return to_enum(:components) unless block_given?

      yield build_repository_link

      finding_aid_id = @document['parent_ssim']&.detect { |pid| (pid =~ CU_FA_ROOT_NAME) || (pid =~ BA_FA_ROOT_NAME) }
      return unless finding_aid_id

      repo_id = @document['repository_id_ssi']
      parent_dsc = Acfa::SearchState.series_to_dsc(@document.fetch('parent_unittitles_ssm', []))

      doc_repo = Arclight::Repository.find_by(slug: repo_id)
      aspace_base_uri = doc_repo.attributes.fetch('aspace_base_uri', nil) if doc_repo
      @document.parents.each do |parent|
        if (parent.id =~ CU_FA_ROOT_NAME)
          tag_link = helpers.repository_finding_aid_path(repository_id: repo_id, id: finding_aid_id)
        elsif aspace_base_uri
          # parent docs do not have sufficient data to build ASpace PUI links
          yield tag.li(class: 'breadcrumb-item') { parent.label }
          next
        elsif finding_aid_id && finding_aid_id =~ CU_FA_ROOT_NAME
          aspace_id = parent.id.sub(finding_aid_id, '')
          aspace_id = nil unless aspace_id =~ /^aspace/
          tag_link_params = { repository_id: repo_id, finding_aid_id: finding_aid_id, anchor: aspace_id || 'view_all' }
          tag_link_params.delete(:anchor) if parent.level == 'Series'
          tag_link = parent_dsc ? helpers.repository_finding_aid_component_path(id: parent_dsc, **tag_link_params)
            : helpers.repository_finding_aid_components_path(**tag_link_params)
        else
          next
        end
        yield tag.li(class: 'breadcrumb-item') { tag_link ? link_to(parent.label, tag_link) : parent.label }
      end
    end

    def render?
      @document.parents.length >= @offset # the repository link will occupy an offset
    end

    def build_repository_link
      render Acfa::Arclight::RepositoryBreadcrumbComponent.new(document: @document)
    end
  end
end