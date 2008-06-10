require File.dirname(__FILE__) + '/../../lib/templater'

Templater.register_template_path File.dirname(__FILE__)

myobj = "Treate!"
puts T(:custom, :html).run(:object => myobj)