module Tadpole
  module SectionProviders
    class TemplateProvider < SectionProvider
      EXTENSIONS = ['']
      
      def self.path_suitable?(full_path) File.directory?(full_path) end
      
      def initialize(full_path, owner)
        self.owner = owner
        self.full_path = full_path
        Tadpole.template_paths.each do |template_path|
          if full_path.index(template_path) == 0
            path = full_path[template_path.length..-1]
            @template = Tadpole(owner.path, path).new(owner.options)
          end
        end
        raise ArgumentError, "no template at `#{full_path}'" unless @template
      end
      
      def render(locals = {}, &block)
        @template.run(locals)
      end
    end
  end
end