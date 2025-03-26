///|
extern type UUID

///|
fn uuid(str : String) -> UUID = "env" "uuid_in"

///|
fn uuid_out(uuid : UUID) -> String = "env" "uuid_out"

///|
fn uuid_cmp(left : UUID, right : UUID) -> Int = "env" "uuid_cmp"

///|
pub impl FromStr for UUID with from_string(str) {
  uuid(str)
}

///|
impl Obj for UUID with typname() {
  "uuid"
}

///|
pub impl Show for UUID with to_string(self) {
  uuid_out(self)
}

///|
pub impl Show for UUID with output(self, logger) {
  output_with_typname(self, logger)
}

///|
pub impl Compare for UUID with compare(self, other) {
  uuid_cmp(self, other)
}

///|
pub impl FromJson for UUID with from_json(json, path) {
  uuid(String::from_json!(json, path))
}

///|
pub impl ToJson for UUID with to_json(self) {
  String(self.to_string())
}
