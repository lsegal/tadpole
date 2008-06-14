def init
  sections :a, [:b, [:c]]
end

def a; '{' + yield + '}' end
def b; '(' + yield + ')' end
def c; '[]' end

# Expected: {([])}