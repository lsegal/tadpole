def init
  sections :a, [:b, [:c, :d]]
end

def a
  '[' + yield(:foo => 'FOO') + ']'
end

def b
  foo + yieldall(:foo => 'BAR', :bar => 'BAR')
end

def c
  foo
end

def d
  bar
end

# expected [FOOBARBAR]