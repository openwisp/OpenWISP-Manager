module MarkableOnChange
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def acts_as_markable_on_change(params = nil)
      has_one :mark, :as => :markable

      const_set('CRITICAL_ATTRIBUTES_ON_SAVE', [params[:watch_for]].flatten)
      const_set('CRITICAL_ATTRIBUTES_ON_DESTROY', [params[:notify_on_destroy]].flatten)

      before_save do |instance|
        instance.mark!
      end

      before_destroy do |instance|
        instance.notify!
      end
    end
  end



  module InstanceMethods

    # Look for :watch_for specified attributes. Find with reflect_on_all_associations
    # if we need to look recursively inside other associations. Otherwise, we simply
    # call _changed? method on a specified attribute.
    def changing?
      klass = self.class

      many = klass.reflect_on_all_associations(:has_many).collect{|assoc| assoc.name}
      one = [
          klass.reflect_on_all_associations(:has_one).collect{|assoc| assoc.name},
          klass.reflect_on_all_associations(:belongs_to).collect{|assoc| assoc.name}
      ].flatten

      begin
        klass.const_get('CRITICAL_ATTRIBUTES_ON_SAVE').any? do |attr|
          if many.include?(attr.to_sym)
            send("#{attr}").any?{|instance| instance.has_changed_from? self.changed_at }
          elsif one.include?(attr.to_sym)
            send("#{attr}").has_changed_from? self.changed_at
          else
            send("#{attr}_changed?")
          end
        end
      rescue
        raise "acts_as_markable_on_change not defined for #{klass} or for its :watch_for attributes"
      end
    end

    # Gets the timestamp of last change
    def changed_at
      mark.changed_at unless mark.blank?
    end

    # is the Model changed_from? some_date ???
    # if it's blank, IT HAS CHANGED!
    def has_changed_from?(from_date)
      return true if changed_at.blank?
      changed_at.to_i > from_date.to_i
    end

    # Write the timestamp (mark.changed_at).
    # If force is true, the mark is written even if the model
    # is not changing.
    def mark!(force = true)
      if changing? or force
        mark.blank? ? self.mark = Mark.new(:changed_at => Time.now) : self.mark.changed_at = Time.now
      end
    end

    # Look for belongs_to associations specified by
    # :notify_on_destroy and mark! them (so when destroy happens, the
    # "father" attribute is marked as changed)
    def notify!
      klass = self.class
      belongs = klass.reflect_on_all_associations(:belongs_to).collect{|assoc| assoc.name}

      to_notify = klass.const_get('CRITICAL_ATTRIBUTES_ON_DESTROY')
      if to_notify and belongs.include?(to_notify)
        to_notify.each do |attr|
          send("#{attr}").mark!(true)
        end
      end
    end

    # Just a placeholder... clear the timestamp mark
    def clear_changes!
      mark.clear!
    end
  end

  ActiveRecord::Base.send :include, MarkableOnChange
end
