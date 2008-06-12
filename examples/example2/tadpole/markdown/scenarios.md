Some Theoretically-Real-World-Examples of Tadpole in Action
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
    
    Three days later, _Bob_ got word of a nasty bug in his software that could potentially
    lead to harmful attacks if left unfixed. Guess what, that bug was in the sidebar template
    that Janet was using He quickly patched the bug and released a fix, notifying all of his 
    users of the changes (Janet was on his mailing list). Because Janet never edited any of 
    the files belonging to "Boblog", all she had to do was download the patch and restart
    the application without ever having to remake all of her ever-so-important theming changes to
    her blog.
    
    