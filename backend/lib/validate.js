// Request validation with zod. Each schema strips unknown keys, so handlers
// only ever see the fields they declared.
const { z } = require('zod');

const CATEGORIES = [
  'Electronics', 'Watches & Jewelry', 'Wallets & Bags', 'Keys',
  'Pets', 'Clothing', 'Documents', 'Other',
];

const trimmed = (max, min = 0) => z.string().trim().min(min).max(max);
const optionalTrimmed = max => z.string().trim().max(max).optional();
const httpUrl = max => z.string().trim().max(max).refine(
  v => v === '' || /^https?:\/\/\S+$/i.test(v),
  { message: 'must be an http(s) URL' }
);
const email = z.string().trim().toLowerCase().email().max(254);
const password = z.string()
  .min(8, 'Password must be at least 8 characters.')
  .max(128, 'Password is too long.')
  .refine(v => /[A-Za-z]/.test(v) && /\d/.test(v), {
    message: 'Password must contain at least one letter and one number.',
  });
const sixDigits = z.string().trim().regex(/^\d{6}$/, 'Code must be 6 digits.');
const id = z.string().trim().min(1).max(200);
const verificationRef = z.string().trim().max(500).refine(
  v => v === '' || /^https:\/\//i.test(v) || /^[A-Za-z0-9_.-]{8,200}$/.test(v),
  'must be an upload id or an https URL'
);
const optionalBool = z.boolean().optional();

const schemas = {
  signup: z.object({
    email,
    password,
    fullName: optionalTrimmed(80),
    phone: optionalTrimmed(30),
  }),
  login: z.object({ email, password: z.string().min(1).max(128) }),
  forgotPassword: z.object({ email }),
  verifyResetCode: z.object({ email, code: sixDigits }),
  resetPassword: z.object({ email, code: sixDigits, newPassword: password }),
  verifyEmail: z.object({ code: sixDigits }),
  googleLogin: z.object({ idToken: z.string().min(20).max(4096) }),
  deleteAccount: z.object({
    password: z.string().max(128).optional(),
    confirm: z.string().max(20).optional(),
  }),

  createPost: z.object({
    title: trimmed(120, 3),
    description: trimmed(2000, 10),
    category: z.enum(CATEGORIES),
    isLost: z.boolean(),
    reward: z.union([z.string().trim().max(40), z.number()]).nullable().optional(),
    location: trimmed(200, 1),
    imageUrl: httpUrl(500).optional(),
    lostOn: z.string().trim().max(40).nullable().optional(),
    latitude: z.number().min(-90).max(90).nullable().optional(),
    longitude: z.number().min(-180).max(180).nullable().optional(),
  }),
  updatePost: z.object({
    title: trimmed(120, 3).optional(),
    description: trimmed(2000, 10).optional(),
    category: z.enum(CATEGORIES).optional(),
    isLost: z.boolean().optional(),
    reward: z.union([z.string().trim().max(40), z.number()]).nullable().optional(),
    location: trimmed(200, 1).optional(),
    imageUrl: httpUrl(500).optional(),
    lostOn: z.string().trim().max(40).nullable().optional(),
    latitude: z.number().min(-90).max(90).nullable().optional(),
    longitude: z.number().min(-180).max(180).nullable().optional(),
    status: z.enum(['active', 'resolved']).optional(),
  }),
  reportPost: z.object({ reason: optionalTrimmed(300) }),

  initiateChat: z.object({
    peerId: id,
    postId: z.string().trim().max(200).optional(),
    itemName: optionalTrimmed(120),
  }),
  sendMessage: z.object({
    text: optionalTrimmed(2000),
    imageUrl: httpUrl(500).optional(),
  }).refine(v => (v.text && v.text.length > 0) || (v.imageUrl && v.imageUrl.length > 0), {
    message: 'Message cannot be empty.',
  }),

  updateProfile: z.object({
    fullName: optionalTrimmed(80),
    nickName: optionalTrimmed(40),
    phone: optionalTrimmed(30),
    address: optionalTrimmed(120),
    job: optionalTrimmed(80),
    avatarUrl: httpUrl(500).optional(),
  }),
  privacy: z.object({
    showProfile: optionalBool,
    allowMessages: optionalBool,
    showLocation: optionalBool,
    hidePhone: optionalBool,
  }),
  notificationSettings: z.object({
    messages: optionalBool,
    matches: optionalBool,
    updates: optionalBool,
    marketing: optionalBool,
    email: optionalBool,
  }),
  verification: z.object({
    docType: z.enum(['passport', 'id_card', 'drivers_license']),
    // Either a private file id returned by POST /profile/verification/upload
    // or (legacy) an https URL.
    frontUrl: verificationRef.refine(v => v.length > 0, 'frontUrl is required'),
    backUrl: verificationRef.optional(),
    selfieUrl: verificationRef.refine(v => v.length > 0, 'selfieUrl is required'),
  }),
  verificationUpload: z.object({ slot: z.enum(['front', 'back', 'selfie']) }),
  rejectVerification: z.object({ reason: trimmed(300, 3) }),
  pushToken: z.object({
    token: trimmed(4096, 20),
    platform: z.enum(['android', 'ios', 'web']).default('android'),
  }),
  removePushToken: z.object({ token: trimmed(4096, 20) }),
  blockUser: z.object({ blockedUserId: id }),
  savePost: z.object({ postId: id }),

  searchQuery: z.object({ q: z.string().trim().max(60).default('') }),
};

function firstIssue(error) {
  const issue = error.issues && error.issues[0];
  if (!issue) return 'Invalid request.';
  const path = issue.path && issue.path.length ? `${issue.path.join('.')}: ` : '';
  return `${path}${issue.message}`;
}

/** Validates `req.body` (or `req.query` with source='query') and replaces it with the parsed value. */
function validate(schema, source = 'body') {
  return (req, res, next) => {
    const result = schema.safeParse(req[source] || {});
    if (!result.success) {
      return res.status(400).json({ message: firstIssue(result.error) });
    }
    if (source === 'query') req.validatedQuery = result.data;
    else req.body = result.data;
    next();
  };
}

module.exports = { schemas, validate, CATEGORIES };
