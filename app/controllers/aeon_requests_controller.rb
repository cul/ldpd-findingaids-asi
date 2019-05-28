class AeonRequestsController < ApplicationController
  def create
    @selected_containers = Set.new
    params.select {|key, value| key.starts_with?('checkbox_')}.each do |checkbox_id, checkbox_value|
      @selected_containers.add checkbox_value
    end
    @bib_id = params[:bib_id]
    @item_title = params[:item_title]
  end

  def login
    @selected_containers = Set.new
    params.select {|key, value| key.starts_with?('checkbox_')}.each do |checkbox_id, checkbox_value|
      @selected_containers.add checkbox_value
    end
    session[:selected_containers] = @selected_containers.to_a
    session[:bib_id] = params[:bib_id]
    session[:item_title] = params[:item_title]
    session[:notes] = params[:notes]
    session[:scheduled_date] = Date.strptime(params[:scheduled_date],'%Y-%m-%d').strftime('%m/%d/%Y') unless params[:scheduled_date].empty?
  end

  def redirectshib
    @selected_containers = session[:selected_containers]
    @bib_id = session[:bib_id]
    @item_title = session[:item_title]
    @notes = session[:notes]
    @scheduled_date = session[:scheduled_date]
    session.clear
  end

  def redirectnonshib
    @selected_containers = session[:selected_containers]
    @bib_id = session[:bib_id]
    @item_title = session[:item_title]
    @notes = session[:notes]
    @scheduled_date = session[:scheduled_date]
    session.clear
  end
end
