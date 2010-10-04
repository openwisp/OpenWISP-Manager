class WeeklyMonitoringAccessPoint < ActiveRecord::Base

  def initialize ( params )
    params[:date] ||= Date.today
    params[:percentage] || raise("BUG: Missing percentage")
    params[:access_point_id] || raise("BUG: Missing access point")
    
    super( params )
  end
  
end
