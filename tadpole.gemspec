SPEC = Gem::Specification.new do |s|
  s.name          = "tadpole"
  s.version       = "0.1.0"
  s.date          = "2008-05-13"
  s.author        = "Loren Segal"
  s.email         = "lsegal@soen.ca"
  s.homepage      = "http://www.soen.ca"
  s.platform      = Gem::Platform::RUBY
  s.summary       = "A Small but Extensible Templating Engine for Ruby" 
  s.files         = Dir.glob("{lib,spec,benchmarks,examples}/**/*") + ['LICENSE.txt', 'README.html', 'README.markdown']
  s.require_paths = ['lib']
  s.has_rdoc      = false
  s.rubyforge_project = 'tadpole'
end