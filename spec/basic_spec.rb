require File.join(File.dirname(__FILE__), '..', 'lib', 'templater')

Templater.caching = false

describe 'Templater' do
  it "should be an alias to Templater.template" do
    Templater.should_receive(:template).with(:x, :y, :z)
    Templater(:x, :y, :z) 
  end
end

describe Templater, '.template' do
  before { Templater.template_paths.clear }
  
  it "should raise ArgumentError if path does not exist in template_paths" do
    lambda { Templater(:x, :y, :z) }.should raise_error(ArgumentError)
  end
  
  it "should create the module with the path name" do
    Templater.register_template_path ''
    File.should_receive(:directory?).exactly(3).times.and_return(true)
    Templater('default/html')
    Templater.constants.should include("Template_default_html")
    Templater.constants.should include("LocalTemplate_default_html")
    Templater.constants.should include("LocalTemplate_default")
  end
  
  it "should override templates from other template paths" do
    Templater.register_template_path 'a'
    Templater.register_template_path 'b'
    File.should_receive(:directory?).exactly(6).times.and_return(true)
    Templater(:new, :template)
    Templater.constants.should include("Template_new_template")
    Templater.constants.should include("LocalTemplate_a_new_template")
    Templater.constants.should include("LocalTemplate_a_new")
    Templater.constants.should include("LocalTemplate_b_new_template")
    Templater.constants.should include("LocalTemplate_b_new")
    Templater::Template_new_template.ancestors.should == [Templater::Template_new_template, 
      Templater::LocalTemplate_b_new_template, Templater::LocalTemplate_a_new_template, 
      Templater::LocalTemplate_b_new, Templater::LocalTemplate_a_new, Templater::TemplatePath,
      Templater::Template]
  end
end

describe Templater, "::Template" do
  it "should act as a class (have a .new, #inspect, etc.)" do
    #File.should_receive(:directory?).and_return(true)
    #Templater.caching = false
    Templater(:default, :html).should respond_to(:new)
    Templater::Template.should === Templater(:default, :html).new
    #Templater.caching = false
  end
  
  it "should #run with Symbol sections as methods" do
    File.should_receive(:directory?).at_least(1).times.and_return(true)
    obj = Templater(:x, :q).new
    obj.stub!(:sections).and_return([:a, :b, :c])
    obj.should_receive(:a).and_return('X')
    obj.should_receive(:b).and_return('Y')
    obj.should_receive(:c).and_return('Z')
    obj.run.should == 'XYZ'
  end

  it "should #run with Symbol sections as templates" do
    File.should_receive(:directory?).at_least(1).times.and_return(true)
    qr, qs = Templater(:Q,:R).new, Templater(:Q, :S).new
    Templater(:Q, :R).should_receive(:new).and_return(qr)
    Templater(:Q, :S).should_receive(:new).and_return(qs)
    obj = Templater(:Q).new
    obj.stub!(:sections).and_return([:a, :R, :S])
    obj.should_receive(:a).and_return('X')
    qr.should_receive(:run).and_return('Y')
    qs.should_receive(:run).and_return('Z')
    obj.run.should == 'XYZ'
  end
  
  it "should alias .run as new.run" do
    File.should_receive(:directory?).at_least(1).times.and_return(true)
    obj = mock(:obj)
    obj.stub!(:run)
    Templater(:s).should_receive(:new).and_return(obj)
    Templater(:s).run
  end
end
