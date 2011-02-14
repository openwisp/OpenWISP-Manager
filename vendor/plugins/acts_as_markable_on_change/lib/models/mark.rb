class Mark < ActiveRecord::Base
  ##
  ## Attributes till now:
  ##  
  ##  a timestamp to mark changes:    changed_at:datetime
  ##  polymorphic attributes:         markable_id:integer, markable_type:string
  ##

  belongs_to :markable, :polymorphic => true

  # Clear changed_at value
  # and declare changes have
  # been processed
  def clear!
    self.changed_at = nil
    self.save
  end
end
