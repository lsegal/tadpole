require 'erb'

module Tadpole
  module SectionProviders
    class ERBProvider < SectionProvider
      EXTENSIONS = ['.erb']
      
      def initialize(full_path, owner)
        super

        erb = ERB.new(content, nil, '<>')
        instance_eval(<<-eof, full_path, -1)
          def render(locals = nil, &block)
            instance_eval(locals.map {|k,v| "\#{k} = locals[\#{k.inspect}]" }.join(';')) if locals
            instance_eval #{erb.src.inspect}
          end
        eof
      end
    end
  end
end