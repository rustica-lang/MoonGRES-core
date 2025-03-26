///|
struct InsertUserArgs {
  name : String
  age : Int
  created_at : Timestamptz
  is_active : Bool
  last_login : Timestamp
  account_balance : Int64
  profile : Jsonb
  avatar : Bytes
  subscription_duration : Interval
  birthdate : Date
  preferred_time : Time
  preferred_numbers : Array[Int]
  salary : Double
  score : Float
} derive(Show, FromJson)

///|
struct User {
  id : UUID
  name : String
  age : Int
  created_at : Timestamptz
  is_active : Bool
  last_login : Timestamp
  account_balance : Int64
  profile : Jsonb
  avatar : Bytes
  subscription_duration : Interval
  birthdate : Date
  preferred_time : Time
  preferred_numbers : Array[Int]
  salary : Double
  score : Float
} derive(Show, ToJson)

///|
struct UserByNameArgs {
  name : String
}

///|
struct Queries {
  insert_user : Query[InsertUserArgs, User]
  list_user_by_name : Query[UserByNameArgs, User]
}

///|
let queries : Queries = {
  insert_user: Query::new(
    b"INSERT INTO users (name, age, created_at, is_active, last_login, account_balance, profile, avatar, subscription_duration, birthdate, preferred_time, preferred_numbers, salary, score) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING *",
    args_tids=Some([
      uuid("00000000-0000-0000-0000-000000000101"), // TEXTOID
      uuid("00000000-0000-0000-0000-000000000104"), // INT4OID
      uuid("00000000-0000-0000-0000-00000000010a"), // TIMESTAMPTZOID
      uuid("00000000-0000-0000-0000-000000000109"), // BOOLOID
      uuid("00000000-0000-0000-0000-00000000010b"), // TIMESTAMPOID
      uuid("00000000-0000-0000-0000-000000000105"), // INT8OID
      uuid("00000000-0000-0000-0000-00000000010f"), // JSONBOID
      uuid("00000000-0000-0000-0000-000000000102"), // BYTEAOID
      uuid("00000000-0000-0000-0000-00000000010e"), // INTERVALOID
      uuid("00000000-0000-0000-0000-00000000010c"), // DATEOID
      uuid("00000000-0000-0000-0000-00000000010d"), // TIMEOID
      uuid("574de665-be6f-5562-a55d-448593e7b73d"), // INT2ARRAYOID
      uuid("00000000-0000-0000-0000-000000000107"), // FLOAT8OID
      uuid("00000000-0000-0000-0000-000000000106"), // FLOAT4OID
    ]),
  ),
  list_user_by_name: Query::new(
    b"SELECT * FROM users WHERE name = $1 ORDER BY created_at DESC LIMIT 1",
    args_tids=Some([uuid("00000000-0000-0000-0000-000000000101")]), // TEXTOID
  ),
}

///|
pub fn get_queries(populate_args_oids : Bool) -> Queries {
  if populate_args_oids {
    queries.insert_user.populate_args_oids()
    queries.list_user_by_name.populate_args_oids()
  }
  queries
}

///|
fn return_404(ctx : Context) -> Action[Context]! {
  let rv = skip_request!(ctx)
  match rv {
    Return(_) => send(response(status=NotFound, b"Not found")) |> ignore
    _ => ()
  }
  rv
}

///|
fn handle_insert_user(ctx : Context, _qstr : StringView) -> Action[Context]! {
  match take_body!(ctx) {
    Return((body, ctx)) => {
      let user = queries.insert_user.query_one(json_decode!(body[:])).unwrap()
      send(response(Buffer::new()..write_string(json_encode!(user)).to_bytes()))
      |> ignore
      Return(ctx)
    }
    rv => rv.cast()
  }
}

///|
fn handle_list_user_by_name(
  ctx : Context,
  qstr : StringView
) -> Action[Context]! {
  let mut v_name = None
  parse_query_args!(qstr, fn {
    "name", Some(v) => v_name = Some(v)
    "name", None => raise ArgumentError("required query argument: \"name\"")
    k, _ => raise ArgumentError("unexpected query argument: \"\{k}\"")
  })
  let v_name = v_name.or_error!(
    ArgumentError("required query argument: \"name\""),
  )
  let rv = skip_request!(ctx)
  let result = queries.list_user_by_name.query_all({ name: v_name })
  send(response(Buffer::new()..write_string(json_encode!(result)).to_bytes()))
  |> ignore
  rv
}

///|
fn dispatch(event : HttpEvent, ctx : Context) -> Action[Context]! {
  match event {
    OnMessageBegin => Continue(ctx)
    OnMethod(POST) =>
      parse_http!(ctx, fn {
        OnUrl(url), ctx => {
          let parser = PathParser::of(url)
          match parser.next_segment() {
            PathPart("users") =>
              match parser.next_segment() {
                PathEnd => handle_insert_user!(ctx, ""[:])
                QueryString(qstr) => handle_insert_user!(ctx, qstr)
                _ => return_404!(ctx)
              }
            _ => return_404!(ctx)
          }
        }
        _, _ => raise ProtocolError("bad protocol")
      })
    OnMethod(GET) =>
      parse_http!(ctx, fn {
        OnUrl(url), ctx => {
          let parser = PathParser::of(url)
          match parser.next_segment() {
            PathPart("users") =>
              match parser.next_segment() {
                PathEnd => handle_list_user_by_name!(ctx, ""[:])
                QueryString(qstr) => handle_list_user_by_name!(ctx, qstr)
                _ => return_404!(ctx)
              }
            _ => return_404!(ctx)
          }
        }
        _, _ => raise ProtocolError("bad protocol")
      })
    OnMethod(_) => return_404!(ctx)
    OnError(e) => raise ProtocolError(e[:].decode())
    _ => Error(InternalError("bad protocol"))
  }
}
