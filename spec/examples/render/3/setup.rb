def init
  sections :a, [:b, [:c]], :x, :y, :z
end

def a; '{' + yield + '}' end
def b; '(' + yield + ')' end
def c; '[]' end
def x; 'a' end
def y; 'b' end
def z; 'c' end

# Expected: {([])}abc