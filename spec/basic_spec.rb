require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

Tadpole.caching = false

describe 'Tadpole' do
  before { Tadpole.template_paths.clear }

  it "should be an alias to Tadpole.template" do
    Tadpole.should_receive(:template).with(:x, :y, :z)
    Tadpole(:x, :y, :z) 
  end
end

describe Tadpole, '.template' do
  before { Tadpole.template_paths.clear }
  
  it "should raise ArgumentError if path does not exist in template_paths" do
    lambda { Tadpole(:x, :y, :z) }.should raise_error(ArgumentError)
  end
  
  it "should create the module with the path name" do
    Tadpole.register_template_path ''
    File.should_receive(:directory?).exactly(3).times.and_return(true)
    Tadpole('default/html')
    Tadpole.constants.should include("Template_default_html")
    Tadpole.constants.should include("LocalTemplate_default_html")
    Tadpole.constants.should include("LocalTemplate_default")
  end
  
  it "should override templates from other template paths" do
    Tadpole.register_template_path 'a'
    Tadpole.register_template_path 'b'
    File.should_receive(:directory?).exactly(6).times.and_return(true)
    Tadpole(:new, :template)
    Tadpole.constants.should include("Template_new_template")
    Tadpole.constants.should include("LocalTemplate_a_new_template")
    Tadpole.constants.should include("LocalTemplate_a_new")
    Tadpole.constants.should include("LocalTemplate_b_new_template")
    Tadpole.constants.should include("LocalTemplate_b_new")
    Tadpole::Template_new_template.ancestors.should == [Tadpole::Template_new_template, 
      Tadpole::LocalTemplate_b_new_template, Tadpole::LocalTemplate_a_new_template, 
      Tadpole::LocalTemplate_b_new, Tadpole::LocalTemplate_a_new, Tadpole::LocalTemplate,
      Tadpole::Template]
  end
end

describe Tadpole, "::Template" do
  before { Tadpole.template_paths.clear; Tadpole.register_template_path '.' }

  it "should act as a class (have a .new, #inspect, etc.)" do
    #File.should_receive(:directory?).and_return(true)
    #Tadpole.caching = false
    Tadpole(:default, :html).should respond_to(:new)
    Tadpole::Template.should === Tadpole(:default, :html).new
    #Tadpole.caching = false
  end
  
  it "should #run with Symbol sections as methods" do
    File.should_receive(:directory?).at_least(1).times.and_return(true)
    obj = Tadpole(:x, :q).new
    obj.stub!(:sections).and_return([:a, :b, :c])
    obj.should_receive(:a).and_return('X')
    obj.should_receive(:b).and_return('Y')
    obj.should_receive(:c).and_return('Z')
    obj.run.should == 'XYZ'
  end

  it "should #run with Symbol sections as templates" do
    File.should_receive(:directory?).at_least(1).times.and_return(true)
    qr, qs = Tadpole(:Q,:R).new, Tadpole(:Q, :S).new
    Tadpole(:Q, :R).should_receive(:new).and_return(qr)
    Tadpole(:Q, :S).should_receive(:new).and_return(qs)
    obj = Tadpole(:Q).new
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
    Tadpole(:s).should_receive(:new).and_return(obj)
    Tadpole(:s).run
  end
end
