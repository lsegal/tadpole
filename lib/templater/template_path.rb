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
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end