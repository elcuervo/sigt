# frozen_string_literal: true

require "spec_helper"

describe SigT do
  describe "simple definition" do
    let(:fn) do
      SigT[SigT::Types::String => SigT::Types::Integer] do |params|
        params.to_i + 1
      end
    end

    it "defines an input/output signature" do
      assert_equal fn["1"], 2
    end

    it "checks the input" do
      assert_raises(SigT::InputError) { fn[1] }
    end

    it "checks output input" do
      bad = SigT[SigT::Types::String => SigT::Types::Hash] do |input|
        input
      end

      assert_raises(SigT::OutputError) { bad["1"] }
    end

    it "multiline" do
      sig = SigT[SigT::Types::String => SigT::Types::Hash.schema(name: SigT::Types::String)]
      fn = sig[] { |input| Hash[name: input] }

      assert_equal fn["raven"], { name: "raven" }
    end
  end

  describe "complex definition" do
    class TestInput < Dry::Struct
      attribute  :url,          SigT::Types::String
      attribute? :potato_count, SigT::Types::Integer
    end

    class TestOutput < Dry::Struct
      attribute  :complexity, SigT::Types::Float
      attribute? :url,        SigT::Types::String
    end

    let(:fn) do
      SigT[TestInput => TestOutput] do |input|
        TestOutput.new(complexity: 0.4, url: input.url)
      end
    end

    it "defines an input/output signature" do
      input = TestInput.new(url: "test")

      assert_equal fn[input].class, TestOutput
    end
  end
end
