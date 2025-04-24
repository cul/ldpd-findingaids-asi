require 'rails_helper'

RSpec.describe Acfa::ArchivesSpace::Client do
  let(:base_uri) { 'https://example-test.example.com/api' }
  let(:username) { 'username' }
  let(:password) { 'password' }
  let(:timeout)  { 10 }

  let(:archives_space_configuration) do
    ArchivesSpace::Configuration.new({
      base_uri: base_uri,
      username: username,
      password: password,
      timeout: timeout
    })
  end

  let(:instance) { described_class.new(archives_space_configuration) }

  let(:repository_id) { '2' }
  let(:resource_id) { '2024' }
  let(:valid_resource_record_uri) { "/repositories/#{repository_id}/resources/#{resource_id}" }
  let(:invalid_resource_record_uri) { "Oh no! This can't be valid!" }

  it 'is a subclass of ArchivesSpace::Client' do
    expect(described_class).to be < ArchivesSpace::Client
  end

  describe "#initialize" do
    it 'can be instantiated' do
      expect(instance).to be_a(described_class)
    end
  end

  describe ".instance" do
    before do
      allow_any_instance_of(Acfa::ArchivesSpace::Client).to receive(:login)
    end

    it 'returns the same instance every time it is called' do
      inst = described_class.instance
      expect(inst).to be_a(described_class)
      expect(described_class.instance).to be(inst)
    end
  end

  describe '#split_resource_record_uri' do
    it 'returns the expected values for a valid resource_record_uri' do
      expect(instance.split_resource_record_uri(valid_resource_record_uri)).to eq([repository_id, resource_id])
    end

    it 'raises an exception when a malformed resource_record_uri is given' do
      expect { instance.split_resource_record_uri(invalid_resource_record_uri) }.to raise_error(Acfa::Exceptions::InvalidArchivesSpaceResourceUri)
    end
  end

  describe '#bib_id_for_resource' do
    let(:expected_bib_id) { '4078184' }

    before do
      response = double('Response')
      allow(response).to receive(:body).and_return({'id_0' => expected_bib_id}.to_json)
      allow(instance).to receive(:get).with(
        "/repositories/#{repository_id}/resources/#{resource_id}"
      ).and_return(response)
      allow(response).to receive(:status_code).and_return(200)
    end

    it 'returns the expected value for a valid resource_record_uri' do
      expect(instance.bib_id_for_resource(resource_record_uri: valid_resource_record_uri)).to eq(expected_bib_id)
    end

    it 'raises an exception when a malformed resource_record_uri is given' do
      expect { instance.bib_id_for_resource(resource_record_uri: invalid_resource_record_uri) }.to raise_error(
        Acfa::Exceptions::InvalidArchivesSpaceResourceUri
      )
    end
  end

  describe '#download_ead' do
    let(:filename) { 'great-filename.xml' }
    let(:include_unpublished) { true }
    let(:expected_download_path) { File.join(CONFIG[:ead_cache_dir], filename) }
    let(:valid_xml) { '<?xml version="1.0" encoding="utf-8"?><ead></ead>' }
    let(:invalid_xml) { '<?xml version="1.0" encoding="utf-8"?><ead></eazzzzzz>' }

    context 'with valid arguments' do
      before do
        response = double('Response')
        allow(response).to receive(:body).and_return(xml_content)
        allow(instance).to receive(:get).with(
          "/repositories/#{repository_id}/resource_descriptions/#{resource_id}.xml",
          query: { include_unpublished: include_unpublished, include_daos: true }
        ).and_return(response)
        allow(response).to receive(:status_code).and_return(200)
      end

      context 'when the XML from ArchivesSpace is valid' do
        let(:xml_content) { valid_xml }
        it 'is successful and returns the expected download path' do
          expect(instance.download_ead(
            resource_record_uri: valid_resource_record_uri, filename: filename, include_unpublished: include_unpublished
          )).to eq(expected_download_path)
        end
      end

      context 'when the XML from ArchivesSpace is invalid' do
        let(:xml_content) { invalid_xml }
        it 'raises an exception' do
          expect{
            instance.download_ead(
              resource_record_uri: valid_resource_record_uri, filename: filename, include_unpublished: include_unpublished
            )
          }.to raise_error(Acfa::Exceptions::InvalidEadXml)
        end
      end
    end

    it 'raises an exception when a malformed resource_record_uri is given' do
      expect {
        instance.download_ead(
          resource_record_uri: invalid_resource_record_uri, filename: filename, include_unpublished: include_unpublished
        )
      }.to raise_error(
        Acfa::Exceptions::InvalidArchivesSpaceResourceUri
      )
    end
  end

  describe '#raise_error_if_unsuccessful_archivesspace_response!' do
    let(:context_label) { 'some_method_name' }
    let(:response_body) { 'This is the response body.' }
    let(:response) do
      resp = double('Response')
      allow(resp).to receive(:status_code).and_return(status_code)
      allow(resp).to receive(:body).and_return(response_body)
      resp
    end

    context 'status code is 200' do
      let(:status_code) { 200 }

      it 'does not raise an exception' do
        expect {
          instance.raise_error_if_unsuccessful_archivesspace_response!(context_label, response)
        }.not_to raise_error
      end
    end

    context 'status code is not 200' do
      let(:status_code) { 403 }

      it 'logs an error and raises an exception' do
        expect(Rails.logger).to receive(:error).with(
          "#{context_label}: request returned a status of #{status_code}.  Response: #{response_body}"
        )
        expect {
          instance.raise_error_if_unsuccessful_archivesspace_response!(context_label, response)
        }.to raise_error(Acfa::Exceptions::UnexpectedArchivesSpaceApiResponse)
      end
    end
  end
end
