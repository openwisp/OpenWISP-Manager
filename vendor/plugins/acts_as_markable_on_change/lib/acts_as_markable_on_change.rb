module MarkableOnChange
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def acts_as_markable_on_change(params = nil)
      has_one :mark, :as => :markable

      const_set('CRITICAL_ATTRIBUTES_ON_SAVE', [params[:watch_for]].flatten) if params[:watch_for]
      const_set('CRITICAL_ATTRIBUTES_ON_DESTROY', [params[:notify_on_destroy]].flatten) if params[:notify_on_destroy]
      const_set('CLEAR_MARKS_ON_METHOD', params[:clear_marks_on]) if params[:clear_marks_on]

      # By passing a method name via :clear_marks_on, it will be defined an hook that,
      # whenever that method is called, also the Mark model will be emptied (basically
      # resetting changes).
      # This way can be used to "commit" changes definitively.
      def method_added(method)
        if !method_defined?(:clear_marks_trigger) && const_defined?('CLEAR_MARKS_ON_METHOD') && (const_get('CLEAR_MARKS_ON_METHOD') == method)
          alias_method :clear_marks_trigger, const_get('CLEAR_MARKS_ON_METHOD')

          define_method(const_get('CLEAR_MARKS_ON_METHOD')) do
            clear_marks_trigger
            Mark.clear!
          end
        end
      end

      after_save do |instance|
        instance.mark! if const_defined?('CRITICAL_ATTRIBUTES_ON_SAVE')
      end

      after_destroy do |instance|
        instance.notify! if const_defined?('CRITICAL_ATTRIBUTES_ON_DESTROY')
      end
    end
  end



  module InstanceMethods
    # Look for :watch_for specified attributes. Find with reflect_on_all_associations
    # if we need to look recursively inside other associations. Otherwise, we simply
    # call _changed? method on a specified attribute.
    def changing?(from_date = nil)
      klass = self.class
      from_date ||= self.changed_at

      many = klass.reflect_on_all_associations(:has_many).collect{|assoc| assoc.name}
      one = [
          klass.reflect_on_all_associations(:has_one).collect{|assoc| assoc.name},
          klass.reflect_on_all_associations(:belongs_to).collect{|assoc| assoc.name}
      ].flatten

      begin
        klass.const_get('CRITICAL_ATTRIBUTES_ON_SAVE').any? do |attr|
          if many.include?(attr.to_sym)
            send("#{attr}").any?{|instance| (instance.has_changed_from?(from_date) or instance.changing?) if instance }
          elsif one.include?(attr.to_sym)
            (send("#{attr}").has_changed_from?(from_date) or send("#{attr}").changing?) if try(attr)
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
      mark.changed_at if respond_to?(:mark) && !mark.blank?
    end

    # is the Model changed_from? some_date ???
    # if callee and from_date are blank, it means changes are not being tracked
    # or have been cleared (so it has not changed).
    # if callee is nil, but from_date is blank, it means the callee has changes
    # that need to be applied
    def has_changed_from?(from_date)
      if changed_at.blank? && from_date.blank?
        false
      elsif changed_at.blank?
        true
      else
        changed_at.to_i > from_date.to_i
      end
    end

    # Write the timestamp (mark.changed_at).
    # If force is true, the mark is written even if the model
    # is not changing.
    def mark!(force = false)
      if force or changing?
        mark.blank? ? self.mark = Mark.new(:changed_at => Time.now) : self.mark.changed_at = Time.now
        self.mark.save
      end
    end

    # Look for belongs_to associations specified by
    # :notify_on_destroy and mark! them (so when destroy happens, the
    # "father" attribute is marked as changed)
    def notify!
      klass = self.class
      belongs = klass.reflect_on_all_associations(:belongs_to).collect{|assoc| assoc.name}

      begin
        to_notify = klass.const_get('CRITICAL_ATTRIBUTES_ON_DESTROY')
        to_notify.each do |attr|
          send("#{attr}").mark!(true) if belongs.include?(attr.to_sym)
        end
      rescue
        raise "acts_as_markable_on_change not defined for #{klass} or for its :notify_on_destroy attributes"
      end
    end
  end

  ActiveRecord::Base.send :include, MarkableOnChange
end
