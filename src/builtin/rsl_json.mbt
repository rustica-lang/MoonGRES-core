///|
extern type JsonText

///|
fn json_in(str : String) -> JsonText = "env" "json_in"

///|
fn json_out(json : JsonText) -> String = "env" "json_out"

///|
pub impl FromStr for JsonText with from_string(str) {
  json_in(str)
}

///|
impl Obj for JsonText with typname() {
  "json"
}

///|
pub impl Show for JsonText with to_string(self) {
  json_out(self)
}

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
