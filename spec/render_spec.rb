require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

describe Tadpole, '::Template' do
  before do
    Tadpole.template_paths.clear
    Tadpole.register_template_path File.dirname(__FILE__) + '/examples' 
  end
  
  it "should render sections in order" do
    Template('render/1').new.run.should == 'xyz1'
  end
  
  it "should render heirarchical sections" do
    Template('render/2').new.run.should == '{([])}'
  end
  
  it "should render heirarchical sections and then continue rendering in order" do
    Template('render/3').new.run.should == '{([])}abc'
  end
end