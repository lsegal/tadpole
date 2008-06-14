def init
  sections 'a'
end

def a
  render 'a', :x => 1
end

# Expected: 123