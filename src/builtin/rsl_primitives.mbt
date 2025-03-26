///|
fn parse_bool(str : String) -> Bool = "env" "parse_bool"

///|
pub impl FromStr for Bool with from_string(str) {
  parse_bool(str)
}

///|
pub impl Show for Bool with to_string(self) {
  if self {
    "true"
  } else {
    "false"
  }
}

///|
fn int4in(str : String) -> Int = "env" "int4in"

///|
pub impl FromStr for Int with from_string(str) {
  int4in(str)
}

///|
fn int4out(val : Int) -> String = "env" "int4out"

///|
pub impl Show for Int with to_string(self) {
  int4out(self)
}

///|
pub impl Show for Int with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
fn int8in(str : String) -> Int64 = "env" "int8in"

///|
pub impl FromStr for Int64 with from_string(str) {
  int8in(str)
}

///|
fn int8out(val : Int64) -> String = "env" "int8out"

///|
pub impl Show for Int64 with to_string(self) {
  int8out(self)
}

///|
pub impl Show for Int64 with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
fn float4in(str : String) -> Float = "env" "float4in"

///|
pub impl FromStr for Float with from_string(str) {
  float4in(str)
}

///|
fn float4out(val : Float) -> String = "env" "float4out"

///|
pub impl Show for Float with to_string(self) {
  float4out(self)
}

///|
pub impl Show for Float with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
pub impl FromJson for Float with from_json(json, path) {
  match json {
    Number(n) => n.to_float()
    _ => decode_error!(path, "Float::from_json: expected number")
  }
}

///|
fn float8in(str : String) -> Double = "env" "float8in"

///|
pub impl FromStr for Double with from_string(str) {
  float8in(str)
}

///|
fn float8out(val : Double) -> String = "env" "float8out"

///|
pub impl Show for Double with to_string(self) {
  float8out(self)
}

///|
pub impl Show for Double with output(self, logger) {
  logger.write_string(self.to_string())
}
