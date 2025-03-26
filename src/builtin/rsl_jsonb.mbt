///|
extern type Jsonb

///|
extern type JsonbValue

///|
fn jsonb_in(str : String) -> Jsonb = "env" "jsonb_in"

///|
fn jsonb_out(jsonb : Jsonb) -> String = "env" "jsonb_out"

///|
fn jsonb_value_to_jsonb(val : JsonbValue) -> Jsonb = "env" "jsonb_value_to_jsonb"

///|
fn jsonb_value_new_null() -> JsonbValue = "env" "jsonb_value_new_null"

///|
fn jsonb_value_new_string(string : String) -> JsonbValue = "env" "jsonb_value_new_string"

///|
fn jsonb_value_new_numeric(number : Double) -> JsonbValue = "env" "jsonb_value_new_numeric"

///|
fn jsonb_value_new_bool(value : Bool) -> JsonbValue = "env" "jsonb_value_new_bool"

///|
fn jsonb_value_new_array(len : Int) -> JsonbValue = "env" "jsonb_value_new_array"

///|
fn jsonb_value_array_set(
  array : JsonbValue,
  index : Int,
  member : JsonbValue
) -> Unit = "env" "jsonb_value_array_set"

///|
fn jsonb_value_new_object(size : Int) -> JsonbValue = "env" "jsonb_value_new_object"

///|
fn jsonb_value_object_set(
  object : JsonbValue,
  order : Int,
  key : JsonbValue,
  member : JsonbValue
) -> Unit = "env" "jsonb_value_object_set"

///|
fn json_parse(buf : Bytes, start : Int, length : Int) -> Bool = "env" "json_parse"

///|
fn jsonb_iterate(jsonb : Jsonb) -> Bool = "env" "jsonb_iterate"

//|
///|
pub impl FromStr for Jsonb with from_string(str) {
  jsonb_in(str)
}

///|
impl Obj for Jsonb with typname() {
  "jsonb"
}

///|
pub impl Show for Jsonb with to_string(self) {
  jsonb_out(self)
}

///|
pub impl Show for Jsonb with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl FromJson for Jsonb with from_json(json, path) {
  jsonb_value_to_jsonb(JsonbValue::from_json!(json, path))
}

///|
pub impl ToJson for Jsonb with to_json(self) {
  if not(jsonb_iterate(self)) {
    abort("error occured in jsonb_iterate()")
  }
  json_parse_path.val = Root
  json_parse_stack.pop().unwrap()
}

///|
impl FromJson for JsonbValue with from_json(json, path) {
  match json {
    Null => jsonb_value_new_null()
    String(str) => jsonb_value_new_string(str)
    Number(number) => jsonb_value_new_numeric(number)
    True => jsonb_value_new_bool(true)
    False => jsonb_value_new_bool(false)
    Array(array) => {
      let rv = jsonb_value_new_array(array.length())
      for i, member in array {
        let member = JsonbValue::from_json!(member, path.add_index(i))
        jsonb_value_array_set(rv, i, member)
      }
      rv
    }
    Object(map) => {
      let rv = jsonb_value_new_object(map.size())
      let mut i = 0
      for key, member in map {
        let member = JsonbValue::from_json!(member, path.add_key(key))
        jsonb_value_object_set(rv, i, jsonb_value_new_string(key), member)
        i += 1
      }
      rv
    }
  }
}

///|
let json_parse_stack : Array[Json] = []

///|
let json_parse_path : Ref[JsonPath] = Ref::{ val: Root }

///|
fn json_parse_push_value(json : Json, push_stack~ : Bool) -> Unit {
  match json_parse_path.val {
    Root => json_parse_stack.push(json)
    Index(_) => {
      guard json_parse_stack.last() is Some(Array(arr))
      arr.push(json)
      if push_stack {
        json_parse_stack.push(json)
      }
    }
    Key(_, key~) => {
      guard json_parse_stack.last() is Some(Object(obj))
      obj[key] = json
      if push_stack {
        json_parse_stack.push(json)
      }
    }
  }
}

///|
pub fn json_parse_push_string(str : String) -> Unit {
  json_parse_push_value(String(str), push_stack=false)
}

///|
pub fn json_parse_push_number(num : Double) -> Unit {
  json_parse_push_value(Number(num), push_stack=false)
}

///|
pub fn json_parse_push_bool(bool : Bool) -> Unit {
  json_parse_push_value(if bool { True } else { False }, push_stack=false)
}

///|
pub fn json_parse_push_null() -> Unit {
  json_parse_push_value(Null, push_stack=false)
}

///|
pub fn json_parse_object_start() -> Unit {
  let json = Object({})
  json_parse_push_value(json, push_stack=true)
  json_parse_path.val = Key(json_parse_path.val, key="")
}

///|
pub fn json_parse_object_field_start(key : String) -> Unit {
  guard json_parse_path.val is (Key(_) as k)
  k.key = key
}

///|
pub fn json_parse_object_end() -> Unit {
  guard json_parse_path.val is Key(parent, ..)
  json_parse_path.val = parent
  match parent {
    Root => ()
    _ => json_parse_stack.pop() |> ignore
  }
}

///|
pub fn json_parse_array_start() -> Unit {
  let json = Array([])
  json_parse_push_value(json, push_stack=true)
  json_parse_path.val = Index(json_parse_path.val, index=0)
}

///|
pub fn json_parse_array_end() -> Unit {
  guard json_parse_path.val is Index(parent, ..)
  json_parse_path.val = parent
  match parent {
    Root => ()
    _ => json_parse_stack.pop() |> ignore
  }
}

///|
pub fn Json::parse(buf : BytesView) -> Json {
  if not(json_parse(buf.bytes, buf.start, buf.len)) {
    abort("failed to parse JSON")
  }
  json_parse_path.val = Root
  json_parse_stack.pop().unwrap()
}

///|
pub fn json_decode[T : FromJson](buf : BytesView) -> T! {
  T::from_json!(Json::parse(buf), Root)
}

///|
pub fn json_encode[T : ToJson](value : T) -> String! {
  Jsonb::from_json!(value.to_json(), Root).to_string()
}
