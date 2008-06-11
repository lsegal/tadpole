require 'rubygems'

module Templater
  Version = '0.1.0'
  Root = File.dirname(__FILE__) + '/templater'
  
  module SectionProviders
    autoload :ERBProvider,      Root + '/providers/erb'
    autoload :FileProvider,     Root + '/providers/file'
    autoload :HamlProvider,     Root + '/providers/haml'
    autoload :MarkabyProvider,  Root + '/providers/markaby'
    autoload :TemplateProvider, Root + '/providers/template'
  end
  
  autoload :Template,     Root + '/template'
  autoload :TemplatePath, Root + '/template_path'
end

['main', 'providers/section_provider'].each do |path|
  require File.join(Templater::Root, path)
end

module Templater::SectionProviders
  register_provider TemplateProvider, ERBProvider, HamlProvider, FileProvider
end

    
