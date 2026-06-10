const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const db = require('./db');
const bcrypt = require('bcryptjs');

let serviceAccount;

if (process.env.FIREBASE_CONFIG) {
  try {
    serviceAccount = JSON.parse(process.env.FIREBASE_CONFIG);
    console.log('Loaded Firebase config from environment variable.');
  } catch (e) {
    console.error('Failed to parse FIREBASE_CONFIG env variable:', e.message);
  }
}

if (!serviceAccount) {
  try {
    serviceAccount = require('./finder-9959b-firebase-adminsdk-fbsvc-4ad8b53f21.json');
    console.log('Loaded Firebase config from local JSON file.');
  } catch (e) {
    console.error('Failed to load local firebase-key JSON file:', e.message);
  }
}

if (!serviceAccount) {
  console.error('Error: No Firebase configuration found. Please set FIREBASE_CONFIG or place the key file in backend folder.');
  process.exit(1);
}

initializeApp({
  credential: cert(serviceAccount)
});

const firestore = getFirestore();

// Helper to encrypt a placeholder password for users
async function getPlaceholderPasswordHash() {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash('FinderChangeMe123!', salt);
}

async function runMigration() {
  console.log('Starting migration from Firebase to Railway PostgreSQL...');
  
  // Verify DB connection
  console.log('Using database:', db.isPostgres ? 'PostgreSQL' : 'SQLite');
  
  const passwordHash = await getPlaceholderPasswordHash();
  
  // 1. Migrate Users
  console.log('Migrating Users...');
  const usersSnapshot = await firestore.collection('users').get();
  let userCount = 0;
  for (const doc of usersSnapshot.docs) {
    const data = doc.data();
    const uid = doc.id;
    const email = (data.email || '').toLowerCase().trim();
    if (!email) continue;
    
    const fullName = data.fullName || '';
    const nickName = data.nickName || email.split('@')[0];
    const phone = data.phone || '';
    const address = data.address || '';
    const job = data.job || '';
    const avatarUrl = data.avatarUrl || '';
    
    // Convert timestamps
    let createdAt = Date.now();
    let updatedAt = Date.now();
    
    if (data.createdAt) {
      createdAt = data.createdAt.seconds ? data.createdAt.seconds * 1000 : parseInt(data.createdAt);
    }
    if (data.updatedAt) {
      updatedAt = data.updatedAt.seconds ? data.updatedAt.seconds * 1000 : parseInt(data.updatedAt);
    }

    if (isNaN(createdAt)) createdAt = Date.now();
    if (isNaN(updatedAt)) updatedAt = Date.now();

    try {
      // Check if user already exists
      const existing = await db.queryOne('SELECT uid FROM users WHERE uid = $1', [uid]);
      if (!existing) {
        await db.exec(
          `INSERT INTO users (uid, email, password_hash, full_name, nick_name, phone, address, job, avatar_url, created_at, updated_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
          [uid, email, passwordHash, fullName, nickName, phone, address, job, avatarUrl, createdAt, updatedAt]
        );
        userCount++;
      } else {
        console.log(`User ${email} already exists in SQL database, skipping...`);
      }
    } catch (err) {
      console.error(`Error migrating user ${email}:`, err.message);
    }
  }
  console.log(`Successfully migrated ${userCount} users.`);

  // 2. Migrate Posts
  console.log('Migrating Posts...');
  const postsSnapshot = await firestore.collection('posts').get();
  let postCount = 0;
  for (const doc of postsSnapshot.docs) {
    const data = doc.data();
    const id = doc.id;
    const ownerId = data.ownerId;
    if (!ownerId) continue;
    
    const title = data.title || '';
    const description = data.description || '';
    const category = data.category || 'All Items';
    const isLost = data.isLost === undefined ? true : !!data.isLost;
    const reward = data.reward || null;
    const location = data.location || '';
    const imageUrl = data.imageUrl || data.imagePath || '';
    const status = data.status || 'active';
    
    let createdAtMs = Date.now();
    let updatedAtMs = Date.now();
    if (data.createdAtMs) createdAtMs = parseInt(data.createdAtMs);
    else if (data.createdAt) createdAtMs = data.createdAt.seconds ? data.createdAt.seconds * 1000 : parseInt(data.createdAt);
    
    if (data.updatedAtMs) updatedAtMs = parseInt(data.updatedAtMs);
    else if (data.updatedAt) updatedAtMs = data.updatedAt.seconds ? data.updatedAt.seconds * 1000 : parseInt(data.updatedAt);

    if (isNaN(createdAtMs)) createdAtMs = Date.now();
    if (isNaN(updatedAtMs)) updatedAtMs = Date.now();

    try {
      const existing = await db.queryOne('SELECT id FROM posts WHERE id = $1', [id]);
      if (!existing) {
        await db.exec(
          `INSERT INTO posts (id, owner_id, title, description, category, is_lost, reward, location, image_url, status, created_at_ms, updated_at_ms)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)`,
          [id, ownerId, title, description, category, isLost, reward, location, imageUrl, status, createdAtMs, updatedAtMs]
        );
        postCount++;
      }
    } catch (err) {
      console.error(`Error migrating post ${id}:`, err.message);
    }
  }
  console.log(`Successfully migrated ${postCount} posts.`);

  // 3. Migrate Chats
  console.log('Migrating Chats & Messages...');
  const chatsSnapshot = await firestore.collection('chats').get();
  let chatCount = 0;
  let messageCount = 0;
  for (const doc of chatsSnapshot.docs) {
    const data = doc.data();
    const id = doc.id;
    const postId = data.postId;
    if (!postId) continue;
    
    const itemName = data.itemName || 'Item';
    const lastMessageText = data.lastMessageText || '';
    const lastSenderId = data.lastSenderId || null;
    
    let createdAtMs = Date.now();
    let updatedAtMs = Date.now();
    if (data.createdAtMs) createdAtMs = parseInt(data.createdAtMs);
    if (data.updatedAtMs) updatedAtMs = parseInt(data.updatedAtMs);
    if (isNaN(createdAtMs)) createdAtMs = Date.now();
    if (isNaN(updatedAtMs)) updatedAtMs = Date.now();

    try {
      const existing = await db.queryOne('SELECT id FROM chats WHERE id = $1', [id]);
      if (!existing) {
        await db.exec(
          `INSERT INTO chats (id, post_id, item_name, last_message_text, last_sender_id, created_at_ms, updated_at_ms)
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [id, postId, itemName, lastMessageText, lastSenderId, createdAtMs, updatedAtMs]
        );
        chatCount++;

        // Migrate participants
        const participants = data.participants || [];
        const unreadCounts = data.unreadCounts || {};
        for (const userId of participants) {
          const unreadCount = parseInt(unreadCounts[userId]) || 0;
          try {
            await db.exec(
              `INSERT INTO chat_participants (chat_id, user_id, unread_count)
               VALUES ($1, $2, $3)
               ON CONFLICT (chat_id, user_id) DO NOTHING`,
              [id, userId, unreadCount]
            );
          } catch (pe) {
            console.error(`Error adding participant ${userId} to chat ${id}:`, pe.message);
          }
        }
      }

      // Migrate messages subcollection
      const messagesSnapshot = await firestore.collection('chats').doc(id).collection('messages').get();
      for (const mDoc of messagesSnapshot.docs) {
        const mData = mDoc.data();
        const mId = mDoc.id;
        const senderId = mData.senderId;
        const text = mData.text || '';
        if (!senderId || !text) continue;
        
        const isRead = mData.isRead === undefined ? false : !!mData.isRead;
        let mCreatedAtMs = Date.now();
        if (mData.createdAtMs) mCreatedAtMs = parseInt(mData.createdAtMs);
        if (isNaN(mCreatedAtMs)) mCreatedAtMs = Date.now();

        try {
          const mExisting = await db.queryOne('SELECT id FROM messages WHERE id = $1', [mId]);
          if (!mExisting) {
            await db.exec(
              `INSERT INTO messages (id, chat_id, sender_id, text, is_read, created_at_ms)
               VALUES ($1, $2, $3, $4, $5, $6)`,
              [mId, id, senderId, text, isRead, mCreatedAtMs]
            );
            messageCount++;
          }
        } catch (me) {
          console.error(`Error migrating message ${mId} for chat ${id}:`, me.message);
        }
      }
    } catch (err) {
      console.error(`Error migrating chat ${id}:`, err.message);
    }
  }
  console.log(`Successfully migrated ${chatCount} chats and ${messageCount} messages.`);

  // 4. Migrate Blocked Users, Saved Items, and Settings per user
  console.log('Migrating subcollections (blocked users, saved items, settings) for each user...');
  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;

    // Blocked Users
    try {
      const blockedSnapshot = await firestore.collection('users').doc(userId).collection('blockedUsers').get();
      for (const bDoc of blockedSnapshot.docs) {
        const blockedUserId = bDoc.id;
        try {
          await db.exec(
            `INSERT INTO blocked_users (user_id, blocked_user_id)
             VALUES ($1, $2)
             ON CONFLICT (user_id, blocked_user_id) DO NOTHING`,
            [userId, blockedUserId]
          );
        } catch (e) {
          console.error(`Error migrating blocked user ${blockedUserId} for user ${userId}:`, e.message);
        }
      }
    } catch (_) {}

    // Saved Items
    try {
      const savedSnapshot = await firestore.collection('users').doc(userId).collection('savedItems').get();
      for (const sDoc of savedSnapshot.docs) {
        const postId = sDoc.id;
        try {
          await db.exec(
            `INSERT INTO saved_items (user_id, post_id)
             VALUES ($1, $2)
             ON CONFLICT (user_id, post_id) DO NOTHING`,
            [userId, postId]
          );
        } catch (e) {
          console.error(`Error migrating saved item ${postId} for user ${userId}:`, e.message);
        }
      }
    } catch (_) {}

    // Settings
    try {
      const settingsSnapshot = await firestore.collection('users').doc(userId).collection('settings').get();
      for (const setDoc of settingsSnapshot.docs) {
        const setData = setDoc.data();
        const showProfile = setData.showProfile === undefined ? true : !!setData.showProfile;
        const allowMessages = setData.allowMessages === undefined ? true : !!setData.allowMessages;
        const showLocation = setData.showLocation === undefined ? false : !!setData.showLocation;
        const hidePhone = setData.hidePhone === undefined ? true : !!setData.hidePhone;

        try {
          await db.exec(
            `INSERT INTO user_settings (user_id, show_profile, allow_messages, show_location, hide_phone)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (user_id) DO UPDATE 
             SET show_profile = EXCLUDED.show_profile, allow_messages = EXCLUDED.allow_messages, show_location = EXCLUDED.show_location, hide_phone = EXCLUDED.hide_phone`,
            [userId, showProfile, allowMessages, showLocation, hidePhone]
          );
        } catch (e) {
          console.error(`Error migrating settings for user ${userId}:`, e.message);
        }
      }
    } catch (_) {}
  }

  console.log('Migration completed successfully! 🎉');
  process.exit(0);
}

if (require.main === module) {
  runMigration().catch(err => {
    console.error('Migration failed:', err);
    process.exit(1);
  });
}

module.exports = { runMigration };
