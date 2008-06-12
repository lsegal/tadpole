Tadpole: Revolutionizing Templates in Ruby
==========================================

_Created by [Loren Segal](http://www.gnuu.org) in 2008_

Quick How-To's
--------------

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
        Tadpole('mytemplate').run### Override a Template

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
    Tadpole('mytemplate').run### Heirarchical Sections

Sometimes you may need to encapsulate the output of some sections inside another one. An HTML
template, for example, will usually contain the page body inside the body tag of a more general
"header" template. To set this up, you use the following `sections` call:

    sections 'header', ['section1', 'section2', 'copyright']
    
You can then call these from your `header.erb` file as simple yields. Each yield renders
one section in the sub-list:

    <html>
      <body>
        <h1>Section 1</h1>
        <%= yield %>
        
        <h1>Section 2</h1>
        <%= yield %>
        
        <h1>Copyright</h1>
        <%= yield %>
      </body>
    </html>
    
Alternatively you can yield all sub-sections with the convenience call `all_sections` 
(in the following [Haml](http://haml.hamptoncatlin.com) example, yield param 's' 
contains the section name which would serve as the li's id attribute):

    %html
      %body
        %ol
          - all_sections do |s|
            %li{:id => s}= yield
    
    
What is Tadpole?
----------------

**Tadpole** is a small templating engine that attempts to solve a problem that
no other templating engine does: _extensibility_. When dealing with templates,
most engines focus on the formatting of the output content while forgetting about
the important task a developer faces of hooking all these 'views' together. While
it may seem trivial and worth ignoring, in reality, many templates become plagued
with complexity and coupling due to the lack of support beyond the mere presentation
of a single file.

**Tadpole** deals not with the formatting or translation or markup, but rather
with the organization of the data as it is outputted. In fact, **Tadpole** is not
markup at all, nor does it care what markup you use, having out of the box support
for the obvious template languages in Ruby (ERB, [Haml](http://www.haml.hamptoncatlin.com), 
[Markaby](http://code.whytheluckystiff.net/markaby), [Builder](http://builder.rubyforge.org)) 
and the ability to add more. **Tadpole is all about information organization, not formatting**.

If you need a good visualization of what **Tadpole** is, think of it as _the table of_
_contents for your views_. Just as it is important to designing each view and partial of
your template, it is important to decide in what order these views will ultimately be 
organized. **Tadpole**'s job is to store nothing but your table of contents, and then
spit it out when you're ready to show it to the world. This technique becomes very 
powerful in some potentially familiar scenarios. (_See the "Real World Examples"_)

Why Tadpole?
------------

Sufficed to say, you might be wondering what the _big deal_ is. I mean, you're 
probably getting along just fine without this new concept of tables of contents
..._or so you think_. The truth is that there are a lot of real-world scenarios
where the old-style template production simply doesn't cut it. I can say this
because **Tadpole** was [born from one of them](http://www.github.com/lsegal/yard).

I'll be honest, **Tadpole** does not meet every use-case scenario, and it probably
never will. But if you're writing a _blog app_, _CMS_, customizable _forum software_ or
anything that will eventually support _customizable templates_ or _theming_, 
_**Tadpole** was made for you_. Even if you're just dealing with a lot of _template_
_coupling_ or _internationalization code_, there's a good chance you're looking at the 
right tool as well.

### Good With Customizable Themes, You Say?

Anyone who writes customizable software knows that it requires a lot of de-coupled code.
While templates are sometimes considered support files rather than actual software, the
same law holds true for them. Coupled templates are bad for theming because your users
can't get at the data they want.

The standard solution to this problem is to split your templates up into many 'partials'. 
That way, any user can just go into the right partial and easily edit what they need
without copying _all_ of the template data, right? __Wrong__. The problem starts when a 
user wants to start adding or removing partials altogether. In fact, it's actually the
smallest changes that cause the biggest problems. Everytime they add one line to every
new partial, they pull in another entire file. Once _you_ update that file, the changes 
no longer sync to the user. Fixed a typo in your template? Your user may never get the
memo if he pulled in the file you touched. However, because **Tadpole** never actually
deals with template _data_, the same setup in **Tadpole** would not be problematic.
Using **Tadpole**, the user would never even have to touch your templates given a good 
set of insertion points.

The lesson is, when it comes to customization, there is no partial that is partial enough.
**Tadpole** inevitably suffers from this problem as well. However, once you start thinking
in terms of template organization you'll find that it's much harder to decide what part
of a view deserves a 'partial' than it is to simply split your template up into a series
of cohesive "_sections_".

Some _Theoretically_-Real-World Examples of Tadpole in Action
-----------------------------------------------------------

1.  _Bob_ made a Blogging application called _"Boblog"_ and distributed it under the
    MIT license over the internet. _Janet_ found this application and decided to 
    use it to power her upcoming "100 Carrot Recipes" blog. She was mostly happy with
    the provided themes but wanted to customize the look of the sidebar by adding a
    "Favourite Recipes" links section and writing a tidbit about herself. Now "Boblog"
    was a simplistic blog tool and did not support a multitude of plugins, but did use
    **Tadpole** for theming. Janet read about the way customization was done using "Boblog"
    and got to work making her changes. Janet went into her custom templates directory and 
    created her own new template `janet` because she had a bad feeling about directly playing 
    with the existing template files (_and "Boblog" docs said she didn't need to_). Inside
    that directory she created her new files `fav_recipes.html` and `about.html` where she 
    inserted her links to various world renowned Carrot Chefs and a story about her dreams
    of one day meeting them. Now, she wanted her about section to go at the top of the sidebar,
    but she wanted her own links section to go beneath the regular links section (already
    provided by "Boblog"). So, as per the docs, she continued to add a `setup.rb` file which
    would connect her new files together with the template. In this file, she simply wrote:
    
        inherits 'default_theme'
        
        def init
          super
          sections.unshift 'about'
          sections.place('fav_recipes').before('links')
        end
        
    She then went into "Boblog"'s administration interface and selected the new `janet` 
    theme. Voila, her dream of tasty success would finally come true.
    
    Three days later, _Bob_ got word from an anonymous tipster of a nasty bug in his software 
    that could potentially lead to harmful attacks if left unfixed. Guess what, that bug was 
    in the sidebar template that Janet was using! He quickly patched the bug and released a 
    fix, notifying all of his users of the changes (Janet was on his mailing list). Because 
    Janet never edited any of the files belonging to "Boblog", all she had to do was download 
    the patch and restart the application without ever having to remake all of her ever-so-
    important theming changes to her blog.
    
2.  Midget Inc. is working on a colourful new site redesign for their mobile widget business.
    They sell mobile widgets to customers all across the globe and have very strict legal 
    procedures they need to follow when advertising their mobile widgets. In one specific
    region, they are required by law to show a disclaimer above any advertising images they
    display. Rather than place region specific logic inside a partial view, they decide to
    use **Tadpole** to handle their templating system. They decide to use a folder structure
    of the following to display their advertising page:
    
        advertising/
          setup.rb
          content.erb
          images.erb
          fr/
            setup.rb
            disclaimer.erb
          
    `advertising/setup.rb` contains the following:
    
        def init; super; sections 'content', 'images' end
        
    The `fr/` subdirectory contains the specific content they need for the law-requiring region
    and the logic to render this template only in that region is controlled by the controller. 
    Because the `fr/` template automatically inherits its sections from its parent, all they need 
    to do to set up this new logic is put the following in the `fr/setup.rb`:
    
        def init
          super
          sections.place('disclaimer').before('images')
        end
        
    And the templates can be rendered with:
    
        Tadpole('advertising').run
        Tadpole('advertising/fr').run
        
    Respectively.
    
You Should Also Know
--------------------

That this `README` was generated by **Tadpole**. Try it:

    ruby examples/example2/run.rb markdown/readme

Copyright & Licensing Information
---------------------------------

_Copyright 2008 Loren Segal._
_All code licensed under the MIT License._
