### Override a Template

You can override templates by simply registering another template_path and creating
a template of the same name in the new path. Using the `mytemplate` example from above
we can now make a directory:

    custom_templates/
      mytemplate/
        setup.rb
        header.erb

This template will _inherit_ from the template above. Our `setup.rb` will therefore
contain:

    def init
      super
      sections.unshift 'header'
    end

And to run this file all we need to do is:

    require 'tadpole'
    Tadpole.register_template_path 'path/to/templates'         # Register base template path
    Tadpole.register_template_path 'path/to/custom_templates'  # Register overridden template path
    
    # Running our template will now add our 'header' file to the output
    Tadpole('mytemplate').run
    
