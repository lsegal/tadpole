### Create a Template

Creating a template is literally as easy as 1-2-3:

1. Create your templates in a directory. All directories are templates and all templates
are directories. The directory name will be the (or part of) the name of your template. 
Example for template `mytemplate`:

        templates/
          mytemplate/
            setup.rb
            section1.erb
            section2.haml
            copyright.html
      
2. Setup the "_table of contents_" of your sections in the `setup.rb`:

        def init
          super
          sections 'section1', 'section2', 'copyright'
        end
    
   Your sections can include another template (directory). This will call whatever
   sections were part of that other template.
   
   A directory does not _require_ a `section.rb`. If it is not supplied, it will inherit
   the setup file from its parent (including its sections).
    
3. Register the `templates` path as your root template directory and run the template:

        require 'tadpole'
        Tadpole.register_template_path 'path/to/templates'
        Tadpole('mytemplate').run