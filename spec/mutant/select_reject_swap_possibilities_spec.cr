require "spec"
require "../../src/crytic/mutant/select_reject_swap_possibilities"

module Crytic
  describe Mutant::SelectRejectSwapPossibilities do
    it "returns no possibilities if there is no method call at all" do
      ast = Crystal::Parser.parse("1")
      possibilities = Mutant::SelectRejectSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns no possibilities if there is no select call" do
      ast = Crystal::Parser.parse("puts 2")
      possibilities = Mutant::SelectRejectSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = Crystal::Parser.parse("[1].select(&.nil?)")
      possibilities = Mutant::SelectRejectSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 1
    end
  end
end