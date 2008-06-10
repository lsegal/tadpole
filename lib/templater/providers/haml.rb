module Templater
  module SectionProviders
    class HamlProvider < SectionProvider
      def initialize(content, owner)
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