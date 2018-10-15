module Crytic
  class Generator
    MUTANT_POSSIBILITIES = [
      Mutant::ConditionFlipPossibilities.new,
      Mutant::NumberLiteralChangePossibilities.new,
      Mutant::NumberLiteralSignFlipPossibilities.new,
      Mutant::BoolLiteralFlipPossibilities.new,
    ]

    def mutations_for(source : String, specs : Array(String))
      ast = Crystal::Parser.parse(File.read(source))

      results = MUTANT_POSSIBILITIES.map do |inspector|
        ast.accept(inspector)
        inspector
      end.select(&.any?).map do |inspector|
        inspector.locations.map do |location|
          Mutation::Mutation
            .with(mutant: inspector.mutant_class.at(location: location),
                  original: source,
                  specs: specs)
        end
      end.flatten
    end
  end
end