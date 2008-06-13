require 'rubygems'

module Tadpole
  Version = '0.1.0'
  Root = File.dirname(__FILE__) 
  
  module SectionProviders
    autoload :ERBProvider,      Root + '/tadpole/providers/erb'
    autoload :FileProvider,     Root + '/tadpole/providers/file'
    autoload :HamlProvider,     Root + '/tadpole/providers/haml'
    autoload :MarkabyProvider,  Root + '/tadpole/providers/markaby'
    autoload :TemplateProvider, Root + '/tadpole/providers/template'
  end
  
  module Filters
    autoload :ClassMethods,     Root + '/tadpole/filters'
    autoload :InstanceMethods,  Root + '/tadpole/filters'
  end
  
  autoload :Template,     Root + '/tadpole/template'
  autoload :TemplatePath, Root + '/tadpole/template_path'
end

['tadpole/main', 'tadpole/providers/section_provider'].each do |path|
  require File.join(Tadpole::Root, path)
end

module Tadpole::SectionProviders
  register_provider TemplateProvider, ERBProvider, HamlProvider, FileProvider
end

    
