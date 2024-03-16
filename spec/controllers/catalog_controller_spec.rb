RSpec.describe CatalogController, type: :controller do
  describe '#default_grouped!' do
    before do
      controller.params[:page] = 2
      controller.default_grouped!
    end
    subject(:search_state) { controller.search_state }
    it "sets group param" do
      expect(search_state.params[:group]).to eql "true"
    end
    it "does not reset page param" do
      expect(search_state.params[:page]).to be 2
    end
  end
end