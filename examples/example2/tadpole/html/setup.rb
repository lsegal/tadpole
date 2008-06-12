inherits '../markdown'

def init
  super
  sections 'main', ['title', 'content', sections[1..-2], 'copyright']
end
