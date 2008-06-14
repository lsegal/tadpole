def init
  sections 'a', 'b', :c, 'd'
end

def c
  'z'
end

def d
  render('d', :value => '1')
end

# Expected: xyz1