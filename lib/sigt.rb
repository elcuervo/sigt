# frozen_string_literal: true

# The SigT class provides functionality for defining and enforcing type signatures
# on method inputs and outputs using the dry-types gem. It allows for the dynamic
# validation of method arguments and return values against specified type constraints.
#
class SigT
  module Types
    include Dry.Types()

    Type = Types.Instance(Dry::Types::Type)
    Signature = Types::Hash
      .map(Type, Type)
      .constrained(max_size: 1)
  end

  Error = Class.new(StandardError)
  SignatureError = Class.new(Error)
  InputError = Class.new(Error)
  OutputError = Class.new(Error)

  class << self
    # Defines a signature for input and output types and wraps the provided block with type
    # validation checks.
    # @param signature [Hash] A hash representing the input and output types.
    # @yield [input] The block to be executed.
    # @yieldparam input [Object] The input object to be processed.
    # @yieldreturn [Object] The result of the block execution, which will be validated against the
    # output type.
    # @raise [SignatureError] If the signature does not conform to the expected structure or
    # constraints.
    # @raise [InputError] If the input object does not match the expected type.
    # @raise [OutputError] If the output object does not match the expected type.
    # @return [Proc] A proc that represents the wrapped block, which validates input and output
    # types.
    #
    def [](signature, &block)
      Types::Signature[signature]
        .flatten
        .then do |input, output|
          return sandwich(input, block, output) if block
          -> (&fn) { sandwich(input, fn, output) }
        end
    rescue Dry::Types::ConstraintError => e
      raise SignatureError, "Signature can only have 1 Dry::Type => Dry::Type compatible objects"
    end

    private

    # Creates a sandwiched function that validates the input, executes the function, and then
    # validates the output.
    # @param input [Dry::Types::Type] The expected type of the input.
    # @param fn [Proc] The function to execute between type checks.
    # @param output [Dry::Types::Type] The expected type of the output.
    # @return [Proc] A proc that takes an input, validates it, executes the function, and validates
    # the output.
    #
    def sandwich(input, fn, output)
      wrap_or_raise(input, InputError) >> fn >> wrap_or_raise(output, OutputError)
    end

    # Wraps a block with type validation, raising an error if the validation fails.
    # @param type [Dry::Types::Type] The type to validate against.
    # @param error [Class] The error class to be raised if validation fails.
    # @return [Proc] A proc that represents the wrapped block, which performs type validation.
    #
    def wrap_or_raise(type, error)
      -> (input) do
        type[input]
      rescue StandardError => e
        raise error, e.message
      end
    end
  end
end
