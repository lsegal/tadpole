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

