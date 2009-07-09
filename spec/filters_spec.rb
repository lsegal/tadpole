require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

describe Tadpole::Filters do
  before do
    Tadpole.template_paths.clear
    Tadpole.register_template_path File.dirname(__FILE__) + '/examples' 
  end
  
  it "should allow filters specified directly in LocalTemplate" do
    eval "module Tadpole::LocalTemplate; before_run :xyz end"
    
    File.should_receive(:directory?).at_least(:once).and_return(true)
    obj = Template('a/b/c/d').new
    obj.should_receive(:xyz)
    obj.sections []
    obj.run
    Tadpole::LocalTemplate.before_run_filters.clear
  end
  
  describe '#before_run' do
    it "should call filter" do
      Template(:filters).before_run_filters.size.should == 2
      obj = Template(:filters).new
      obj.should_receive(:test)
      obj.run
    end
    
    it "should take a block" do
      Template(:filters).before_run_filters.last.should be_kind_of(Proc)
    end
  end
  
  describe '#before_section' do
    it "should call filter for specific section" do
      obj = Template(:filters).new
      obj.should_receive(:run_a).with('a')
      obj.run
    end

    it "should call filter for all sections" do
      obj = Template(:filters).new
      obj.should_receive(:all).exactly(2).times
      obj.run
    end
  
    it "should take a block for a specific section" do
      filter = Template(:filters).before_section_filters[3]
      filter[0].should == :b
      filter[1].should be_kind_of(Proc)
    end

    it "should take a block for a all sections" do
      filter = Template(:filters).before_section_filters[2]
      filter[0].should == nil
      filter[1].should be_kind_of(Proc)
    end
  end

end