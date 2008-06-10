module Templater
  module SectionProviders
    class ERBProvider < SectionProvider
      def initialize(content, owner)
        super

        require 'erb'
        erb = ERB.new(content, nil, '<>')
        instance_eval "def render(locals = nil); #{@erb.src} end"
      end
      
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