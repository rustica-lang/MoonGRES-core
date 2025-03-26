///|
pub impl Show for BytesView with to_string(self) {
  bytea_substr(self.bytes, self.start, self.len).to_string()
}

///|
pub impl Show for BytesView with output(self, logger) {
  logger.write_string("BytesView<")
  Buffer::new(size_hint=self.len)
  ..write_bytes_view(self)
  .to_bytes()
  .output(logger)
  logger.write_string(self.to_string())
  logger.write_char('>')
}

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
    let buf = Buffer::new(size_hint=self.len + other.len)
    buf.write_bytes_view(self)
    buf.write_bytes_view(other)
    buf.to_bytes()[:]
  }
}

///|
pub fn BytesView::decode(
  self : BytesView,
  encoding~ : String = "utf8"
) -> String {
  bytes_decode(self.bytes, self.start, self.len, encoding)
}
