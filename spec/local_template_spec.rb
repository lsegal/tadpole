require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

describe Tadpole::LocalTemplate do
  before do
    Tadpole.template_paths.clear
    Tadpole.register_template_path(File.dirname(__FILE__) + '/examples')
  end
  
  describe '.inherits' do
    it "should inherit from a relative path" do
      Tadpole('inherits/inherits_b').run.should == "abc"
    end
    
    it "should automatically inherit parent directories" do
      Tadpole('inherits/inherits_b/inherits_c').run.should == "abcd"
    end
    
    it "should inherit absolute paths from top of registered template paths" do
      Tadpole('inherits/inherits_d').run.should == "ab"
    end
    
    it "should order template_paths properly" do
      paths = Tadpole('inherits/inherits_b/inherits_c').template_paths
      paths.map! {|p| p.gsub(Tadpole.template_paths.first + '/', '') }
      paths.should == ["inherits/inherits_b/inherits_c", "inherits/inherits_b", "inherits/inherits_a", "inherits"]
    end
    
    it "should accept multiple inheritances" do
      paths = Tadpole('inherits/inherits_e').template_paths
      paths.map! {|p| p.gsub(Tadpole.template_paths.first + '/', '') }
      paths.should == ["inherits/inherits_e", "inherits/inherits_b", "inherits/inherits_a", "inherits"]
    end
  end
  
  describe '.T' do
    it "should refer to a template" do
      Tadpole('T').run.should == 'info'
    end
    
    it "should refer to the same template path even in a subclass" do
      Tadpole('T/derived').run.should == 'info'
    end
    
    it "should refer to the subclassed path if the section exists in the subclass" do
      Tadpole('T/derived2').run.should == 'notinfo'
    end
  end
end
