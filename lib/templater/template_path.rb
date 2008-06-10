module Templater
  module TemplatePath
    module ClassMethods
      def template_paths; @template_paths ||= [] end
      
      def inherits(*templates)
        if templates.first.is_a?(Symbol) || templates.first.is_a?(String)
          mod = Templater.create_template(*templates)
          include mod
          template_paths.push(*mod.template_paths)
        else
          include(*templates)
        end
      end

      def sections(*new_sections)
        if new_sections.empty? 
          @sections 
        elsif new_sections.size == 1 && new_sections.first.is_a?(Array)
          @sections = new_sections.first
        else
          @sections = new_sections
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end