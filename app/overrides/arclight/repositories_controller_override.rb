Arclight::RepositoriesController.class_eval do
  # Monkeypatch because Arclight is determined to seach by repo name, and not include except defaults
  def show
    @repository = Arclight::Repository.find_by!(slug: params[:id])
    search_service = Blacklight.repository_class.new(blacklight_config)
    @response = search_service.search(
      q: "level_ssim:Collection repository_id_ssi:\"#{@repository.slug}\"",
      fl: "id,repository_id_ssi,ead_ssi,aspace_path_ssi,normalized_title_ssm",
      rows: 100
    )
    @collections = @response.documents
  end
end
