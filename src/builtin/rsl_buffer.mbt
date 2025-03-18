///|
type Buffer

// ///|
// pub extern "wasm" fn length(self : Buffer) -> Int =
//   #| (func (import "env" "sb_mblength")
//   #|  (param (ref extern)) (result i32))

///|
fn as_string_builder(self : Buffer) -> StringBuilder = "%identity"

///|
pub fn Buffer::new(size_hint~ : Int = 0) -> Buffer {
  sb_new(size_hint).as_buffer()
}

///|
pub fn write_string(self : Buffer, str : String) -> Unit {
  self.as_string_builder().write_string(str)
}

///|
pub extern "wasm" fn sb_to_bytes(buf : Buffer) -> Bytes =
  #| (func (import "env" "sb_to_bytes")
  #|  (param (ref extern)) (result (ref $moonbit.bytes)))

///|
pub extern "wasm" fn sb_write_bytes(
  buf : Buffer,
  value : Bytes,
  start : Int,
  length : Int
) -> Unit =
  #| (func (import "env" "sb_write_bytes")
  #|  (param (ref extern)) (param (ref $moonbit.bytes)) (param i32) (param i32)
  #|  (result i32))

///|
pub fn write_bytes(self : Buffer, value : Bytes) -> Unit {
  sb_write_bytes(self, value, 0, value.length())
}

///|
pub fn write_bytes_view(self : Buffer, value : BytesView) -> Unit {
  sb_write_bytes(self, value.bytes, value.start, value.len)
}

///|
pub fn to_bytes(self : Buffer) -> Bytes {
  sb_to_bytes(self)
}
