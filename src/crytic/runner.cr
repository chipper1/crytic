require "./generator/**"
require "./msi_calculator"
require "./mutation/no_mutation"
require "./mutation/result"
require "./reporter/**"
require "./runner_argument_validator"
require "./subject"

module Crytic
  class Runner
    include RunnerArgumentValidator

    alias Threshold = Float64

    def initialize(
      @threshold : Threshold,
      @reporters : Array(Reporter::Reporter),
      @generator : Generator
    )
    end

    def run(source : Array(String), specs : Array(String)) : Bool
      validate_args!(source, specs)

      original_result = Mutation::NoMutation.with(specs).run
      @reporters.each(&.report_original_result(original_result))

      return false unless original_result.successful?

      mutations = @generator.mutations_for(source, specs)

      @reporters.each(&.report_mutations(mutations))

      results = Mutation::ResultSet.new(mutations.map do |mutation_set|
        mutation_set.neutral.run
        mutation_set.mutated.map do |mutation|
          result = mutation.run
          @reporters.each(&.report_result(result))
          result
        end
      end.flatten)

      @reporters.each(&.report_summary(results))
      @reporters.each(&.report_msi(results))

      MsiCalculator.new(results).msi.passes?(@threshold)
    end

    def run(source : String, specs : Array(String)) : Bool
      run([source], specs)
    end
  end
end
