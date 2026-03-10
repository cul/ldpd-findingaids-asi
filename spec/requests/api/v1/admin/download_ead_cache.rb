require 'rails_helper'

url = '/api/v1/admin/download_ead_cache'

RSpec.describe url, type: :request do
  describe "without authentication" do
    it "returns the expected response" do
      get url
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "with authentication" do
    context "when no cached zip file exists" do
      before do
        allow(File).to receive(:exist?).with(CONFIG[:ead_cache_zip_path]).and_return(false)
        get_with_auth(url)
      end

      it "returns a not found status and the expected response" do
        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq({ result: false, error: 'No cached EAD zip files found.' }.to_json)
      end
    end

    context "when a cached zip file exists" do
      let(:zip_file) { Tempfile.new(['ead_cache', '.zip']) }

      before do
        allow(CONFIG).to receive(:[]).and_call_original
        allow(CONFIG).to receive(:[]).with(:ead_cache_zip_path).and_return(zip_file.path)
        get_with_auth(url)
      end

      after do
        zip_file.close
        zip_file.unlink
      end

      it "returns a successful response" do
        expect(response).to have_http_status(:success)
      end

      it "returns the file as an attachment with the correct filename and content type" do
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include(File.basename(zip_file.path))
        expect(response.headers['Content-Type']).to include('application/zip')
      end
    end
  end
end