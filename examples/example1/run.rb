require File.dirname(__FILE__) + '/../../lib/tadpole'

Tadpole.register_template_path File.dirname(__FILE__)

myobj = "Tadpole!"
puts Tadpole(:custom, :html).run(:object => myobj)