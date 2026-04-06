require 'rails_helper'

RSpec.describe 'EAD Cache Download', type: :feature do
  let(:user) do
    User.create!(
      uid: 'test_admin',
      email: 'test_admin@columbia.edu',
      password: Devise.friendly_token[0, 20]
    )
  end
  let(:zip_file) { Tempfile.new(['ead_cache', '.zip']) }

  after do
    zip_file.close
    zip_file.unlink
  end

  describe 'when the user is not signed in' do
    it 'redirects to the sign-in page and does not show the admin page' do
      visit '/admin'

      expect(page.current_path).not_to eq('/admin')
      expect(page).not_to have_text('EAD Cache Download')
    end
  end

  describe 'when signed in and no cached zip file exists' do
    before do
      allow(CONFIG).to receive(:[]).and_call_original
      allow(CONFIG).to receive(:[]).with(:ead_cache_zip_path).and_return('/nonexistent/ead_cache.zip')

      login_as(user, scope: :user)
      visit '/admin'
    end

    it 'shows the admin page' do
      expect(page).to have_text('Admin')
    end

    it 'shows the EAD Cache Download section' do
      expect(page).to have_text('EAD Cache Download')
    end

    it 'shows a disabled button instead of a download link' do
      expect(page).to have_button('No cached EAD files available', disabled: true)
    end

    it 'does not show an active download link' do
      expect(page).not_to have_link('Download EAD files')
    end
  end

  describe 'when signed in and a cached zip file exists' do
    before do
      allow(CONFIG).to receive(:[]).and_call_original
      allow(CONFIG).to receive(:[]).with(:ead_cache_zip_path).and_return(zip_file.path)

      login_as(user, scope: :user)
      visit '/admin'
    end

    it 'shows the admin page' do
      expect(page).to have_text('Admin')
    end

    it 'shows the EAD Cache Download section' do
      expect(page).to have_text('EAD Cache Download')
    end

    it 'displays the file generation timestamp' do
      # The helper formats mtime as "Month DD, YYYY at HH:MM AM/PM"
      expected_date = File.mtime(zip_file.path).strftime('%B')
      expect(page).to have_text(expected_date)
    end

    it 'shows an active download link for the EAD files' do
      expect(page).to have_link('Download EAD files', href: /download_ead_cache/)
    end

    it 'does not show the disabled "no cached files" button' do
      expect(page).not_to have_button('No cached EAD files available')
    end

    it 'downloads the file without navigating away from the page',
       driver: :selenium_chrome_headless_downloads do
      find_link('Download EAD files', href: /download_ead_cache/).click

      expect(page).to have_current_path('/admin')
      expect(page).to have_text('Admin')

      wait_for_download
      expect(downloaded_files.map { |f| File.extname(f) }).to include('.zip')
    end

    after { clear_downloads }
  end

  describe 'when signed in and CONFIG does not define an EAD cache path' do
    before do
      allow(CONFIG).to receive(:[]).and_call_original
      allow(CONFIG).to receive(:[]).with(:ead_cache_zip_path).and_return(nil)

      login_as(user, scope: :user)
      visit '/admin'
    end

    it 'does not render the EAD Cache Download section at all' do
      expect(page).not_to have_text('EAD Cache Download')
    end
  end
end