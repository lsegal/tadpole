sections 'info.erb', :copyright

def copyright; "<div id='copyright'>Copyright 2008 Loren Segal</div>" end

def helper_method
  [1,2,3,4,5].each do |num|
    yield num
  end
end