class AeonRequestsController < ApplicationController
  def create
    @allow_requests = AEON[:allow_requests]
    @display_request_notice = AEON[:display_request_notice]
    @display_request_scheduled_date = AEON[:display_request_scheduled_date]
    @selected_containers = Set.new
    params.select {|key, value| key.starts_with?('checkbox_')}.each do |checkbox_id, checkbox_value|
      @selected_containers.add checkbox_value
    end
    @bib_id = params[:bib_id]
    @call_number = params[:call_number]
    @item_title = params[:item_title]
    @author = params[:author]
    @item_date = params[:item_date]
    @location = params[:location]
    @unprocessed = params[:unprocessed].present?
    @aeon_site_code = params[:site]
  end

  def login
    @allow_cu_affiliate_login = AEON[:allow_cu_affiliate_login]
    @allow_non_cu_affiliate_login = AEON[:allow_non_cu_affiliate_login]
    @allow_non_cu_affiliate_account_creation = AEON[:allow_non_cu_affiliate_account_creation]
    @display_login_notice = AEON[:display_login_notice]
    @selected_containers = Set.new
    params.select {|key, value| key.starts_with?('checkbox_')}.each do |checkbox_id, checkbox_value|
      @selected_containers.add checkbox_value
    end
    session[:selected_containers] = @selected_containers.to_a
    session[:bib_id] = params[:bib_id]
    session[:call_number] = params[:call_number]
    session[:item_title] = params[:item_title]
    session[:author] = params[:author]
    session[:item_date] = params[:item_date]
    session[:location] = params[:location]
    session[:unprocessed] = params[:unprocessed]
    session[:notes] = params[:notes]
    session[:scheduled_date] = Date.strptime(params[:scheduled_date],'%Y-%m-%d').strftime('%m/%d/%Y') unless params[:scheduled_date].blank?
    session[:site] = params[:site]
  end

  def redirectshib
    @selected_containers = session[:selected_containers]
    @bib_id = session[:bib_id]
    @call_number = session[:call_number]
    @item_title = session[:item_title]
    @author = session[:author]
    @item_date = session[:item_date]
    @location = session[:location]
    @unprocessed = session[:unprocessed].present?
    @notes = session[:notes]
    @scheduled_date = session[:scheduled_date]
    @aeon_site_code = session[:site]
    session.clear
  end

  def redirectnonshib
    @selected_containers = session[:selected_containers]
    @bib_id = session[:bib_id]
    @call_number = session[:call_number]
    @item_title = session[:item_title]
    @author = session[:author]
    @item_date = session[:item_date]
    @location = session[:location]
    @unprocessed = session[:unprocessed].present?
    @notes = session[:notes]
    @scheduled_date = session[:scheduled_date]
    @aeon_site_code = session[:site]
    session.clear
  end
end
