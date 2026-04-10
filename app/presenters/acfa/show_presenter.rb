class Acfa::ShowPresenter < Arclight::ShowPresenter
  def html_title
    doc_title = heading
    repo_name = Array.wrap(document.fetch('repository_ssim', nil)).first
    doc_title + " - " + repo_name
  end
end
