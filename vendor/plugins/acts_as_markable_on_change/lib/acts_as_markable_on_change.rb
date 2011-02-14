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

    def changed_at
      mark.changed_at unless mark.blank?
    end

    def has_changed_from?(from_date)
      return true if changed_at.blank?
      changed_at.to_i > from_date.to_i
    end

    def mark!(force = true)
      if changing? or force
        mark.blank? ? self.mark = Mark.new(:changed_at => Time.now) : self.mark.changed_at = Time.now
      end
    end

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

    def clear_changes!
      mark.clear!
    end
  end

  ActiveRecord::Base.send :include, MarkableOnChange
end
