module Tadpole
  module Filters
    module ClassMethods
      def before_section(*args, &block)
        args.push(block) if block
        if args.size == 1
          before_section_filters.push [nil, args.first] 
        elsif args.size == 2
          before_section_filters.push(args)
        else
          raise ArgumentError, "before_section takes a section followed by a Proc/lambda or Symbol referencing the method name"
        end
      end
      alias before before_section
      
      def before_section_filters
        @before_section_filters ||= []
      end
      
      def before_run(meth = nil, &block)
        before_run_filters.push(meth ? meth : block)
      end
      
      def before_run_filters
        @before_run_filters ||= []
      end
    end
    
    module InstanceMethods
      def run_before_run
        self.class.before_run_filters.each do |meth|
          result = call_before_method(meth, false)
          return result if result.is_a?(FalseClass)
        end
      end

      def run_before_sections
        self.class.before_section_filters.each do |info|
          result, sec, meth = nil, *info
          if sec.nil? || sec.to_s == current_section.to_s
            result = call_before_method(meth)
          end

          return result if result.is_a?(FalseClass)
        end
      end
      
      def call_before_method(meth, pass_args = true)
        if meth.is_a?(Symbol)
          meth = method(meth)
          args = meth.arity == 0 ? [] : [current_section]
          meth.call(*args)
        else
          instance_eval(&meth)
        end
      end
    end
  end
end