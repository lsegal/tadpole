require File.join(File.dirname(__FILE__), '..', 'lib', 'tadpole')

describe Tadpole::Filters do
  before do
    Tadpole.template_paths.clear
    Tadpole.register_template_path File.dirname(__FILE__) + '/examples' 
  end
  
  it "should call before_run filter" do
    obj = Template(:filters).new
    obj.should_receive(:test)
    obj.run
  end

  it "should call before_section filter for specific section" do
    obj = Template(:filters).new
    obj.should_receive(:run_a).with('a')
    obj.run
  end

  it "should call before_section filter for all sections" do
    obj = Template(:filters).new
    obj.should_receive(:all).exactly(2).times
    obj.run
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
end