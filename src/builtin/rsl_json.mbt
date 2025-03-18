///|
type JsonText

///|
extern "wasm" fn json_in(str : String) -> JsonText =
  #| (func (import "env" "json_in")
  #|  (param (ref extern)) (result (ref extern)))

///|
extern "wasm" fn json_out(json : JsonText) -> String =
  #| (func (import "env" "json_out")
  #|  (param (ref extern)) (result (ref extern)))

///|
pub impl FromStr for JsonText with from_string(str) { json_in(str) }

///|
pub fn JsonText::to_string(self : JsonText) -> String {
  json_out(self)
}

///|
impl Obj for JsonText with typname() { "json" }

///|
pub impl Show for JsonText with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl FromJson for JsonText with from_json(json, path) {
  JsonText::from_string?(Jsonb::from_json!(json, path).to_string()).unwrap()
}

///|
pub impl ToJson for JsonText with to_json(self) {
  Jsonb::from_string?(self.to_string()).unwrap().to_json()
}
