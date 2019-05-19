class AeonRequestsController < ApplicationController
  def create
    @selected_containers = Set.new
    params.select {|key, value| key.starts_with?('checkbox_')}.each do |checkbox_id, checkbox_value|
      @selected_containers.add checkbox_value
    end
  end

  def login
  end

  def redirectshib
  end
end
