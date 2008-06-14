begin require 'haml'; rescue LoadError; end 

module Tadpole
  module SectionProviders
    class HamlProvider < SectionProvider
      EXTENSIONS = ['.haml']
      
      def initialize(full_path, owner)
        super
        @haml = Haml::Engine.new(content)
      rescue NameError => e
        STDERR.puts "You're missing Haml! Install the gem with `gem install haml`."
        exit
      end
      
      def render(locals = {}, &block)
        @haml.render(owner, locals, &block)
      end
    end
  end
end