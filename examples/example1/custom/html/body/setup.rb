inherits 'default/html/body'

def init(object)
  super
  sections[1,0] = asset('important.html')
end