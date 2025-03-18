///|
type Jsonb

///|
type JsonbValue

///|
extern "wasm" fn jsonb_in(str : String) -> Jsonb =
  #| (func (import "env" "jsonb_in")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn jsonb_out(jsonb : Jsonb) -> String =
  #| (func (import "env" "jsonb_out")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn jsonb_value_to_jsonb(val : JsonbValue) -> Jsonb =
  #| (func (import "env" "jsonb_value_to_jsonb")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn jsonb_value_new_null() -> JsonbValue =
  #| (func (import "env" "jsonb_value_new_null")
  #|  (result (ref extern)))

///|
extern "wasm" fn jsonb_value_new_string(string : String) -> JsonbValue =
  #| (func (import "env" "jsonb_value_new_string")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn jsonb_value_new_numeric(number : Double) -> JsonbValue =
  #| (func (import "env" "jsonb_value_new_numeric")
  #|  (param f64) (result (ref extern)))

///|
extern "wasm" fn jsonb_value_new_bool(value : Bool) -> JsonbValue =
  #| (func (import "env" "jsonb_value_new_bool")
  #|  (param i32) (result (ref extern)))

///|
extern "wasm" fn jsonb_value_new_array(len : Int) -> JsonbValue =
  #| (func (import "env" "jsonb_value_new_array")
  #|  (param i32) (result (ref extern)))

///|
extern "wasm" fn jsonb_value_array_set(
  array : JsonbValue,
  index : Int,
  member : JsonbValue
) -> Unit =
  #| (func (import "env" "jsonb_value_array_set")
  #|  (param (ref extern)) (param i32) (param (ref extern))
  #|  (result i32))

///|
extern "wasm" fn jsonb_value_new_object(size : Int) -> JsonbValue =
  #| (func (import "env" "jsonb_value_new_object")
  #|  (param i32) (result (ref extern)))

///|
extern "wasm" fn jsonb_value_object_set(
  object : JsonbValue,
  order : Int,
  key : JsonbValue,
  member : JsonbValue
) -> Unit =
  #| (func (import "env" "jsonb_value_object_set")
  #|  (param (ref extern)) (param i32) (param (ref extern)) (param (ref extern))
  #|  (result i32))

///|
extern "wasm" fn json_parse(buf : Bytes, start : Int, length : Int) -> Bool =
  #| (func (import "env" "json_parse")
  #|  (param (ref $moonbit.bytes)) (param i32) (param i32)
  #|  (result i32))

///|
extern "wasm" fn jsonb_iterate(jsonb : Jsonb) -> Bool =
  #| (func (import "env" "jsonb_iterate")
  #|  (param (ref extern)) (result i32))

//|
///|
pub impl FromStr for Jsonb with from_string(str) { jsonb_in(str) }

///|
pub fn Jsonb::to_string(self : Jsonb) -> String {
  jsonb_out(self)
}

///|
impl Obj for Jsonb with typname() { "jsonb" }

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
      guard let Some(Array(arr)) = json_parse_stack.last()
      arr.push(json)
      if push_stack {
        json_parse_stack.push(json)
      }
    }
    Key(_, key~) => {
      guard let Some(Object(obj)) = json_parse_stack.last()
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
  json_parse_path.val.update_key_inplace(key)
}

///|
pub fn json_parse_object_end() -> Unit {
  guard let Key(parent, ..) = json_parse_path.val
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
  guard let Index(parent, ..) = json_parse_path.val
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
