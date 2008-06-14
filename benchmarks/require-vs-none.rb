require "benchmark"

TIMES = 10_000

Benchmark.bmbm do |x|
  x.report("require") { TIMES.times { require 'benchmark' } }
  x.report("none")    { TIMES.times { } }
end

# Conclusion: require is expensive.