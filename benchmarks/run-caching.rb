require "benchmark"
require File.dirname(__FILE__) + '/../lib/tadpole'

Tadpole.register_template_path File.dirname(__FILE__) + '/../examples/example2'

TESTS = 100

Benchmark.bmbm do |b|
  b.report("no-cache") do 
    Tadpole.caching = false
    t = Tadpole('tadpole/html/readme').new
    TESTS.times { t.run }
  end

  b.report("cache   ") do 
    Tadpole.caching = true
    t = Tadpole('tadpole/html/readme').new
    TESTS.times { t.run }
  end
end