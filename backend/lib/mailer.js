// Outgoing e-mail. Prefers Resend's HTTPS API (works on hosts that block
// outbound SMTP, such as Railway's trial/hobby plans) and falls back to plain
// SMTP through nodemailer for any other provider.
//
// Configuration (any one of these enables e-mail):
//   RESEND_API_KEY=re_…                       → HTTPS API
//   SMTP_HOST=smtp.resend.com + SMTP_PASS=re_… → HTTPS API (key taken from SMTP_PASS)
//   SMTP_HOST/SMTP_USER/SMTP_PASS (other host)  → SMTP
const FROM_DEFAULT = 'Finder <onboarding@resend.dev>';

function resendKey() {
  if (process.env.RESEND_API_KEY) return process.env.RESEND_API_KEY;
  const host = (process.env.SMTP_HOST || '').toLowerCase();
  const pass = process.env.SMTP_PASS || '';
  if (host.includes('resend.com') && pass.startsWith('re_')) return pass;
  return '';
}

function smtpConfigured() {
  return !!(process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS);
}

/** True when the server can deliver e-mail at all. */
function mailConfigured() {
  return !!resendKey() || smtpConfigured();
}

function fromAddress() {
  if (process.env.SMTP_FROM) return process.env.SMTP_FROM;
  const user = process.env.SMTP_USER || '';
  return user.includes('@') ? `Finder <${user}>` : FROM_DEFAULT;
}

async function sendViaResend(key, { to, subject, text, html }) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 15000);
  try {
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ from: fromAddress(), to: [to], subject, text, html }),
      signal: controller.signal,
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) {
      throw new Error(body.message || body.error || `Resend API responded ${res.status}`);
    }
    return { transport: 'resend-api', id: body.id };
  } finally {
    clearTimeout(timer);
  }
}

async function sendViaSmtp({ to, subject, text, html }) {
  const nodemailer = require('nodemailer');
  const port = parseInt(process.env.SMTP_PORT, 10) || 587;
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port,
    secure: port === 465,
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
    connectionTimeout: 15000,
    greetingTimeout: 15000,
    socketTimeout: 20000,
  });
  const info = await transporter.sendMail({ from: fromAddress(), to, subject, text, html });
  return { transport: 'smtp', id: info.messageId };
}

/**
 * Sends one e-mail. Resolves with {transport, id}; rejects with a descriptive
 * Error. Callers decide whether to await it or fire-and-forget with logging.
 */
async function sendMail(message) {
  const key = resendKey();
  if (key) return sendViaResend(key, message);
  if (smtpConfigured()) return sendViaSmtp(message);
  throw new Error('E-mail is not configured (set RESEND_API_KEY or SMTP_* variables).');
}

/** Fire-and-forget with a log line either way. */
function sendMailInBackground(kind, message) {
  sendMail(message)
    .then(r => console.log(`[MAIL] ${kind} sent to ${message.to} via ${r.transport}${r.id ? ` (${r.id})` : ''}`))
    .catch(err => console.error(`[MAIL] ${kind} to ${message.to} failed: ${err.message}`));
}

function codeEmail({ title, intro, code, footer, color }) {
  return {
    text: `${title}\n\n${intro}\n\nCode: ${code}\n\n${footer}`,
    html: `
      <div style="font-family: Arial, sans-serif; padding: 24px; color: #17201F; max-width: 480px;">
        <h2 style="margin: 0 0 12px; color: #0B6E6A;">${title}</h2>
        <p>${intro}</p>
        <p style="background: #F1F5F4; padding: 12px 20px; display: inline-block; font-size: 28px; letter-spacing: 6px; color: ${color}; border-radius: 8px; font-weight: bold;">${code}</p>
        <p style="color: #5E6866; font-size: 13px;">${footer}</p>
      </div>`,
  };
}

module.exports = { mailConfigured, smtpConfigured, sendMail, sendMailInBackground, codeEmail, fromAddress };
