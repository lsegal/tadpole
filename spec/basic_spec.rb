require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

Tadpole.caching = false

describe Tadpole do
  before { Tadpole.template_paths.clear }

  it "should be an alias to Tadpole.template" do
    Tadpole.should_receive(:template).with(:x, :y, :z)
    Tadpole(:x, :y, :z) 
  end
  
  describe '.create_template' do
    it "should create a template that does not exist on disk" do
      template = Tadpole.create_template('x/y/z')
      template.ancestors.should include(Tadpole::Template)
      template.path.should == 'x/y/z'
    end
    
    it "should inherit templates with same path" do
      module Tadpole::LocalTemplate_x_y; end
      File.should_receive(:directory?).with('./x').and_return(true)
      File.should_receive(:directory?).with('./x/y').and_return(false)
      Tadpole.register_template_path '.'
      template = Tadpole.create_template('x/y')
      template.ancestors.should_not include(Tadpole::LocalTemplate_x_y)
      template.ancestors.should include(Tadpole::LocalTemplate_x)
    end
    
    it "should allow sections to be set programmatically" do
      mod = Tadpole.create_template('mine')
      template = mod.new
      template.class.should == Tadpole::Template_mine
      class << template
        def a; 'a' end
        def b; 'b' end
        def c; 'c' end
      end
      template.sections :a, :b, :c
      template.run.should == 'abc'
    end
  end

  describe '.template' do
    it "should raise ArgumentError if path does not exist in template_paths" do
      lambda { Tadpole(:x, :y, :z) }.should raise_error(ArgumentError)
    end
  
    it "should create the module with the path name" do
      Tadpole.register_template_path ''
      File.should_receive(:directory?).exactly(3).times.and_return(true)
      Tadpole('default/html')
      symbolized_consts = Tadpole.constants.map {|c| c.to_sym }
      symbolized_consts.should include(:Template_default_html)
      symbolized_consts.should include(:LocalTemplate_default_html)
      symbolized_consts.should include(:LocalTemplate_default)
    end
  
    it "should override templates from other template paths" do
      Tadpole.register_template_path 'a'
      Tadpole.register_template_path 'b'
      File.should_receive(:directory?).exactly(6).times.and_return(true)
      Tadpole(:new, :template)
      symbolized_consts = Tadpole.constants.map {|c| c.to_sym }
      symbolized_consts.should include(:Template_new_template)
      symbolized_consts.should include(:LocalTemplate_a_new_template)
      symbolized_consts.should include(:LocalTemplate_a_new)
      symbolized_consts.should include(:LocalTemplate_b_new_template)
      symbolized_consts.should include(:LocalTemplate_b_new)
      Tadpole::Template_new_template.ancestors.should == [Tadpole::Template_new_template, 
        Tadpole::LocalTemplate_b_new_template, Tadpole::LocalTemplate_a_new_template, 
        Tadpole::LocalTemplate_b_new, Tadpole::LocalTemplate_a_new, Tadpole::LocalTemplate,
        Tadpole::Template]
    end
  end
end

describe Tadpole::Template do
  before do
    Tadpole.template_paths.clear
    Tadpole.register_template_path '.'
  end

  it "should act as a class (have a .new, #inspect, etc.)" do
    File.should_receive(:directory?).with('./default/html').and_return(true)
    mod = Tadpole(:default, :html)
    mod.should respond_to(:new)
    template = mod.new
    Tadpole::Template.should === template
    template.inspect.should =~ /#<Template:(\S+) path='default\/html' sections=nil>/
    template.class.should == Tadpole::Template_default_html
  end
  
  it "should create two template modules for the same template in separate template paths" do
    
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
