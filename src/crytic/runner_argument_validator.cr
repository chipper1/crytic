module Crytic
  module RunnerArgumentValidator
    private def validate_args!(source, specs)
      if specs.empty?
        raise ArgumentError.new("No spec files given.")
      end

      unless source.map { |path| File.exists?(path) }.all?
        raise ArgumentError.new("Source file for subject doesn't exist.")
      end

      specs.each do |spec_file|
        unless File.exists?(spec_file)
          raise ArgumentError.new("Spec file #{spec_file} doesn't exist.")
        end
      end
    end
  end
end
