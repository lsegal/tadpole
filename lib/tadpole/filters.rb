module Tadpole
  module Filters
    module ClassMethods
      def before_section(*args)
        if args.size == 1
          before_section_filters.push [nil, args.first] 
        elsif args.size == 2
          before_section_filters.push(args)
        else
          raise ArgumentError, "before_section takes a section followed by a Proc/lambda or Symbol referencing the method name"
        end
      end
      
      def before_section_filters
        @before_section_filters ||= []
      end
      
      def before_run(meth)
        before_run_filters.push(meth)
      end
      
      def before_run_filters
        @before_run_filters ||= []
      end
    end
    
    module InstanceMethods
      def run_before_run
        self.class.before_run_filters.each do |meth|
          meth = method(meth) if meth.is_a?(Symbol)
          result = meth.call 
          return result if result.is_a?(FalseClass)
        end
      end

      def run_before_sections
        self.class.before_section_filters.each do |info|
          result, sec, meth = nil, *info
          if sec.nil? || sec == current_section
            meth = method(meth) if meth.is_a?(Symbol)
            args = meth.arity == 0 ? [] : [current_section]
            result = meth.call(*args)
          end

          return result if result.is_a?(FalseClass)
        end
      end
    end
  end
end