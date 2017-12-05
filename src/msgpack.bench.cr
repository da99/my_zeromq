
require "benchmark"
require "json"
require "yaml"
require "msgpack"

o = {
  "title" => "JSON Example",
  "owner1" => {
    "name" => "Lance Uppercut1",
    "dob" => "1979-05-27"
  },
  "owner2" => {
    "name" => "Lance Uppercut2",
    "dob" => "1979-05-27"
  },
  "owner3" => {
    "name" => "Lance Uppercut",
    "dob" => "1979-05-27"
  },
  "owner4" => {
    "name" => "Lance Uppercut",
    "dob" => "1979-05-27"
  }
}

json_string = o.to_json

o["title"] = "YAML Example"
yaml_string = o.to_yaml

o["title"] = "MSGPACK Example"
msgpack_bin = o.to_msgpack

def assert(a, b)
  return true if a == b
  raise Exception.new("#{a.inspect} != #{b.inspect}")
end


class My_JSON

  class Owner
    JSON.mapping(
      name: String,
      dob: String
    )
  end # === class Owner

  JSON.mapping(
    title: String,
    owner1: {type: Owner},
    owner2: {type: Owner},
    owner3: {type: Owner},
    owner4: {type: Owner}
  )

end # === class My_JSON

class My_YAML
  class Owner
    YAML.mapping(
      name: String,
      dob: String
    )
  end # === class Owner

  YAML.mapping(
    title: String,
    owner1: {type: Owner},
    owner2: {type: Owner},
    owner3: {type: Owner},
    owner4: {type: Owner}
  )

end # === class My_YAML

class My_MSGPACK

  class Owner
    MessagePack.mapping({
      name: String,
      dob: String
    })
  end # === class Owner
  MessagePack.mapping({
    title: String,
    owner1: {type: Owner},
    owner2: {type: Owner},
    owner3: {type: Owner},
    owner4: {type: Owner}
  })
end # === class My_MSGPACK

X = 2_000_000
Benchmark.bm do |x|
  x.report("MessagePack:") {
    X.times { |i|
      m = My_MSGPACK.from_msgpack(msgpack_bin)
      assert( m.title, "MSGPACK Example")
      assert( m.owner1.name, "Lance Uppercut1")
    }
  }
  x.report("json:") {
    X.times do |i|
      j = My_JSON.from_json(json_string)
      assert( j.title, "JSON Example")
      assert( j.owner1.name, "Lance Uppercut1")
    end
  }
  x.report("yaml:") {
    X.times { |i|
      y = My_YAML.from_yaml(yaml_string)
      assert( y.title, "YAML Example")
      assert( y.owner1.name, "Lance Uppercut1")
    }
  }
end # Benchmark

