module Tadpole
  module SectionProviders
    class HamlProvider < SectionProvider
      EXTENSIONS = ['.haml']
      
      def initialize(full_path, owner)
        super

        require 'haml'
        @haml = Haml::Engine.new(content)
      end
      
      def render(locals = {}, &block)
        @haml.render(owner, locals, &block)
      end
    end
  end
end