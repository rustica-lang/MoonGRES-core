///|
fn bytea_out(bytea : Bytes) -> String = "env" "bytea_out"

///|
fn bytea_substr(bytea : Bytes, start : Int, length : Int) -> Bytes = "env" "bytea_substr"

///|
fn bytes_decode(
  bytes : Bytes,
  start : Int,
  length : Int,
  encoding : String
) -> String = "env" "bytes_decode"

///|
impl Obj for Bytes with typname() {
  "bytea"
}

///|
pub impl Show for Bytes with to_string(self) {
  bytea_out(self)
}

///|
pub impl Show for Bytes with output(self, logger) {
  output_with_typname(self, logger)
}

///|
impl FromJson for Bytes with from_json(json, path) {
  String::from_json!(json, path).encode()
}

///|
impl ToJson for Bytes with to_json(self) {
  String(self.to_string())
}

///|
pub fn Bytes::decode(self : Bytes, encoding~ : String = "utf8") -> String {
  bytes_decode(self, 0, self.length(), encoding)
}
