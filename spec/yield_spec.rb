require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

describe Tadpole, '::Template' do
  before do
    Tadpole.template_paths.clear
    Tadpole.register_template_path File.dirname(__FILE__) + '/examples' 
  end
  
  it "should yield to a method with extra values" do
    Template('yield/1').new.run.should == '[FOOBARBAR]'
  end
  
  it "should yield to external template with extra values" do
    Template('yield/2').new(:foo => 'FOO').run.should == 'BARBAR'
  end
end
