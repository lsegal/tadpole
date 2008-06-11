require "benchmark"
require File.dirname(__FILE__) + '/../lib/templater'

Templater.register_template_path File.dirname(__FILE__) + '/../examples/example2'

TESTS = 100

Benchmark.bmbm do |b|
  b.report("no-cache") do 
    Templater.caching = false
    t = Templater('treate/html/readme').new
    TESTS.times { t.run }
  end

  b.report("cache   ") do 
    Templater.caching = true
    t = Templater('treate/html/readme').new
    TESTS.times { t.run }
  end
end