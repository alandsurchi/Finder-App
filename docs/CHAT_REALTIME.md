# Chat realtime, receipts and presence

REST stays the source of truth; the WebSocket (`backend/websocket.js`) only
pushes what the routes already stored. The app polls every 3 s without a
socket and every 20 s with one.

## Connection

`wss://<host>/ws?token=<jwt>` (the legacy first message `{type:'auth', token}`
is still accepted). Banned users are closed with code 4401. The server pings
every 30 s and drops sockets that do not pong. `users.last_seen_ms` is written
on connect, every minute while connected, and on disconnect.

## Events

Server → client

| type | payload |
|---|---|
| `authenticated` | `{userId}` |
| `presence.snapshot` | `{users:[{userId, online, lastSeenMs}]}` for everyone you share a chat with |
| `presence` | `{userId, online, lastSeenMs}` on first connect / last disconnect |
| `message.new` | `{chatId, message}` to every participant (your other devices too) |
| `message.delivered` | `{chatId, userId, deliveredAtMs}` |
| `message.read` | `{chatId, userId, readAtMs}` |
| `message.deleted` | `{chatId, messageId}` |
| `typing` | `{chatId, userId, isTyping}` |

Client → server: `typing {chatId, isTyping}`, `delivered {chatId}`,
`read {chatId}`, `ping`.

## Ticks

Per participant watermarks in `chat_participants`: `last_delivered_at_ms`
and `last_read_at_ms`. A message is delivered/read when it was sent before
the peer's watermark (`mapMessage(row, watermarks)`). Delivered is set when
the peer lists their chats, fetches the first page, or acks over the socket;
read when they open the chat (`GET /chats/:id/messages` without cursor,
`PUT /chats/:id/read`, or `read` over the socket).

App rule (own messages only): clock = sending, one grey tick = sent, two grey
= delivered, two blue (`tickRead` token) = seen.

## Messages API additions

- `POST /chats/:id/messages` accepts `waveform` (≤ 64 ints 0-100, voice only)
  and `forwardOf` (id of a message from any chat you take part in).
- `GET /chats/:id/messages` returns `peerReadAtMs`, `peerDeliveredAtMs` and
  `myReadAtMsBefore` (for the "unread messages" divider).
- `DELETE /chats/:id/messages/:mid?scope=me` hides a message for one account
  (`message_hidden`); without `scope` the sender deletes it for everyone.
- `GET /chats` adds `peerPresence`, `lastMessageRead`, `lastMessageDelivered`,
  `lastMessageId` and translates `itemName` into the viewer language.
- Push notifications for new messages go only to participants without an
  open socket.

## Voice notes

The recorder samples the input level ten times a second and stores 40
buckets with the message. Gestures: hold to record (release sends, slide
inwards cancels, slide up locks), or tap once to start hands-free and tap
again to send. Playback offers 1×, 1.5× and 2×.
