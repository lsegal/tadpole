def init(object)
  super
  sections erb('info.erb'), :copyright
end

def copyright; "Copyright 2008 Loren Segal" end

def helper_method
  [1,2,3,4,5].each do |num|
    yield num
  end
end