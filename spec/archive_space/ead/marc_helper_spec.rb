require 'rails_helper'
require 'archive_space/ead/marc_helper'
require "rexml/document"
RSpec.describe ArchiveSpace::Ead::MarcHelper do
	let(:test_class) {  Class.new {|| include ArchiveSpace::Ead::MarcHelper } }
	let(:test_obj) { test_class.new }
	let(:rbml_fixture) { 'marc/11583096.marc' }
	let(:avery_fixture) { 'marc/6911372.marc' }
	let(:marc_source) { fixture_file_upload(rbml_fixture).read }
	let(:marc) { MARC::Record.new_from_marc(marc_source.dup) }

    describe "stub_ead" do
    	it "returns well-formatted XML" do
    		expect(REXML::Document.new test_obj.stub_ead(marc)).to have_elements
    	end
    end

	describe "respository_code" do
		it "gets the rbml code" do
			code = test_obj.repository_code marc
			expect(code).to eql("nnc-rb")
		end
		it "gets the avery code" do
			code = test_obj.repository_code MARC::Record.new_from_marc(fixture_file_upload(avery_fixture).read)
			expect(code).to eql("nnc-a")
		end
	end

	describe "unitdate_elements" do
		let(:elements) { test_obj.unitdate_elements(marc) }
		it "generates an inclusive date" do
			inclusive = elements.detect {|e| e[:attrs][:type] == 'inclusive'}
			expect(inclusive[:attrs]).to match(
				{
					encodinganalog: '245$f',
					normal: '1934/2018',
					type: 'inclusive'
				}
			)
			expect(inclusive[:value]).to eql("1934-2018")
		end
	end

	describe "unitid_elements" do
		let(:elements) { test_obj.unitid_elements(marc) }
		it "generates an inclusive date" do
			call_num = elements.detect {|e| e[:attrs][:type] == 'call_num'}
			expect(call_num[:attrs]).to match(
				{
					type: 'call_num',
					repositorycode: 'nnc-rb'
				}
			)
			expect(call_num[:value]).to eql("MS#1739")
		end
	end

	describe "origination_elements" do
		let(:elements) { test_obj.origination_elements(marc) }
		it "generates a creator" do
			expect(elements.first[:children].first).to match(
				{
					name: 'persname',
					attrs: {:encodinganalog=>"100"},
					value: "Mitchell, Arthur, 1934-,."
				}
			)
		end
	end
end