require 'erb'

module Tadpole
  module SectionProviders
    class ERBProvider < SectionProvider
      EXTENSIONS = ['.erb']
      
      def initialize(full_path, owner)
        super
        @erb = ERB.new(content, nil, '<>')
      end
      
      def render(locals = nil, &block)
        b = owner.instance_eval("binding")
        eval(locals.map {|k,v| "#{k} = locals[#{k.inspect}]" }.join(';'), b) if locals
        @erb.result(b)
      end
    end
  end
end