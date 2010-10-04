class HourlyMonitoringAccessPoint < ActiveRecord::Base

  def initialize ( params )
    params[:hour] ||= DateTime.now.hour
    params[:date] ||= Date.today 
    params[:access_point_id] || raise("BUG: Missing access point")
    
    super( params )
  end
  
end
