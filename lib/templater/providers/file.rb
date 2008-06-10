module Templater
  module SectionProviders
    class FileProvider < SectionProvider
      def render(locals = nil); content end
    end
  end
end