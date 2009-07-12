require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

describe Tadpole::SectionProviders::ERBProvider do
  before do
    Tadpole.template_paths.clear
    Tadpole.register_template_path(File.dirname(__FILE__) + '/examples')
  end

  describe '#render' do
    it "should setup locals through run" do
      Tadpole('erb').run(:a_variable => 1).should == '1'
    end
    
    it "should setup locals through #render" do
      Tadpole('erb2').run.should == '2'
    end
  end
end