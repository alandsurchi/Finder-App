const ws = require('ws');
const jwt = require('jsonwebtoken');
const db = require('./db');
const crypto = require('crypto');

const JWT_SECRET = process.env.JWT_SECRET || 'finder_secret_key_12345';

// Map of userId -> Set of active WebSocket connections
const clients = new Map();

function initWebSocket(server) {
  const wss = new ws.Server({ noServer: true });

  server.on('upgrade', (request, socket, head) => {
    wss.handleUpgrade(request, socket, head, (wsConnection) => {
      wss.emit('connection', wsConnection, request);
    });
  });

  wss.on('connection', (wsConn) => {
    console.log('New WebSocket connection established.');
    let currentUserId = null;

    wsConn.on('message', async (messageData) => {
      try {
        const payload = JSON.parse(messageData.toString());

        if (payload.type === 'auth') {
          const { token } = payload;
          if (!token) {
            wsConn.send(JSON.stringify({ type: 'error', message: 'Auth token missing.' }));
            return wsConn.close();
          }

          try {
            const decoded = jwt.verify(token, JWT_SECRET);
            currentUserId = decoded.userId;
            
            // Add connection to clients map
            if (!clients.has(currentUserId)) {
              clients.set(currentUserId, new Set());
            }
            clients.get(currentUserId).add(wsConn);
            
            console.log(`WebSocket client authenticated. User ID: ${currentUserId}`);
            wsConn.send(JSON.stringify({ type: 'authenticated', userId: currentUserId }));
          } catch (err) {
            wsConn.send(JSON.stringify({ type: 'error', message: 'Invalid token.' }));
            return wsConn.close();
          }
        } else if (payload.type === 'message') {
          if (!currentUserId) {
            return wsConn.send(JSON.stringify({ type: 'error', message: 'Not authenticated.' }));
          }

          const { chatId, text, recipientId } = payload;
          if (!chatId || !text || !recipientId) {
            return wsConn.send(JSON.stringify({ type: 'error', message: 'chatId, text, and recipientId are required.' }));
          }

          // Save message to database
          const messageId = crypto.randomUUID();
          const now = Date.now();

          await db.exec(
            `INSERT INTO messages (id, chat_id, sender_id, text, is_read, created_at_ms)
             VALUES ($1, $2, $3, $4, $5, $6)`,
            [messageId, chatId, currentUserId, text.trim(), false, now]
          );

          // Update chat last message metadata
          await db.exec(
            `UPDATE chats 
             SET last_message_text = $1, last_sender_id = $2, updated_at_ms = $3
             WHERE id = $4`,
            [text.trim(), currentUserId, now, chatId]
          );

          // Increment unread count for recipient
          await db.exec(
            `UPDATE chat_participants 
             SET unread_count = unread_count + 1 
             WHERE chat_id = $1 AND user_id = $2`,
            [chatId, recipientId]
          );

          const messageResponse = {
            type: 'message',
            id: messageId,
            chatId,
            senderId: currentUserId,
            text: text.trim(),
            createdAtMs: now,
            isRead: false
          };

          // Send to sender (echo/confirmation)
          wsConn.send(JSON.stringify(messageResponse));

          // Send to recipient if online
          if (clients.has(recipientId)) {
            const recipientSockets = clients.get(recipientId);
            recipientSockets.forEach(sock => {
              if (sock.readyState === ws.OPEN) {
                sock.send(JSON.stringify(messageResponse));
              }
            });
          }

          // Trigger database-based in-app notification for the recipient
          try {
            // Find sender display name
            const sender = await db.queryOne('SELECT full_name, nick_name FROM users WHERE uid = $1', [currentUserId]);
            const senderName = sender ? (sender.full_name || sender.nick_name) : 'Someone';

            // Find chat metadata to get item/post title
            const chat = await db.queryOne('SELECT item_name FROM chats WHERE id = $1', [chatId]);
            const postTitle = chat ? chat.item_name : 'your post';

            const notificationId = crypto.randomUUID();
            await db.exec(
              `INSERT INTO notifications (id, user_id, title, message, type, is_unread, created_at_ms)
               VALUES ($1, $2, $3, $4, $5, $6, $7)`,
              [
                notificationId,
                recipientId,
                `💬 New message from ${senderName}`,
                `Regarding: "${postTitle}"`,
                'newMessage',
                true,
                now
              ]
            );

            // If recipient is online, notify them of the new notification
            if (clients.has(recipientId)) {
              const recipientSockets = clients.get(recipientId);
              recipientSockets.forEach(sock => {
                if (sock.readyState === ws.OPEN) {
                  sock.send(JSON.stringify({
                    type: 'notification',
                    id: notificationId,
                    title: `💬 New message from ${senderName}`,
                    message: `Regarding: "${postTitle}"`,
                    notificationType: 'newMessage',
                    isUnread: true,
                    createdAtMs: now
                  }));
                }
              });
            }
          } catch (notifErr) {
            console.error('WebSocket message notification failed:', notifErr);
          }
        }
      } catch (err) {
        console.error('WebSocket message parsing error:', err);
        wsConn.send(JSON.stringify({ type: 'error', message: 'Invalid message payload format.' }));
      }
    });

    wsConn.on('close', () => {
      if (currentUserId && clients.has(currentUserId)) {
        const userSockets = clients.get(currentUserId);
        userSockets.delete(wsConn);
        if (userSockets.size === 0) {
          clients.delete(currentUserId);
        }
        console.log(`WebSocket client disconnected. User ID: ${currentUserId}`);
      } else {
        console.log('Unauthenticated WebSocket client disconnected.');
      }
    });
  });
}

module.exports = {
  initWebSocket
};
