///|
extern type StringBuilder

///|
fn as_buffer(self : StringBuilder) -> Buffer = "%identity"

///|
fn sb_new(size_hint : Int) -> StringBuilder = "env" "sb_new"

///|
fn sb_write_string(sb : StringBuilder, str : String) -> Unit = "env" "sb_write_string"

///|
fn sb_write_substring(
  sb : StringBuilder,
  str : String,
  start : Int,
  length : Int
) -> Unit = "env" "sb_write_substring"

///|
fn sb_write_char(sb : StringBuilder, ch : Char) -> Unit = "env" "sb_write_char"

///|
fn sb_to_string(sb : StringBuilder) -> String = "env" "sb_to_string"

///|
pub fn StringBuilder::new(size_hint~ : Int = 0) -> StringBuilder {
  sb_new(size_hint)
}

// ///|
// /// Return whether the given buffer is empty.
// pub fn StringBuilder::is_empty(self : StringBuilder) -> Bool {
//   self.len == 0
// }

///|
pub impl Logger for StringBuilder with write_string(self, str) -> Unit {
  sb_write_string(self, str)
}

///|
pub impl Logger for StringBuilder with write_char(self, ch) -> Unit {
  sb_write_char(self, ch)
}

///|
pub impl Logger for StringBuilder with write_substring(self, str, start, length) -> Unit {
  sb_write_substring(self, str, start, length)
}

///|
pub impl Show for StringBuilder with to_string(self) -> String {
  sb_to_string(self)
}

///|
pub impl Show for StringBuilder with output(self, logger) -> Unit {
  logger.write_string(sb_to_string(self))
}

// ///|
// pub fn StringBuilder::reset(self : StringBuilder) -> Unit {
//   self.len = 0
// }
