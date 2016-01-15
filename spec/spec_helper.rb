require 'simplecov'
SimpleCov.start

require 'coveralls'
Coveralls.wear!

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'action_logic'

if ENV['BENCHMARK']
  ActionLogic::ActionConfiguration.configure do |config|
    config.benchmark = true
    config.benchmark_log = File.open("benchmark.log", "w")
  end
end

RSpec.configure do |c|
  c.fail_fast = true
  c.color = true
  c.formatter = 'documentation'
  c.order = 'rand'
end
