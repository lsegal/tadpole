module Tadpole
  module LocalTemplate
    module ClassMethods
      attr_accessor :path
      def template_paths; @template_paths ||= [] end
      def inherited_paths; @inherited_paths ||= [] end
      
      def inherits(*templates)
        templates.each do |template|
          p = template.to_s[0,1] == '/' ? [template.to_s[1..-1]] : [path, template]
          mod = Tadpole.template(*p)
          include mod
          before_run_filters.push(*mod.before_run_filters)
          before_section_filters.push(*mod.before_section_filters)
          inherited_paths.unshift(*mod.template_paths)
        end
      end
    end

    def self.included(klass)
      klass.extend ClassMethods
      klass.extend Filters::ClassMethods
    end
    
    def T(extra_path, extra_opts = {})
      opts = options.to_hash.update(extra_opts)
      dirname = File.dirname(caller.first[/^(.+?):/, 1])
      begin
        Template(path, extra_path).new(opts)
      rescue MissingTemplateError => e
        Tadpole.template_paths.each do |template_path|
          if dirname.index(template_path) == 0
            path = dirname[template_path.length..-1]
            return Template(path, extra_path).new(opts)
          end
        end
        raise e
      end
    end
    
    included(self)
  end
end