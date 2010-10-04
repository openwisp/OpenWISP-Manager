class Configuration < ActiveRecord::Base

  validates_presence_of :key
  validates_format_of :key, :with => /\A[a-z_\.,]+\Z/
  validates_presence_of :value

  def self.get(key)
    unless res = Configuration.find_by_key(key)
      raise("BUG: value for key " + key + " not found!")
    end
    res.value
  end

  def self.set(key, value)
    if prev = Configuration.find_by_key(key)
      prev.set(value) 
    else
      Configuration.new(:key => key, :value => value).save!
    end
  end

  def set(value = '')
    self.system_key? && raise("BUG: key " + key + "is readonly!")
  end
  
  def system_key?
    self.system_key
  end
end
