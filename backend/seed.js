// Idempotent demo seed. Run with: npm run seed
//
// Creates four demo accounts (password Demo1234!), ten posts, two chats with
// messages, notifications, saved items and settings. Every seeded row uses a
// "seed-" prefixed id so re-running replaces exactly the same data.
require('./env').loadEnv();

if (process.env.NODE_ENV === 'production' && process.env.SEED_FORCE !== '1') {
  console.error('Refusing to seed demo data into a production database. Set SEED_FORCE=1 to override.');
  process.exit(1);
}

const bcrypt = require('bcryptjs');
const db = require('./db');
const { bool } = require('./lib/helpers');

const PUBLIC = (process.env.SEED_PUBLIC_URL || 'http://localhost:3001').replace(/\/$/, '');
const PASSWORD = 'Demo1234!';
const img = f => `${PUBLIC}/static/${f}`;

const USERS = [
  { uid: 'seed-user-demo', email: 'demo@finder.app', fullName: 'Alex Rivera', nickName: 'alex', phone: '+1 555 0100', address: 'Portland, OR', job: 'Product designer', avatar: img('avatar-demo.png'), verified: true },
  { uid: 'seed-user-sara', email: 'sara@finder.app', fullName: 'Sara Ahmed', nickName: 'sara', phone: '+1 555 0101', address: 'Portland, OR', job: 'Teacher', avatar: img('avatar-sara.png'), verified: true },
  { uid: 'seed-user-omar', email: 'omar@finder.app', fullName: 'Omar Haddad', nickName: 'omar', phone: '+1 555 0102', address: 'Beaverton, OR', job: 'Barista', avatar: img('avatar-omar.png'), verified: false },
  { uid: 'seed-user-lina', email: 'lina@finder.app', fullName: 'Lina Park', nickName: 'lina', phone: '+1 555 0103', address: 'Lake Oswego, OR', job: 'Nurse', avatar: img('avatar-lina.png'), verified: false },
];

const H = 60 * 60 * 1000;
const D = 24 * H;
const now = Date.now();

const POSTS = [
  { id: 'seed-post-01', owner: 'seed-user-sara', title: 'Brown leather wallet', description: 'Lost near the fountain at Central Park. Has a small scratch on the front and a photo of a dog inside. Cards and ID are in it, no cash.', category: 'Wallets & Bags', isLost: true, reward: '50', location: 'Central Park, near the fountain', image: img('wallet.jpg'), lostOn: '2026-09-12 18:30', age: 2 * H },
  { id: 'seed-post-02', owner: 'seed-user-omar', title: 'Set of car keys with a red keychain', description: 'Found on a bench outside the library. Toyota key, two house keys and a small Eiffel Tower charm.', category: 'Keys', isLost: false, reward: null, location: 'City Library, main entrance', image: img('keys.jpg'), lostOn: null, age: 5 * H },
  { id: 'seed-post-03', owner: 'seed-user-demo', title: 'iPhone 15 in a pink case', description: 'Left in a taxi on the way to the airport. Lock screen shows a mountain photo. Please message me, I can describe the case.', category: 'Electronics', isLost: true, reward: '200', location: 'Airport road', image: '', lostOn: '2026-09-11 07:45', age: 1 * D },
  { id: 'seed-post-04', owner: 'seed-user-lina', title: 'Golden retriever, answers to Max', description: 'Very friendly, wearing a blue collar with no tag. Found wandering near the river trail, safe with me for now.', category: 'Pets', isLost: false, reward: null, location: 'Riverside trail', image: '', lostOn: null, age: 1 * D + 3 * H },
  { id: 'seed-post-05', owner: 'seed-user-demo', title: 'Silver necklace with a moon pendant', description: 'Sentimental value. Probably lost in the gym locker room on Tuesday evening.', category: 'Watches & Jewelry', isLost: true, reward: null, location: 'Downtown Fitness', image: img('necklace.jpg'), lostOn: '2026-09-09 19:00', age: 3 * D, resolved: true },
  { id: 'seed-post-06', owner: 'seed-user-sara', title: 'Black umbrella with wooden handle', description: 'Found on the 14 bus, left on the back seat. Handle has the initials J.M. carved in.', category: 'Other', isLost: false, reward: null, location: 'Bus line 14', image: '', lostOn: null, age: 6 * H },
  { id: 'seed-post-07', owner: 'seed-user-omar', title: 'Student ID card - Portland State', description: 'Lost somewhere between the campus library and the food carts. Name on the card is Omar H.', category: 'Documents', isLost: true, reward: '20', location: 'PSU campus', image: '', lostOn: '2026-09-12 13:00', age: 20 * H },
  { id: 'seed-post-08', owner: 'seed-user-lina', title: 'Kids denim jacket, size 6', description: 'Found at the playground near the swings. Has a dinosaur patch on the sleeve.', category: 'Clothing', isLost: false, reward: null, location: 'Laurelhurst Park playground', image: '', lostOn: null, age: 2 * D },
  { id: 'seed-post-09', owner: 'seed-user-sara', title: 'AirPods Pro in a green case', description: 'Lost during my run along the waterfront. The case has a small sticker of a cat.', category: 'Electronics', isLost: true, reward: '40', location: 'Waterfront Park', image: '', lostOn: '2026-09-13 07:10', age: 40 * 60 * 1000 },
  { id: 'seed-post-10', owner: 'seed-user-demo', title: 'Grey house keys on a carabiner', description: 'Found on the sidewalk outside the coffee shop on 3rd Ave. Three keys and a gym fob.', category: 'Keys', isLost: false, reward: null, location: '3rd Ave, coffee shop', image: '', lostOn: null, age: 4 * D },
];

function chatId(postId, a, b) {
  const ids = [a, b].sort();
  return `${postId}_${ids[0]}_${ids[1]}`;
}

const CHATS = [
  {
    id: chatId('seed-post-01', 'seed-user-demo', 'seed-user-sara'),
    postId: 'seed-post-01', itemName: 'Brown leather wallet',
    a: 'seed-user-demo', b: 'seed-user-sara',
    messages: [
      { from: 'seed-user-demo', text: 'Hi Sara! I think I found your wallet near the east gate.', age: 90 * 60 * 1000 },
      { from: 'seed-user-sara', text: 'Oh amazing! Is there a scratch on the front, left side?', age: 80 * 60 * 1000 },
      { from: 'seed-user-demo', text: 'Yes, and a photo of a golden retriever inside.', age: 70 * 60 * 1000 },
      { from: 'seed-user-sara', text: "That's mine! Can we meet at the park cafe tomorrow at 10?", age: 4 * 60 * 1000 },
    ],
  },
  {
    id: chatId('seed-post-02', 'seed-user-demo', 'seed-user-omar'),
    postId: 'seed-post-02', itemName: 'Set of car keys with a red keychain',
    a: 'seed-user-demo', b: 'seed-user-omar',
    messages: [
      { from: 'seed-user-demo', text: 'Hey Omar, are those Toyota keys still with you?', age: 7 * H },
      { from: 'seed-user-omar', text: 'Yes! Do you know whose they are?', age: 6.5 * H },
      { from: 'seed-user-demo', text: 'My neighbour lost hers yesterday, I will ask her to message you.', age: 6 * H },
    ],
  },
];

async function upsertUser(u) {
  const hash = await bcrypt.hash(PASSWORD, 10);
  const existing = await db.queryOne('SELECT uid FROM users WHERE email = $1', [u.email]);
  if (existing) {
    await db.exec(
      `UPDATE users SET password_hash = $1, full_name = $2, nick_name = $3, phone = $4, address = $5, job = $6,
              avatar_url = $7, is_verified = $8, identity_verified = $9, updated_at = $10 WHERE email = $11`,
      [hash, u.fullName, u.nickName, u.phone, u.address, u.job, u.avatar, bool(true), bool(u.verified), now, u.email]
    );
    return existing.uid;
  }
  await db.exec(
    `INSERT INTO users (uid, email, password_hash, full_name, nick_name, phone, address, job, avatar_url, created_at, updated_at, is_verified, identity_verified)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
    [u.uid, u.email, hash, u.fullName, u.nickName, u.phone, u.address, u.job, u.avatar, now - 120 * D, now, bool(true), bool(u.verified)]
  );
  return u.uid;
}

async function run() {
  await db.initDb();
  console.log('Seeding demo data...');

  const uidByKey = {};
  for (const u of USERS) uidByKey[u.uid] = await upsertUser(u);
  const uid = key => uidByKey[key] || key;

  // Wipe previous seed rows (order matters for FK-enabled databases).
  await db.exec(`DELETE FROM messages WHERE chat_id LIKE 'seed-%'`);
  await db.exec(`DELETE FROM chat_participants WHERE chat_id LIKE 'seed-%'`);
  await db.exec(`DELETE FROM chats WHERE id LIKE 'seed-%'`);
  await db.exec(`DELETE FROM notifications WHERE id LIKE 'seed-%'`);
  await db.exec(`DELETE FROM saved_items WHERE post_id LIKE 'seed-%'`);
  await db.exec(`DELETE FROM reports WHERE post_id LIKE 'seed-%'`);
  await db.exec(`DELETE FROM posts WHERE id LIKE 'seed-%'`);

  for (const p of POSTS) {
    const created = now - p.age;
    await db.exec(
      `INSERT INTO posts (id, owner_id, title, description, category, is_lost, reward, location, image_url, lost_on, status, created_at_ms, updated_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
      [p.id, uid(p.owner), p.title, p.description, p.category, bool(p.isLost), p.reward, p.location, p.image, p.lostOn, p.resolved ? 'resolved' : 'active', created, created]
    );
  }

  for (const c of CHATS) {
    const a = uid(c.a), b = uid(c.b);
    const id = chatId(c.postId, a, b);
    const last = c.messages[c.messages.length - 1];
    const updated = now - last.age;
    await db.exec(
      `INSERT INTO chats (id, post_id, item_name, last_message_text, last_sender_id, created_at_ms, updated_at_ms)
       VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [id, c.postId, c.itemName, last.text, uid(last.from), now - c.messages[0].age, updated]
    );
    // unread for whoever did not send the last message
    const lastSender = uid(last.from);
    const unreadFor = lastSender === a ? b : a;
    const unread = c.messages.filter(m => uid(m.from) === lastSender).length >= 1 ? 1 : 0;
    await db.exec('INSERT INTO chat_participants (chat_id, user_id, unread_count) VALUES ($1, $2, $3)', [id, a, a === unreadFor ? unread : 0]);
    await db.exec('INSERT INTO chat_participants (chat_id, user_id, unread_count) VALUES ($1, $2, $3)', [id, b, b === unreadFor ? unread : 0]);
    let n = 0;
    for (const m of c.messages) {
      n += 1;
      await db.exec(
        `INSERT INTO messages (id, chat_id, sender_id, text, image_url, is_read, created_at_ms)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [`${id}-m${n}`, id, uid(m.from), m.text, '', bool(true), now - m.age]
      );
    }
  }

  const demo = uid('seed-user-demo');
  const NOTIFS = [
    { id: 'seed-notif-1', title: 'Possible match found', message: 'A found "wallet" was posted 400 m from your last seen location.', type: 'match', unread: true, age: 5 * 60 * 1000 },
    { id: 'seed-notif-2', title: 'Sara Ahmed · Brown leather wallet', message: "That's mine! Can we meet at the park cafe tomorrow at 10?", type: 'message', unread: true, age: 4 * 60 * 1000 },
    { id: 'seed-notif-3', title: 'Item resolved', message: '"Silver necklace with a moon pendant" has been marked as resolved.', type: 'update', unread: false, age: 3 * D },
    { id: 'seed-notif-4', title: 'Welcome to Finder', message: 'Tip: add clear photos and a precise location to get matches faster.', type: 'system', unread: false, age: 120 * D },
  ];
  for (const nf of NOTIFS) {
    await db.exec(
      `INSERT INTO notifications (id, user_id, title, message, type, is_unread, created_at_ms) VALUES ($1, $2, $3, $4, $5, $6, $7)`,
      [nf.id, demo, nf.title, nf.message, nf.type, bool(nf.unread), now - nf.age]
    );
  }

  await db.exec('INSERT INTO saved_items (user_id, post_id) VALUES ($1, $2)', [demo, 'seed-post-02']);
  await db.exec('INSERT INTO saved_items (user_id, post_id) VALUES ($1, $2)', [demo, 'seed-post-04']);

  // Settings: Sara shares her phone so the demo shows the Call button.
  const { saveSettings } = require('./lib/helpers');
  await saveSettings(uid('seed-user-sara'), { hide_phone: false });
  await saveSettings(demo, {});

  console.log('\nDemo accounts (password for all: ' + PASSWORD + ')');
  for (const u of USERS) console.log(`  ${u.email}  (${u.fullName}${u.verified ? ', identity verified' : ''})`);
  console.log('\nMigrated legacy accounts keep the password: FinderChangeMe123!');
  console.log(`Images are served from ${PUBLIC}/static/`);
  console.log('Done.');
  process.exit(0);
}

run().catch(err => {
  console.error('Seed failed:', err);
  process.exit(1);
});
