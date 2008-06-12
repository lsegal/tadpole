module Tadpole
  module SectionProviders
    class << self
      def providers
        @providers ||= []
      end

      def register_provider(*provs)
        providers.push(*provs)
      end
    end
    
    class SectionProvider
      attr_accessor :owner, :content
      
      EXTENSIONS = []
      
      # You don't need to override this method unless
      # you need custom functionality beyond checking
      # if a file exists under one of the possible file 
      # extensions.
      # 
      # @return [String, nil] The full pathname
      def self.provides?(basename) 
        self.const_get("EXTENSIONS").any? do |ext|
          path = basename + ext
          return path if path_suitable?(path) 
        end
        nil
      end
      
      # Override this if you want to provide another
      # mechanism to detect that the path is suitable
      # for use. Default just checks File.file?(full_path)
      def self.path_suitable?(full_path)
        File.file?(full_path)
      end
      
      # @abstract
      def render(locals = {}, &block) 
        raise NotImplementedError, "abstract class"
      end
        
      def initialize(full_path, owner = nil)
        self.owner = owner
        self.content = File.read(full_path)
      end
      
      def inspect; "#<%s:0x%s>" % [self.class.to_s.split('::').last, object_id.to_s(16)] end
      
      def method_missing(meth, *args, &block)
        if owner.respond_to?(meth)
          owner.send(meth, *args, &block)
        else
          super
        end
      end
    end
  end
end