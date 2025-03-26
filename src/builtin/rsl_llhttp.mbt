///| HTTP 请求方法。
///
pub(all) enum Method {
  DELETE
  GET
  HEAD
  POST
  PUT
  // pathological
  CONNECT
  OPTIONS
  TRACE
  // WebDAV
  COPY
  LOCK
  MKCOL
  MOVE
  PROPFIND
  PROPPATCH
  SEARCH
  UNLOCK
  BIND
  REBIND
  UNBIND
  ACL
  // subversion
  REPORT
  MKACTIVITY
  CHECKOUT
  MERGE
  // upnp
  M_SEARCH
  NOTIFY
  SUBSCRIBE
  UNSUBSCRIBE
  // RFC-5789
  PATCH
  PURGE
  // CalDAV
  MKCALENDAR
  // RFC-2068, section 19.6.1.2
  LINK
  UNLINK
  // icecast
  SOURCE
  // RFC-7540, section 11.6
  PRI
  // RFC-2326 RTSP
  DESCRIBE
  ANNOUNCE
  SETUP
  PLAY
  PAUSE
  TEARDOWN
  GET_PARAMETER
  SET_PARAMETER
  REDIRECT
  RECORD
  // RAOP
  FLUSH
} derive(Show)

///|
pub fn Method::from_int(method_ : Int) -> Method {
  match method_ {
    0 => DELETE
    1 => GET
    2 => HEAD
    3 => POST
    4 => PUT
    5 => CONNECT
    6 => OPTIONS
    7 => TRACE
    8 => COPY
    9 => LOCK
    10 => MKCOL
    11 => MOVE
    12 => PROPFIND
    13 => PROPPATCH
    14 => SEARCH
    15 => UNLOCK
    16 => BIND
    17 => REBIND
    18 => UNBIND
    19 => ACL
    20 => REPORT
    21 => MKACTIVITY
    22 => CHECKOUT
    23 => MERGE
    24 => M_SEARCH
    25 => NOTIFY
    26 => SUBSCRIBE
    27 => UNSUBSCRIBE
    28 => PATCH
    29 => PURGE
    30 => MKCALENDAR
    31 => LINK
    32 => UNLINK
    33 => SOURCE
    34 => PRI
    35 => DESCRIBE
    36 => ANNOUNCE
    37 => SETUP
    38 => PLAY
    39 => PAUSE
    40 => TEARDOWN
    41 => GET_PARAMETER
    42 => SET_PARAMETER
    43 => REDIRECT
    44 => RECORD
    45 => FLUSH
    _ => abort("unknown HTTP method: \{method_}")
  }
}

///|
fn llhttp_execute(buf : Bytes, start : Int, len : Int) -> Int = "env" "llhttp_execute"

///|
fn llhttp_resume() -> Int = "env" "llhttp_resume"

///|
fn llhttp_finish(buf : Bytes) -> Int = "env" "llhttp_finish"

///|
fn llhttp_reset() -> Int = "env" "llhttp_reset"

///|
fn llhttp_get_error_pos(buf : Bytes) -> Int = "env" "llhttp_get_error_pos"

///|
fn llhttp_get_method() -> Int = "env" "llhttp_get_method"

///|
fn llhttp_get_http_major() -> Int = "env" "llhttp_get_http_major"

///|
fn llhttp_get_http_minor() -> Int = "env" "llhttp_get_http_minor"

///|
enum HttpEvent {
  OnMessageBegin
  OnMethod(Method)
  OnUrl(String)
  OnVersion(Int, Int)
  OnHeader(String, String)
  OnHeadersComplete
  OnBody(BytesView)
  OnMessageComplete
  OnError(Bytes)
} derive(Show)

///|
struct ParserState {
  mut url : BytesView?
  mut header_field : BytesView?
  mut header_value : BytesView?
  mut event : HttpEvent?
} derive(Default)

///|
let state : ParserState = Default::default()

///|
pub(all) enum CallbackResult {
  Ok
  Err
  Paused
}

///|
pub fn on_message_begin() -> CallbackResult {
  state.event = Some(OnMessageBegin)
  Paused
}

///|
pub fn on_method_complete() -> CallbackResult {
  let method_ = Method::from_int(llhttp_get_method())
  state.event = Some(OnMethod(method_))
  Paused
}

///|
pub fn on_url(url : BytesView) -> CallbackResult {
  state.url += Some(url)
  Ok
}

///|
pub fn on_url_complete() -> CallbackResult {
  let url = state.url.unwrap().decode(encoding="ascii")
  state.event = Some(OnUrl(url))
  Paused
}

///|
pub fn on_version_complete() -> CallbackResult {
  let major = llhttp_get_http_major()
  let minor = llhttp_get_http_minor()
  state.event = Some(OnVersion(major, minor))
  Paused
}

///|
pub fn on_header_field(field : BytesView) -> CallbackResult {
  state.header_field += Some(field)
  Ok
}

///|
pub fn on_header_field_complete() -> CallbackResult {
  Ok
}

///|
pub fn on_header_value(value : BytesView) -> CallbackResult {
  state.header_value += Some(value)
  Ok
}

///|
pub fn on_header_value_complete() -> CallbackResult {
  let field = state.header_field.unwrap().decode(encoding="ascii")
  state.header_field = None
  let value = state.header_value.unwrap().decode(encoding="ascii")
  state.header_value = None
  state.event = Some(OnHeader(field, value))
  Paused
}

///|
pub fn on_headers_complete() -> CallbackResult {
  state.event = Some(OnHeadersComplete)
  Paused
}

///|
pub fn on_body(body : BytesView) -> CallbackResult {
  if body.len > 0 {
    state.event = Some(OnBody(body))
    Paused
  } else {
    Ok
  }
}

///|
pub fn on_message_complete() -> CallbackResult {
  state.url = None
  state.header_field = None
  state.header_value = None
  state.event = Some(OnMessageComplete)
  Paused
}

///|
pub fn on_error(error : Bytes) -> Int {
  state.event = Some(OnError(error))
  0
}

///|
enum ParseResult {
  Ok
  Err(Int, Bytes)
  Paused(HttpEvent, BytesView)
} derive(Show)

///|
fn parse_http_step(buf : BytesView) -> ParseResult {
  match llhttp_execute(buf.bytes, buf.start, buf.len) {
    0 => Ok
    21 => {
      let event = state.event.unwrap()
      state.event = None
      llhttp_resume() |> ignore
      Paused(event, buf[llhttp_get_error_pos(buf.bytes) - buf.start:])
    }
    errno => {
      let event = state.event.unwrap()
      state.event = None
      let reason = match event {
        OnError(reason) => reason
        _ => b"unknown"
      }
      Err(errno, reason)
    }
  }
}
