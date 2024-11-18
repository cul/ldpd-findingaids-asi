require 'rails_helper'

describe CatalogController, type: :routing do
  let(:well_known_id) { 'well-known-id' }
  it 'routes to #resolve' do
    expect(get: "/resolve/#{well_known_id}").to route_to(
      action: 'resolve',
      controller: 'catalog',
      id: well_known_id
    )
  end
end