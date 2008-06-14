def init
  sections 'a', ['b', 'c']
end

def a
  'x' + yield + yield + yield
end

def b
  'y'
end

def c
  'z'
end

# Expected: xyzy