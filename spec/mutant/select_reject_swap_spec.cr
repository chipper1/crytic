require "../../src/crytic/mutant/select_reject_swap"
require "../../src/crytic/mutant/select_reject_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::SelectRejectSwap do
    it "switches select calls for reject calls" do
      ast = Crystal::Parser.parse("[1].select(&.nil?)")
      transformed = ast.transform(Mutant::SelectRejectSwap.at(location_at(
        line_number: 1, column_number: 1, name_column_number: 5)))
      transformed.to_s.should eq "[1].reject do |__arg0|\n  __arg0.nil?\nend"
    end

    it "switches reject calls for select calls" do
      ast = Crystal::Parser.parse("[1].reject(&.nil?)")
      transformed = ast.transform(Mutant::SelectRejectSwap.at(location_at(
        line_number: 1, column_number: 1, name_column_number: 5)))
      transformed.to_s.should eq "[1].select do |__arg0|\n  __arg0.nil?\nend"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("[1].select(&.nil?)")
      transformed = ast.transform(Mutant::SelectRejectSwap.at(location_at(
        line_number: 100,
        column_number: 100)))
      transformed.to_s.should eq "[1].select do |__arg0|\n  __arg0.nil?\nend"
    end

    it "can cope with additional calls following" do
      ast = Crystal::Parser.parse("[1, 2, 3, 4].select { |i| i > 4 }.flatten")
      possibilities = Mutant::SelectRejectSwapPossibilities.new
      ast.accept(possibilities)
      mutant = Mutant::SelectRejectSwap.at(possibilities.locations.first)
      transformed = ast.transform(mutant)
      transformed.to_s.should eq <<-CODE
      [1, 2, 3, 4].reject do |i|
        i > 4
      end.flatten
      CODE
    end

    it "works together with a multi-callsite possibility" do
      ast = Crystal::Parser.parse(<<-CODE
      MUTANT_POSSIBILITIES.map do |inspector|
        ast.accept(inspector)
        inspector
      end.select(&.any?).map do |inspector|
        inspector.locations.map do |location|
          Mutation::Mutation.with(mutant: inspector.mutant_class.at(location: location), original: source, specs: specs)
        end
      end.flatten
      CODE
      )
      possibilities = Mutant::SelectRejectSwapPossibilities.new
      ast.accept(possibilities)
      mutant = Mutant::SelectRejectSwap.at(possibilities.locations.first)
      transformed = ast.transform(mutant)
      transformed.to_s.should eq <<-CODE
      MUTANT_POSSIBILITIES.map do |inspector|
        ast.accept(inspector)
        inspector
      end.reject(&.any?).map do |inspector|
        inspector.locations.map do |location|
          Mutation::Mutation.with(mutant: inspector.mutant_class.at(location: location), original: source, specs: specs)
        end
      end.flatten
      CODE
    end
  end
end
