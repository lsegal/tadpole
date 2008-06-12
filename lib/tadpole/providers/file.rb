module Tadpole
  module SectionProviders
    class FileProvider < SectionProvider
      EXTENSIONS = ['.txt', '.html', '.textile', '.md', '.markdown', 'markdn', '']

      def render(locals = nil); content end
    end
  end
end