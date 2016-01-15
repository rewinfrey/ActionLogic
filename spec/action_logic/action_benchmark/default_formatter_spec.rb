require 'spec_helper'

module ActionLogic::ActionBenchmark
  describe DefaultFormatter do

    let(:benchmark_log) { StringIO.new }
    let(:benchmark_result) { double(:benchmark_result, utime: 0.00003, stime: 0.00002, total: 0.00001, real: 0.00030) }

    subject { described_class.new(benchmark_log: benchmark_log) }

    it "writes the benchmark result to the log for an ActionCoordinator" do
      subject.coordinator(benchmark_result, "CoordinatorContext")
      expect(benchmark_log.string).to\
        eq "context:   CoordinatorContext                                 user_time: 0.000030   system_time: 0.000020   total_time: 0.000010   real_time: 0.000300  \n"
    end

    it "writes the benchmark result to the log for an ActionUseCase" do
      subject.coordinator(benchmark_result, "UseCaseContext")
      expect(benchmark_log.string).to\
        eq "context:   UseCaseContext                                     user_time: 0.000030   system_time: 0.000020   total_time: 0.000010   real_time: 0.000300  \n"
    end

    it "writes the benchmark result to the log for an ActionTask" do
      subject.coordinator(benchmark_result, "TaskContext")
      expect(benchmark_log.string).to\
        eq "context:   TaskContext                                        user_time: 0.000030   system_time: 0.000020   total_time: 0.000010   real_time: 0.000300  \n"
    end
  end
end
