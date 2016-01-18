require 'simplecov'
require 'coveralls'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'spec/fixtures'
end

require 'action_logic'

class CustomFormatter < ActionLogic::ActionBenchmark::DefaultFormatter
  def log_coordinator(benchmark_result, execution_context_name)
    benchmark_log.puts("The ActionCoordinator #{execution_context_name} took #{benchmark_result} to complete.")
  end

  def log_use_case(benchmark_result, execution_context_name)
    benchmark_log.puts("The ActionUseCase #{execution_context_name} took #{benchmark_result} to complete.")
  end

  def log_task(benchmark_result, execution_context_name)
    benchmark_log.puts("The ActionTask #{execution_context_name} took #{benchmark_result} to complete.")
  end
end

class CustomHandler
  def call
    yield
    "this is the custom handler"
  end
end

if ENV['BENCHMARK']
  ActionLogic.configure do |config|
    config.benchmark = true
    config.benchmark_log = File.open("benchmark.log", "w")
    config.benchmark_formatter = CustomFormatter
    config.benchmark_handler = CustomHandler.new
  end
end

RSpec.configure do |c|
  c.fail_fast = true
  c.color = true
  c.formatter = 'documentation'
  c.order = 'rand'
end
