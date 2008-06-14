module Tadpole
  module TemplatePath
    module ClassMethods
      attr_accessor :path
      def template_paths; @template_paths ||= [] end
      
      def inherits(*templates)
        templates.each do |template|
          p = template.to_s[0,1] == '/' ? [template.to_s[1..-1]] : [path, template]
          mod = Tadpole.template(*p)
          include mod
          template_paths.push(*mod.template_paths)
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
      klass.extend Filters::ClassMethods
    end
    
    def T(extra_path, extra_opts = {})
      opts = options.to_hash.update(extra_opts)
      Template(path, extra_path).new(opts)
    end
  end
end