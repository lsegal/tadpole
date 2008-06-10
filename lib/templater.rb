require 'rubygems'

module Templater
  Root = File.dirname(__FILE__) + '/templater'
  
  module SectionProviders
    autoload :ERBProvider,      Root + '/providers/erb'
    autoload :FileProvider,     Root + '/providers/file'
    autoload :HamlProvider,     Root + '/providers/haml'
    autoload :MarkabyProvider,  Root + '/providers/markaby'
  end
  
  autoload :Template,     Root + '/template'
  autoload :TemplatePath, Root + '/template_path'
end

['main', 'providers/section_provider'].each do |path|
  require File.join(Templater::Root, path)
end

    
