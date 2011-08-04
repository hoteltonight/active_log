module ParolkarInnovationLab
  module SocialNet
    def self.included(base)
      base.extend ParolkarInnovationLab::SocialNet::ClassMethods
    end
    
    module ClassMethods
      def records_active_log(arg_hash={}) 
              include ParolkarInnovationLab::SocialNet::InstanceMethods
              before_save :record_changes_for_active_log
              after_save :save_active_log, :unless => :skip_active_log
              has_many :active_logs, :as => :ar
      end
    end  
    
    module InstanceMethods
      # Explicitly define methods for each attribute, since doing it via method_missing
      # would potentially conflict with others defining method_missing.
      def self.included(base)
        base.column_names.each do |attr_name|
          define_method "#{attr_name}_at_timestamp" do |timestamp|
            attribute_value_at_timestamp(attr_name.to_sym, timestamp)
          end
        end
      end

      private
        def record_changes_for_active_log
          @copy_of_changes = changes
        end
        def save_active_log
          return unless changes.length > 0
          log = ActiveLog.new
          log.ar = self
          log.changed_content = @copy_of_changes
          log.meta_data = {:session_user_id => ActiveLog.current.id} unless ! ActiveLog.current # How does this work? Well.. You gotta put a before_filter in application controller which assigns ActiveLog.current = current_user
          log.save!
        end   

        def skip_active_log
          @skip_active_log
        end

        def attribute_value_at_timestamp(attribute, timestamp)
          return nil if created_at >= timestamp.utc

          attribute = attribute.to_sym  # ensure it's a symbol
          attribute_name = attribute.to_s

          # if created before the time, with no changes (or active log skipped), then use current value.
          # note that unless skipped, there is an acitve log created for initial record creation
          return self[attribute] if active_logs.size == 0

          # otherwise, it's been changed, so we have to see what the value was at the time specified
          #   if there are changes before the time, then scan those, starting from the one closest
          #     and looking for attr change, and use latest/new value
          #   if only changes after the time, then scan those, starting from the one closest
          #     to the time and looking for attr change, and use prior value
          active_logs.where("updated_at < ?", timestamp.utc).order("updated_at DESC").each do |log|
            log.changed_content.each do |attr, values|
              return values[1] if attr == attribute_name
            end
          end

          active_logs.where("updated_at >= ?", timestamp.utc).order("updated_at ASC").each do |log|
            log.changed_content.each do |attr, values|
              return values[0] if attr == attribute_name
            end
          end

          # if we get here, none of the changes affected the enabled attribute, so return current value
          self[attribute]
        end

     end
   end
 end  
