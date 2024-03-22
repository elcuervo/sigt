# SigT

![](https://images.unsplash.com/photo-1622966591413-81d31b41c8a3?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTV8fHNpZ25hdHVyZXxlbnwwfHwwfHx8MA%3D%3D)

## Install

```bash
gem install sigt
```

## Example

### Function composition

```ruby
module Types
  include Dry.Types()
end

AgeHash = Types::Hash.schema(age: Types::Integer, name: Types::String)
FinalHash = AgeHash & Types::Hash.schema(created_at: Types.Instance(Time))

TO_INTEGER = -> (x) { x.to_i }
TO_JSON = -> (x) { x.to_json }

hash = SigT[Types::Integer => AgeHash] { |age| Hash[age: age, name: "poe"] }

with_date = SigT[AgeHash => FinalHash] do |hash|
  hash.update(created_at: Time.now.utc)
end

fn = TO_INTEGER >> hash >> with_date >> TO_JSON
fn["42"]
#=> "{\"age\":42,\"name\":\"poe\",\"created_at\":\"2024-03-22 22:28:26 UTC\"}"
```

### Dry::Types

```ruby
sig = SigT[Types::String => Types::Hash.schema(name: Types::String)]

fn = sig[] { |input| Hash[name: input] }

fn[1]
#=> SigT::InputError: 1 violates constraints (type?(String, 1) failed)

fn["elcuervo"]
#=> {:name=>"elcuervo"}
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
