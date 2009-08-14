require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

describe Tadpole, '::Template' do
  before do
    Tadpole.template_paths.clear
    Tadpole.register_template_path File.dirname(__FILE__) + '/examples' 
  end
  
  it "should yield with extra values" do
    Template('yield').new.run.should == '[FOOBARBAR]'
  end
end
