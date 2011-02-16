class Mark < ActiveRecord::Base
  ##
  ## Attributes till now:
  ##  
  ##  a timestamp to mark changes:    changed_at:datetime
  ##  polymorphic attributes:         markable_id:integer, markable_type:string
  ##

  belongs_to :markable, :polymorphic => true

  class << self
    alias :clear! :delete_all
  end
end
