def init
  sections :a
end

def a
  render('_a', :a_variable => 2)
end