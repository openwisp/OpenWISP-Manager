class Server < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_format_of :name, :with => /\A[a-z][\s\w\d\.\-]*\Z/i
  validates_length_of :name, :maximum => 16
  
  has_many :ethernets, :as => :machine, :dependent => :destroy
  has_many :bridges, :as => :machine, :dependent => :destroy
  has_many :l2vpn_servers, :dependent => :destroy

  has_many :taps, :through => :l2vpn_servers

  somehow_has :many => :access_points, :through => :l2vpn_servers

  def vlans
    # TODO: this should return an activerecord array
    (self.ethernets.map { | e | e.vlans } + 
      self.taps.map { |t| t.vlans }).flatten
  end
  
  def interfaces
    # TODO: this should return an activerecord array
    self.ethernets + self.taps
  end

end
