///|
pub extern "wasm" fn bytes_decode(
  bytes : Bytes,
  start : Int,
  length : Int,
  encoding : String
) -> String =
  #| (func (import "env" "bytes_decode")
  #|  (param (ref $moonbit.bytes)) (param i32) (param i32) (param (ref extern))
  #|  (result (ref extern)))
  #|

///|
fn unsafe_to_fixed_array(self : Bytes) -> FixedArray[Byte] = "%identity"

///|
fn unsafe_to_bytes(self : UninitializedArray[Byte]) -> Bytes = "%identity"

///|
pub fn op_add(self : BytesView?, other : BytesView?) -> BytesView? {
  match (self, other) {
    (Some(this), Some(that)) => Some(this + that)
    (None, Some(_)) => other
    (Some(_), None) => self
    (None, None) => self
  }
}

///|
pub fn BytesView::op_add(self : BytesView, other : BytesView) -> BytesView {
  if physical_equal(self.bytes, other.bytes) &&
    self.start + self.len == other.start {
    BytesView::{
      bytes: self.bytes,
      start: self.start,
      len: self.len + other.len,
    }
  } else {
    let rv : FixedArray[Byte] = FixedArray::make(self.len + other.len, b'\x00')
    FixedArray::unsafe_blit(
      rv,
      0,
      self.bytes.unsafe_to_fixed_array(),
      self.start,
      self.len,
    )
    FixedArray::unsafe_blit(
      rv,
      self.len,
      other.bytes.unsafe_to_fixed_array(),
      other.start,
      other.len,
    )
    rv.unsafe_to_bytes()[:]
  }
}

///|
pub fn BytesView::decode(
  self : BytesView,
  encoding~ : String = "utf8"
) -> String {
  bytes_decode(self.bytes, self.start, self.len, encoding)
}

///|
pub fn to_bytes_view(self : Array[Byte]) -> BytesView {
  self.buf.unsafe_to_bytes()[:self.len]
}

///|
pub fn BytesView::make(size : Int) -> BytesView {
  UninitializedArray::make(size).unsafe_to_bytes()[:]
}
