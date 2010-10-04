class Server < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name

  has_many :ethernets, :as => :machine, :dependent => :destroy
  has_many :bridges, :as => :machine, :dependent => :destroy
  has_many :l2vpn_servers, :dependent => :destroy

  has_many :taps, :through => :l2vpn_servers

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
