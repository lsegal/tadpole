def init
  sections :a, [:b, [:c, :d]]
end

def a
  '[' + yield(:foo => 'FOO') + ']'
end

def b
  foo + yieldall(:bar => 'BAR')
end

def c
  bar
end

def d
  bar
end

# expected [FOOBARBAR]