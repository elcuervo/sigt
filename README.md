# SigT

![](https://images.unsplash.com/photo-1622966591413-81d31b41c8a3?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTV8fHNpZ25hdHVyZXxlbnwwfHwwfHx8MA%3D%3D)

## Example

### Dry::Types

```ruby
module Types
  include Dry.Types()
end

sig = SigT[Types::String => Types::Hash.schema(name: Types::String)]

fn = sig[] { |input| Hash[name: input] }

fn[1]
#=> SigT::InputError: 1 violates constraints (type?(String, 1) failed)

fn["elcuervo"]
#=> {:name=>"raven"}
```

### Dry::Struct

```ruby
class TestInput < Dry::Struct
  attribute  :url,          SigT::Types::String
  attribute? :potato_count, SigT::Types::Integer
end

class TestOutput < Dry::Struct
  attribute  :complexity, SigT::Types::Float
  attribute? :url,        SigT::Types::String
end

fn = SigT[TestInput => TestOutput] do |input|
  TestOutput.new(complexity: 0.4, url: input.url)
end

fn.call(TestInput.new(url: "test"))
# => #<TestOutput complexity=0.4 url="test">
```
