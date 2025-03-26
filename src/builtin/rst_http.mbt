///|
pub(all) enum ResponseStatus {
  Continue
  SwitchingProtocols
  Processing
  EarlyHints
  ResponseIsStale
  RevalidationFailed
  DisconnectedOperation
  HeuristicExpiration
  MiscellaneousWarning
  Ok
  Created
  Accepted
  NonAuthoritativeInformation
  NoContent
  ResetContent
  PartialContent
  MultiStatus
  AlreadyReported
  TransformationApplied
  ImUsed
  MiscellaneousPersistentWarning
  MultipleChoices
  MovedPermanently
  Found
  SeeOther
  NotModified
  UseProxy
  SwitchProxy
  TemporaryRedirect
  PermanentRedirect
  BadRequest
  Unauthorized
  PaymentRequired
  Forbidden
  NotFound
  MethodNotAllowed
  NotAcceptable
  ProxyAuthenticationRequired
  RequestTimeout
  Conflict
  Gone
  LengthRequired
  PreconditionFailed
  PayloadTooLarge
  UriTooLong
  UnsupportedMediaType
  RangeNotSatisfiable
  ExpectationFailed
  ImATeapot
  PageExpired
  EnhanceYourCalm
  MisdirectedRequest
  UnprocessableEntity
  Locked
  FailedDependency
  TooEarly
  UpgradeRequired
  PreconditionRequired
  TooManyRequests
  RequestHeaderFieldsTooLargeUnofficial
  RequestHeaderFieldsTooLarge
  LoginTimeout
  NoResponse
  RetryWith
  BlockedByParentalControl
  UnavailableForLegalReasons
  ClientClosedLoadBalancedRequest
  InvalidXForwardedFor
  RequestHeaderTooLarge
  SslCertificateError
  SslCertificateRequired
  HttpRequestSentToHttpsPort
  InvalidToken
  ClientClosedRequest
  InternalServerError
  NotImplemented
  BadGateway
  ServiceUnavailable
  GatewayTimeout
  HttpVersionNotSupported
  VariantAlsoNegotiates
  InsufficientStorage
  LoopDetected
  BandwidthLimitExceeded
  NotExtended
  NetworkAuthenticationRequired
  WebServerUnknownError
  WebServerIsDown
  ConnectionTimeout
  OriginIsUnreachable
  TimeoutOccured
  SslHandshakeFailed
  InvalidSslCertificate
  RailgunError
  SiteIsOverloaded
  SiteIsFrozen
  IdentityProviderAuthenticationError
  NetworkReadTimeout
  NetworkConnectTimeout
} derive(Show)

///|
fn status(self : ResponseStatus) -> Int {
  match self {
    Continue => 100
    SwitchingProtocols => 101
    Processing => 102
    EarlyHints => 103
    ResponseIsStale => 110
    RevalidationFailed => 111
    DisconnectedOperation => 112
    HeuristicExpiration => 113
    MiscellaneousWarning => 199
    Ok => 200
    Created => 201
    Accepted => 202
    NonAuthoritativeInformation => 203
    NoContent => 204
    ResetContent => 205
    PartialContent => 206
    MultiStatus => 207
    AlreadyReported => 208
    TransformationApplied => 214
    ImUsed => 226
    MiscellaneousPersistentWarning => 299
    MultipleChoices => 300
    MovedPermanently => 301
    Found => 302
    SeeOther => 303
    NotModified => 304
    UseProxy => 305
    SwitchProxy => 306
    TemporaryRedirect => 307
    PermanentRedirect => 308
    BadRequest => 400
    Unauthorized => 401
    PaymentRequired => 402
    Forbidden => 403
    NotFound => 404
    MethodNotAllowed => 405
    NotAcceptable => 406
    ProxyAuthenticationRequired => 407
    RequestTimeout => 408
    Conflict => 409
    Gone => 410
    LengthRequired => 411
    PreconditionFailed => 412
    PayloadTooLarge => 413
    UriTooLong => 414
    UnsupportedMediaType => 415
    RangeNotSatisfiable => 416
    ExpectationFailed => 417
    ImATeapot => 418
    PageExpired => 419
    EnhanceYourCalm => 420
    MisdirectedRequest => 421
    UnprocessableEntity => 422
    Locked => 423
    FailedDependency => 424
    TooEarly => 425
    UpgradeRequired => 426
    PreconditionRequired => 428
    TooManyRequests => 429
    RequestHeaderFieldsTooLargeUnofficial => 430
    RequestHeaderFieldsTooLarge => 431
    LoginTimeout => 440
    NoResponse => 444
    RetryWith => 449
    BlockedByParentalControl => 450
    UnavailableForLegalReasons => 451
    ClientClosedLoadBalancedRequest => 460
    InvalidXForwardedFor => 463
    RequestHeaderTooLarge => 494
    SslCertificateError => 495
    SslCertificateRequired => 496
    HttpRequestSentToHttpsPort => 497
    InvalidToken => 498
    ClientClosedRequest => 499
    InternalServerError => 500
    NotImplemented => 501
    BadGateway => 502
    ServiceUnavailable => 503
    GatewayTimeout => 504
    HttpVersionNotSupported => 505
    VariantAlsoNegotiates => 506
    InsufficientStorage => 507
    LoopDetected => 508
    BandwidthLimitExceeded => 509
    NotExtended => 510
    NetworkAuthenticationRequired => 511
    WebServerUnknownError => 520
    WebServerIsDown => 521
    ConnectionTimeout => 522
    OriginIsUnreachable => 523
    TimeoutOccured => 524
    SslHandshakeFailed => 525
    InvalidSslCertificate => 526
    RailgunError => 527
    SiteIsOverloaded => 529
    SiteIsFrozen => 530
    IdentityProviderAuthenticationError => 561
    NetworkReadTimeout => 598
    NetworkConnectTimeout => 599
  }
}

///|
fn default_message(self : ResponseStatus) -> String {
  let repr = self.to_string()
  let sb = StringBuilder::new(size_hint=repr.length())
  for i, ch in repr {
    if i > 0 && ch.is_ascii_uppercase() {
      sb.write_char(' ')
    }
    sb.write_char(ch)
  }
  sb.to_string()
}

///|
fn env_recv(buf : Bytes, start : Int, len : Int) -> Int = "env" "recv"

///|
fn recv(buf : BytesView) -> Int {
  env_recv(buf.bytes, buf.start, buf.len)
}

///|
fn env_send(buf : Bytes, start : Int, len : Int) -> Int = "env" "send"

///|
fn send(resp : Response) -> Int {
  let buf = resp.serialize()
  env_send(buf, 0, buf.length())
}

///|
trait StringLike {
  op_get(Self, Int) -> Char
  length(Self) -> Int
}

///|
pub fn url_unquote[T : StringLike](str : T, plus~ : Bool = true) -> String {
  let len = str.length()
  let buf = Buffer::new(size_hint=len)
  fn hex2int {
    '0'..='9' as ch => ch - '0'
    'A'..='F' as ch => ch - 'A' + 10
    'a'..='f' as ch => ch - 'a' + 10
    _ => -1
  }

  for i = 0; i < len; i = i + 1 {
    let ch = str[i]
    if ch == '%' {
      if i + 2 < len {
        let hi = hex2int(str[i + 1])
        if hi >= 0 {
          let lo = hex2int(str[i + 2])
          if lo >= 0 {
            buf.write_byte((hi * 16 + lo).to_byte())
            continue i + 3
          }
        }
      }
    }
    if plus && ch == '+' {
      buf.write_byte(b' ')
    } else {
      buf.write_byte(ch.to_int().to_byte())
    }
  }
  buf.to_bytes().decode()
}

///|
type CaseInsensitiveKey String derive(Show)

///|
fn CaseInsensitiveKey::key(val : String) -> CaseInsensitiveKey {
  CaseInsensitiveKey(val)
}

///|
impl Eq for CaseInsensitiveKey with op_equal(self, other) {
  let len = self._.length()
  guard len == other._.length() else { false }
  for i in 0..<len {
    if self._[i].to_lower() != other._[i].to_lower() {
      break false
    }
  } else {
    true
  }
}

///|
impl Hash for CaseInsensitiveKey with hash_combine(self, hasher) {
  for c in self._ {
    hasher.combine_int(c.to_lower().to_int())
  }
}

///|
struct RequestBuilder {
  mut method_ : Method?
  mut url : String?
  mut version : (Int, Int)?
  headers : Map[CaseInsensitiveKey, String]
  mut complete : Bool
} derive(Default, Show)

///|
pub fn reset(self : RequestBuilder) -> Unit {
  self.method_ = None
  self.url = None
  self.version = None
  self.headers.clear()
  self.complete = false
}

///|
pub(all) struct Context {
  ready : BytesView
  avail : BytesView
  req : RequestBuilder
} derive(Show)

///|
let buf_size : Int = 64 * 1024

///|
pub fn Context::new() -> Context {
  return {
    ready: b""[:],
    avail: Bytes::make(buf_size, b'\x00')[:],
    req: Default::default(),
  }
}

///|
pub(all) enum HttpError {
  ParseError(Int, Bytes)
  IOError(String)
  InternalError(String)
} derive(Show)

///|
pub(all) enum Action[T] {
  Continue(Context)
  Error(HttpError)
  Return(T)
  EOF
} derive(Show)

///|
fn Action::cast[X, Y](self : Action[X]) -> Action[Y] {
  match self {
    Return(_) => abort("cannot cast Return")
    Continue(ctx) => Continue(ctx)
    Error(e) => Error(e)
    EOF => EOF
  }
}

///|
pub fn parse_http[T](
  ctx : Context,
  f : (HttpEvent, Context) -> Action[T]!
) -> Action[T]! {
  loop parse_http_step(ctx.ready), ctx.avail {
    Ok, { len: 0, .. } => continue Ok, Context::new().avail
    Ok, buf => {
      let received = recv(buf)
      if received > 0 {
        continue parse_http_step(buf[:received]), buf[received:]
      } else if received == 0 {
        match llhttp_finish(buf.bytes) {
          0 => EOF
          21 => {
            let event = state.event.unwrap()
            state.event = None
            llhttp_resume() |> ignore
            continue Paused(event, b""[:]), buf
          }
          errno => {
            let event = state.event.unwrap()
            state.event = None
            let reason = match event {
              OnError(reason) => reason
              _ => b""
            }
            continue Err(errno, reason), buf
          }
        }
      } else {
        Error(IOError("Failed to recv(): \{received}"))
      }
    }
    Err(errno, reason), _ => Error(ParseError(errno, reason))
    Paused(event, ready), avail => {
      match event {
        OnMethod(method_) => ctx.req.method_ = Some(method_)
        OnUrl(url) => ctx.req.url = Some(url)
        OnVersion(major, minor) => ctx.req.version = Some((major, minor))
        OnHeader(field, value) =>
          ctx.req.headers[CaseInsensitiveKey(field)] = value
        OnMessageComplete => ctx.req.complete = true
        _ => ()
      }
      match f!(event, { ready, avail, req: ctx.req }) {
        Continue(ctx) => continue parse_http_step(ctx.ready), ctx.avail
        action => action
      }
    }
  }
}

///|
fn skip_header(ctx : Context) -> Action[Context]! {
  parse_http!(ctx, fn {
    OnHeadersComplete, ctx => Return(ctx)
    _, ctx => Continue(ctx)
  })
}

///|
pub fn skip_request(ctx : Context) -> Action[Context]! {
  parse_http!(ctx, fn {
    OnMessageComplete, ctx => Return(ctx)
    _, ctx => Continue(ctx)
  })
}

///|
fn take_body(ctx : Context) -> Action[(Bytes, Context)]! {
  match skip_header!(ctx) {
    Return(ctx) => {
      let size_hint = ctx.req.headers["content-length"]
        .bind(fn(len) {
          Int::from_string?(len).map(fn(len) { Some(len) }).or(None)
        })
        .or(0)
      let content = Buffer::new(size_hint~)
      parse_http!(ctx, fn {
        OnBody(body), ctx => {
          content.write_bytes_view(body)
          Continue(ctx)
        }
        OnMessageComplete, ctx => Return((content.to_bytes(), ctx))
        _, ctx => Continue(ctx)
      })
    }
    rv => rv.cast()
  }
}

///|
struct PathParser {
  url : String
  mut pos : Int
  mut q : Bool
}

///|
enum PathSegment {
  PathPart(String)
  QueryString(StringView)
  PathEnd
} derive(Show)

///|
fn PathParser::of(url : String) -> PathParser {
  { url, pos: if url[0] == '/' { 1 } else { 0 }, q: false }
}

///|
fn next_segment(self : PathParser) -> PathSegment {
  let { url, pos, q } = self
  let len = url.length()
  if q {
    self.pos = len
    self.q = false
    QueryString(url[pos:])
  } else {
    for i = pos; i < len; {
      if url[i] == '/' {
        self.pos = i + 1
        break PathPart(url_unquote(url[pos:i], plus=false))
      } else if url[i] == '?' {
        self.q = true
        self.pos = i + 1
        break PathPart(url_unquote(url[pos:i], plus=false))
      } else {
        continue i + 1
      }
    } else {
      if i == pos {
        PathEnd
      } else {
        self.pos = len
        PathPart(url_unquote(url[pos:], plus=false))
      }
    }
  }
}

///|
pub fn parse_query_args(
  url : StringView,
  f : (String, String?) -> Unit!
) -> Unit! {
  loop url, url.index_of("="), url.index_of("&") {
    s, -1, -1 => if s.length() > 0 { f!(url_unquote(s), None) }
    s, -1, and => {
      f!(url_unquote(s[:and]), None)
      let s = s[and + 1:]
      continue s, -1, s.index_of("&")
    }
    s, eq, -1 => f!(url_unquote(s[:eq]), Some(url_unquote(s[eq + 1:])))
    s, eq, and =>
      if eq < and {
        f!(url_unquote(s[:eq]), Some(url_unquote(s[eq + 1:and])))
        let s = s[and + 1:]
        continue s, s.index_of("="), s.index_of("&")
      } else {
        f!(url_unquote(s[:and]), None)
        let s = s[and + 1:]
        continue s, eq - and - 1, s.index_of("&")
      }
  }
}

///|
struct Response {
  version : (Int, Int)
  status : ResponseStatus
  message : String?
  headers : Map[CaseInsensitiveKey, String]
  body : Bytes
}

///|
fn response(
  version~ : (Int, Int) = (1, 0),
  status~ : ResponseStatus = Ok,
  message~ : String? = None,
  headers~ : Map[CaseInsensitiveKey, String] = Map::new(),
  body : Bytes
) -> Response {
  { version, status, message, headers, body }
}

///|
fn serialize(self : Response) -> Bytes {
  let buf = Buffer::new(size_hint=1024)
  let (major, minor) = self.version
  let status_code = self.status.status()
  let status_message = self.message.or_else(fn() {
    self.status.default_message()
  })
  buf.write_string(
    "HTTP/\{major}.\{minor} \{status_code} \{status_message}\r\n",
  )
  buf.write_string("Access-Control-Allow-Origin: *\r\n")
  buf.write_string("Content-Length: \{self.body.length()}\r\n")
  for key, value in self.headers {
    buf.write_string("\{key._}: \{value}\r\n")
  }
  buf.write_string("\r\n")
  buf.write_bytes(self.body)
  buf.to_bytes()
}

///|
type! ProtocolError String derive(Show)

///|
type! ArgumentError String derive(Show)

///|
fn main {
  for ctx = Context::new() {
    match parse_http?(ctx, dispatch) {
      // Buffer exhausted, continue with new buffer
      Ok(Return({ ready: { len: 0, .. }, avail: { len: 0, .. }, .. })) =>
        continue Context::new()

      // Finished with one request, but we still have available bytes
      // or free buffer, continue with the next pipelined request
      Ok(Return(ctx)) => {
        llhttp_reset() |> ignore
        ctx.req.reset()
        continue ctx
      }

      // Peer closed its writing half of the connection
      Ok(EOF) => break

      // Deal with errors
      Ok(Error(ParseError(errno, reason))) => {
        println("parse error \{errno}: \{reason}")
        break
      }
      Ok(Error(IOError(reason))) => {
        println("I/O error: \{reason}")
        break
      }
      Ok(Error(InternalError(reason))) => {
        println("Internal error: \{reason}")
        break
      }
      Ok(Continue(_)) => abort("unreachable")
      Err(e) => {
        let (status, msg) = match e {
          JsonDecodeError((p, v)) =>
            (BadRequest, "JsonDecodeError: \{p as &Show} \{v}")
          ProtocolError(v) => (InternalServerError, "ProtocolError: \{v}")
          ArgumentError(v) => (BadRequest, "ArgumentError: \{v}")
          _ => (InternalServerError, "Unknown error")
        }
        if ctx.req.complete {
          send(response(status~, Buffer::new()..write_string(msg).to_bytes()))
          |> ignore
        } else {
          ereport(ERROR, "Unexpected error: \{msg}")
        }
        break
      }
    }
  }
}
