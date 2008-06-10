module Templater
  module SectionProviders
    class << self
      def providers
        @providers ||= {}
      end

      def register_provider(prov)
        prov.each do |k, v|
          providers.update(k.to_sym => v)
        end
      end

      def default_provider(ext = nil)
        if ext
          if providers.has_key? ext
            @default_provider = providers[ext]
          else
            raise ArgumentError, "no such provider `#{ext}'"
          end
        else
          @default_provider
        end
      end
    end
    
    class SectionProvider
      attr_accessor :owner, :content
      
      # @abstract
      def render(locals = {}, &block) 
        raise NotImplementedError, "abstract class"
      end
        
      def initialize(content, owner = nil)
        self.owner = owner
        self.content = content
      end
    end

    register_provider  :erb     => ERBProvider,
                       :haml    => HamlProvider,
                       :markaby => MarkabyProvider,
                       :file    => FileProvider
    default_provider   :file
  end
end