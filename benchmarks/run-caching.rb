require "benchmark"
require File.dirname(__FILE__) + '/../lib/tadpole'

Tadpole.register_template_path File.dirname(__FILE__) + '/../examples/example1'

TESTS = 1

Benchmark.bm do |b|
  b.report("no-cache") do 
    Tadpole.caching = false
    t = Tadpole('custom/html').new
    TESTS.times { t.run(:object => 1) }
  end

  b.report("cache   ") do 
    Tadpole.caching = true
    t = Tadpole('custom/html').new
    TESTS.times { t.run(:object => 1) }
  end
end