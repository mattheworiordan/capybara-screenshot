module Capybara
  module Screenshot
    module Callbacks
      class CallbackSet < Array
        def call *args
          each do |callback|
            callback.call *args
          end
        end
      end

      module ClassMethods
        def callbacks
          @callbacks ||= {}
        end

        def define_callback name
          callbacks[name] ||= CallbackSet.new

          define_singleton_method name do |&block|
            callbacks[name] << block
          end
        end

        def run_callbacks name, *args
          if cb_set = callbacks[name]
            cb_set.call *args
          end
        end
      end

      module InstanceMethods
        def run_callbacks name, *args
          self.class.run_callbacks name, *args
        end
      end

      def self.included receiver
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end
