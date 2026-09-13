/// In-app copies of the legal documents. The hosted versions live in
/// `backend/public/legal/` and are linked from the store listings; keep the
/// two in step when either changes.
class LegalSection {
  final String heading;
  final String body;
  const LegalSection(this.heading, this.body);
}

class LegalDocument {
  final String title;
  final String updated;
  final String intro;
  final List<LegalSection> sections;
  const LegalDocument({
    required this.title,
    required this.updated,
    required this.intro,
    required this.sections,
  });
}

const privacyPolicy = LegalDocument(
  title: 'Privacy Policy',
  updated: 'Last updated 13 September 2026',
  intro:
      'Finder helps people report lost and found items and get in touch with each other. This policy explains what data the app collects, why, and what control you have over it.',
  sections: [
    LegalSection('1. Data we collect',
        'Account data: e-mail, password (stored as a salted hash), name, nickname and optionally phone, city and occupation.\n\nPosts: title, description, category, location text, date and photos you attach.\n\nMessages: the text and photos you exchange with other members.\n\nIdentity verification (optional): photos of an identity document and a selfie, used only to grant the verified badge.\n\nTechnical data: request logs (IP address, endpoint, time) kept for security.\n\nGoogle sign-in: we receive your e-mail, name and profile picture from Google.'),
    LegalSection('2. How we use it',
        'To run the service: show posts, deliver messages and notifications, and let members contact each other. To keep the community safe: reports, blocks and identity verification. To send transactional e-mails such as verification codes and password resets. Product news is only sent if you opt in.\n\nWe do not sell personal data and we do not show third-party advertising.'),
    LegalSection('3. What other members can see',
        'Your name, photo and posts are visible to signed-in members. Your phone number is hidden unless you turn on sharing in Privacy & safety. Your e-mail address is never shown to other members. Members you block cannot see your posts or message you.'),
    LegalSection('4. Where data is stored',
        'Data is stored on our hosting provider\'s servers and photos on Cloudinary, both under their own data-processing terms. Data is transmitted over HTTPS.'),
    LegalSection('5. How long we keep it',
        'Account data is kept while your account exists. Verification documents are deleted once a decision has been made, and no later than 90 days after upload. Request logs are kept for 30 days.'),
    LegalSection('6. Your rights',
        'Access and correction: edit your profile in the app at any time.\n\nDeletion: delete your account from Privacy & safety → Delete account. Your posts, conversations, settings and profile are removed immediately; backups expire within 30 days.\n\nPortability and questions: write to privacy@finder.app.'),
    LegalSection('7. Children',
        'Finder is not intended for children under 16. We remove accounts we learn belong to children.'),
    LegalSection('8. Changes',
        'We will announce material changes in the app before they take effect. The date at the top shows when this policy was last revised.'),
  ],
);

const termsOfService = LegalDocument(
  title: 'Terms of Service',
  updated: 'Last updated 13 September 2026',
  intro:
      'By creating an account or using Finder you agree to these terms. If you do not agree, do not use the service.',
  sections: [
    LegalSection('1. The service',
        'Finder is a community notice board for lost and found items. We provide the place to post and talk; we do not take part in hand-overs, do not verify that an item belongs to a member, and are not a party to any reward arrangement between members.'),
    LegalSection('2. Your account',
        'You must be at least 16 years old. Keep your password private; you are responsible for activity on your account. One person, one account. Do not impersonate others.'),
    LegalSection('3. Your content',
        'You keep ownership of what you post. You give Finder a licence to store, display and distribute it inside the service so that other members can see it. Only post photos and information you have the right to share.'),
    LegalSection('4. Rules of conduct',
        'You must not: post false reports or claim an item that is not yours; ask for payment before returning an item or use the service for scams; harass, threaten or discriminate against other members; post illegal content or content that infringes someone else\'s rights; scrape the service, probe the API or interfere with its operation.\n\nWe may remove content, suspend or delete accounts that break these rules, and cooperate with law enforcement where required.'),
    LegalSection('5. Safety',
        'Meet in public places, bring someone with you, and never pay a reward before you have your item. Use in-app chat so you can block and report. Finder cannot guarantee the honesty of any member.'),
    LegalSection('6. Identity verification',
        'The verified badge means a member submitted an identity document that our team reviewed. It is not a guarantee of identity or good faith.'),
    LegalSection('7. Availability and changes',
        'We may change or discontinue features at any time. We try to keep the service available but do not promise uninterrupted operation.'),
    LegalSection('8. Liability',
        'To the extent permitted by law, Finder is provided "as is" and we are not liable for losses arising from your use of the service, from other members\' conduct, or from items that are not recovered.'),
    LegalSection('9. Termination',
        'You can delete your account at any time from Privacy & safety. We can terminate accounts that violate these terms.'),
    LegalSection('10. Contact',
        'Questions about these terms: support@finder.app'),
  ],
);
