require File.dirname(__FILE__) + '/../../lib/templater'

Templater.register_template_path File.dirname(__FILE__)

puts T(:treate, ARGV[0]||'html').run