before_run :test
before_run { 2 + 2 }
before_section :a, :run_a
before_section :all
before { 2 + 2 }
before(:b) { 2 + 2 }

def test; end
def run_a; end
def all(section) end
  
def init; sections 'a', 'b' end
