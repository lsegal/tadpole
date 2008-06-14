require "benchmark"

TIMES = 10_000

module A
  Benchmark.bmbm do |x|
    x.report("eval")          { TIMES.times { eval("x = 2", binding) } }
    x.report("instance-eval") { TIMES.times { instance_eval "x = 2" } }
    x.report("module-eval")   { TIMES.times { module_eval "x = 2"} }
    x.report("class-eval")    { TIMES.times { class_eval "x = 2"} }
    x.report("non-eval")      { TIMES.times { x = 2 } }
  end
end