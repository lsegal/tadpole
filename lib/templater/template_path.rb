module Templater
  module TemplatePath
    module ClassMethods
      attr_accessor :path
      def template_paths; @template_paths ||= [] end
      
      def inherits(*templates)
        templates.each do |template|
          mod = Templater.template(template)
          include mod
          template_paths.push(*mod.template_paths)
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
    end
  end
end