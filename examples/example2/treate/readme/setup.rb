inherits 'treate/markdown'

def init
  super
  sections.insert_before('copyright', 'readme_notice')
end