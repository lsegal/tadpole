before_run :test
before_section :a, :run_a
before_section :all

def test; end
def run_a; end
def all(section) end
  
def init; sections 'a', 'b' end
