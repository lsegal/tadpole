module Templater
  module SectionProviders
    class FileProvider < SectionProvider
      EXTENSIONS = ['.txt', '.html', '']

      def render(locals = nil); content end
    end
  end
end