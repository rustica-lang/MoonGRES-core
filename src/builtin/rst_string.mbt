///|
fn text_substr(str : String, start : Int, length : Int) -> String = "env" "text_substr"

///|
fn text_encode(str : String, encoding : String) -> Bytes = "env" "text_encode"

///|
pub fn String::substring(self : String, start~ : Int = 0, end? : Int) -> String {
  let len = match end {
    Some(end) => {
      guard start <= end
      end - start
    }
    None => -1
  }
  text_substr(self, start, len)
}

///|
pub impl FromStr for String with from_string(str) {
  str
}

///|
pub fn String::encode(self : String, encoding~ : String = "utf8") -> Bytes {
  text_encode(self, encoding)
}

///|
fn Char::to_lower(self : Char) -> Char {
  if self.is_ascii_uppercase() {
    Char::from_int(self - 'A' + 'a'.to_int())
  } else {
    self
  }
}
