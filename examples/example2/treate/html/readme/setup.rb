inherits 'treate/html'
inherits 'treate/markdown/readme'

def init
  super
  sections[1][2].push('readme_notice')
end