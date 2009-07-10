require 'erb'

module Tadpole
  module SectionProviders
    class ERBProvider < SectionProvider
      EXTENSIONS = ['.erb']
      
      def initialize(full_path, owner)
        super

        erb = ERB.new(content, nil, '<>')
        instance_eval(<<-eof, full_path, -2)
          def render(locals = nil, &block)
            if locals
              opts = owner.options
              owner.options = owner.options.to_hash.update(locals)
            end
            out = owner.instance_eval #{erb.src.inspect}
            owner.options = opts if locals
            out
          end
        eof
      end
    end
  end
end