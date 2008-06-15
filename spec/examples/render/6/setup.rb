def init
  sections [:a, [:b, [:c, :d], :e, :f]]
end

def a; 'A' + yieldall + 'G' end
def b; 'B(' + subsections.map {|x| section_name(x).upcase }.join + ')' end
def c; 'XXX' end
def d; 'XXX' end
def e; 'E' end
def f; 'F' end

# Expected: AB(CD)EFG