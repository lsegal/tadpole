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

