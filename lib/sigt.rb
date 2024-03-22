# frozen_string_literal: true

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

  IDENTITY = -> (x) { x }

  class << self
    # Defines a signature for input and output types and wraps the provided block with type validation checks.
    #
    # @param [Hash] signature A hash representing the input and output types.
    # @yield [input] The block to be executed.
    # @yieldparam [Object] input The input object to be processed.
    # @raise [InputError] if the input object does not match the expected type.
    # @raise [OutputError] if the output object does not match the expected type.
    # @return [Proc] A proc that represents the wrapped block.
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

    def sandwich(input, fn, output)
      wrap_or_raise(input, InputError) >> fn >> wrap_or_raise(output, OutputError)
    end

    # Wraps the provided block with type validation checks and raises an error if the validation fails.
    #
    # @param [Dry::Types::Type] type The type to validate against.
    # @param [Class] error The error class to be raised if validation fails.
    # @return [Proc] A proc that represents the wrapped block.
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
