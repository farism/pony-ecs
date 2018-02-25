use "game"
use "websocket"

actor Main

  let _game: Game

  var _listener: (WebSocketListener | None) = None

  new create(env: Env) =>
    try
      _listener = WebSocketListener(
        env.root as AmbientAuth,
        recover SimpleServer(EchoWebSocketNotify) end,
        "127.0.0.1","8989"
      )
    end

    _game = Game(env)


actor EchoWebSocketNotify is SimpleWebSocketNotify

  be opened(conn: WebSocketConnection tag) =>
    @printf[I32]("New client connected\n".cstring())

  be text_received(conn: WebSocketConnection tag, text: String) =>
    conn.send_text(text)

  be binary_received(conn: WebSocketConnection tag, data: Array[U8] val) =>
    conn.send_binary(data)

  be closed(conn: WebSocketConnection tag) =>
    @printf[I32]("Connection closed\n".cstring())
