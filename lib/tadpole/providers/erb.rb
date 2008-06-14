module Tadpole
  module SectionProviders
    class ERBProvider < SectionProvider
      EXTENSIONS = ['.erb']
      
      def initialize(full_path, owner)
        super

        require 'erb'
        erb = ERB.new(content, nil, '<>')
        instance_eval(<<-eof, full_path, -1)
          def render(locals = nil)
            eval(locals.map {|k,v| "\#{k} = \#{v.inspect}" }.join(';')) if locals
            #{erb.src} 
          end
        eof
      end
    end
  end
end