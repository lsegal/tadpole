inherits 'treate/markdown'

def init
  super
  sections.place('readme_notice').before('copyright')
end