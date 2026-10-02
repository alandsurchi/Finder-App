// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Finder';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonDiscard => 'Discard';

  @override
  String get commonDone => 'Done';

  @override
  String get commonOk => 'OK';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonShare => 'Share';

  @override
  String get commonReport => 'Report';

  @override
  String get commonBlock => 'Block';

  @override
  String get commonUnblock => 'Unblock';

  @override
  String get commonSend => 'Send';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get commonSending => 'Sending…';

  @override
  String get commonUploading => 'Uploading…';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonViewProfile => 'View profile';

  @override
  String get commonMoreOptions => 'More options';

  @override
  String get commonLogOut => 'Log out';

  @override
  String get commonLost => 'Lost';

  @override
  String get commonFound => 'Found';

  @override
  String get commonReturned => 'Returned';

  @override
  String get commonMarkAsReturned => 'Mark as returned';

  @override
  String get commonMarkedAsReturned => 'Marked as returned.';

  @override
  String get commonReopen => 'Reopen';

  @override
  String get commonPosts => 'Posts';

  @override
  String get commonMessages => 'Messages';

  @override
  String get commonNotifications => 'Notifications';

  @override
  String get commonProfile => 'Profile';

  @override
  String get commonHome => 'Home';

  @override
  String get commonLocation => 'Location';

  @override
  String get commonLocationNotSpecified => 'Location not specified';

  @override
  String get commonFinderUser => 'Finder User';

  @override
  String get commonYou => 'You';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String commonUploadFailed(String detail) {
    return 'Upload failed. $detail';
  }

  @override
  String get commonCopied => 'Copied.';

  @override
  String get commonJustNow => 'Just now';

  @override
  String commonMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String commonHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String commonDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String commonWeeksAgo(int count) {
    return '${count}w ago';
  }

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String commonMonthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'Jan',
      '2': 'Feb',
      '3': 'Mar',
      '4': 'Apr',
      '5': 'May',
      '6': 'Jun',
      '7': 'Jul',
      '8': 'Aug',
      '9': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Dec',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String commonWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'Mon',
      '2': 'Tue',
      '3': 'Wed',
      '4': 'Thu',
      '5': 'Fri',
      '6': 'Sat',
      '7': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String commonDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String commonDayMonthYear(int day, String month, int year) {
    return '$day $month $year';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the language Finder uses';

  @override
  String get languageSystem => 'Use phone language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageKurdish => 'کوردی';

  @override
  String get languageChanged => 'Language updated.';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Log in to continue finding what matters.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Your password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authOrContinueWith => 'Or continue with';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authNoAccountPrompt => 'Don\'t have an account?';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authInvalidEmail => 'Enter a valid email address.';

  @override
  String get authPasswordMin6 => 'Password must be at least 6 characters.';

  @override
  String get authSignupTitle => 'Create your account';

  @override
  String get authSignupSubtitle =>
      'Report and track lost & found items with the community.';

  @override
  String get authEmailAddressLabel => 'Email address';

  @override
  String get authEmailAddressHint => 'yourname@example.com';

  @override
  String get authNameLabel => 'Your name';

  @override
  String get authNameHint => 'How should we call you?';

  @override
  String get authPhoneLabel => 'Phone number';

  @override
  String get authPhoneHint => '+1 234 567 8900';

  @override
  String get authSignupPasswordHint => 'At least 8 characters';

  @override
  String get authPasswordRule =>
      'Use at least 8 characters with a letter and a number.';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authOrSignUpWith => 'Or sign up with';

  @override
  String get authSignUpWithGoogle => 'Sign up with Google';

  @override
  String get authHaveAccountPrompt => 'Already have an account?';

  @override
  String get authLogIn => 'Log in';

  @override
  String get authForgotInvalidEmail => 'Please enter a valid email address';

  @override
  String get authForgotCodeSent =>
      'Verification code sent! Check your inbox or console logs.';

  @override
  String get authForgotCodeResent =>
      'New verification code sent! Check your inbox or console logs.';

  @override
  String get authForgotEnterNumericCode =>
      'Please enter the 6-digit numeric verification code';

  @override
  String get authForgotCodeVerified => 'Code verified successfully!';

  @override
  String get authForgotPasswordsMismatch => 'Passwords do not match';

  @override
  String get authForgotPasswordUpdated =>
      'Password updated successfully! Please log in.';

  @override
  String get authForgotTitle => 'Forgot password';

  @override
  String get authForgotSubtitle =>
      'Enter your email address and we will send you a 6-digit verification code.';

  @override
  String get authForgotCheckInboxTitle => 'Check your inbox';

  @override
  String authForgotCheckInboxSubtitle(String email) {
    return 'Enter the 6-digit verification code sent to $email.';
  }

  @override
  String get authForgotNewPasswordTitle => 'Set a new password';

  @override
  String get authForgotNewPasswordSubtitle =>
      'Create a secure new password for your account.';

  @override
  String get authForgotSendCode => 'Send verification code';

  @override
  String get authForgotCancelAndLogIn => 'Cancel and log in';

  @override
  String get authVerificationCodeLabel => 'Verification code';

  @override
  String get authVerificationCodeHint => '6-digit code';

  @override
  String get authVerifyCode => 'Verify code';

  @override
  String get authChangeEmail => 'Change email';

  @override
  String get authResendCode => 'Resend code';

  @override
  String get authNewPasswordLabel => 'New password';

  @override
  String get authNewPasswordHint => 'Min. 6 characters';

  @override
  String get authConfirmPasswordLabel => 'Confirm new password';

  @override
  String get authConfirmPasswordHint => 'Retype new password';

  @override
  String get authResetPassword => 'Reset password';

  @override
  String get authStartOver => 'Start over / change email';

  @override
  String get authVerifyEnterCode =>
      'Please enter the 6-digit verification code.';

  @override
  String get authVerifiedWelcome => 'Account verified. Welcome to Finder!';

  @override
  String get authVerifyCodeResent =>
      'A new verification code has been sent to your email.';

  @override
  String get authVerifyTitle => 'Verify your email';

  @override
  String get authVerifySubtitle =>
      'We sent a 6-digit verification code to your registered email address. Enter it below to activate your account.';

  @override
  String get authVerifyAccount => 'Verify account';

  @override
  String get authGoogleCancelled => 'Google sign-in was cancelled by the user.';

  @override
  String get authGoogleTokenFailed => 'Failed to retrieve Google ID token.';

  @override
  String get authSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get authSocialSemantic => 'Continue with social account';

  @override
  String get authLegalAgreePrefix => 'By creating an account you agree to the ';

  @override
  String get authLegalAgreeAnd => ' and the ';

  @override
  String get authLegalAgreeSuffix => '.';

  @override
  String get onboardLostTitle => 'Lost something? Post it in a minute';

  @override
  String get onboardLostDescription =>
      'Add a photo, where and when you lost it. Finder shows it to people nearby and alerts you the moment something matches.';

  @override
  String get onboardFoundTitle => 'Found something? Help it get home';

  @override
  String get onboardFoundDescription =>
      'Post what you found. A person reviews every post, and the app matches it with people searching, in their own language.';

  @override
  String get onboardConnectTitle => 'Chat, verify, hand it back safely';

  @override
  String get onboardConnectDescription =>
      'Message inside the app, ask for a detail only the owner knows, and meet in a public place. Help & Support walks you through every step.';

  @override
  String get onboardGetStarted => 'Get started';

  @override
  String get legalOpenWebVersion => 'Open web version';

  @override
  String legalCouldNotOpen(String url) {
    return 'Could not open $url';
  }

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalUpdated => 'Last updated 13 September 2026';

  @override
  String get legalPrivacyIntro =>
      'Finder helps people report lost and found items and get in touch with each other. This policy explains what data the app collects, why, and what control you have over it.';

  @override
  String get legalPrivacy1Heading => '1. Data we collect';

  @override
  String get legalPrivacy1Body1 =>
      'Account data: e-mail, password (stored as a salted hash), name, nickname and optionally phone, city and occupation.';

  @override
  String get legalPrivacy1Body2 =>
      'Posts: title, description, category, location text, date and photos you attach.';

  @override
  String get legalPrivacy1Body3 =>
      'Messages: the text and photos you exchange with other members.';

  @override
  String get legalPrivacy1Body4 =>
      'Identity verification (optional): photos of an identity document and a selfie, used only to grant the verified badge.';

  @override
  String get legalPrivacy1Body5 =>
      'Technical data: request logs (IP address, endpoint, time) kept for security, plus anonymous crash reports and usage statistics (which screens are used, never the content of posts or messages).';

  @override
  String get legalPrivacy1Body6 =>
      'Google sign-in: we receive your e-mail, name and profile picture from Google.';

  @override
  String get legalPrivacy2Heading => '2. How we use it';

  @override
  String get legalPrivacy2Body1 =>
      'To run the service: show posts, deliver messages and notifications, and let members contact each other. To keep the community safe: reports, blocks and identity verification. To send transactional e-mails such as verification codes and password resets. Product news is only sent if you opt in.';

  @override
  String get legalPrivacy2Body2 =>
      'We do not sell personal data and we do not show third-party advertising.';

  @override
  String get legalPrivacy3Heading => '3. What other members can see';

  @override
  String get legalPrivacy3Body =>
      'Your name, photo and posts are visible to signed-in members. Your phone number is hidden unless you turn on sharing in Privacy & safety. Your e-mail address is never shown to other members. Members you block cannot see your posts or message you.';

  @override
  String get legalPrivacy4Heading => '4. Where data is stored';

  @override
  String get legalPrivacy4Body =>
      'Data is stored on our hosting provider\'s servers and photos on Cloudinary, both under their own data-processing terms. Data is transmitted over HTTPS.';

  @override
  String get legalPrivacy5Heading => '5. How long we keep it';

  @override
  String get legalPrivacy5Body =>
      'Account data is kept while your account exists. Verification documents are deleted once a decision has been made, and no later than 90 days after upload. Request logs are kept for 30 days.';

  @override
  String get legalPrivacy6Heading => '6. Your rights';

  @override
  String get legalPrivacy6Body1 =>
      'Access and correction: edit your profile in the app at any time.';

  @override
  String get legalPrivacy6Body2 =>
      'Deletion: delete your account from Privacy & safety → Delete account. Your posts, conversations, settings and profile are removed immediately; backups expire within 30 days.';

  @override
  String get legalPrivacy6Body3 =>
      'Portability and questions: write to privacy@finder.app.';

  @override
  String get legalPrivacy7Heading => '7. Children';

  @override
  String get legalPrivacy7Body =>
      'Finder is not intended for children under 16. We remove accounts we learn belong to children.';

  @override
  String get legalPrivacy8Heading => '8. Changes';

  @override
  String get legalPrivacy8Body =>
      'We will announce material changes in the app before they take effect. The date at the top shows when this policy was last revised.';

  @override
  String get legalTermsIntro =>
      'By creating an account or using Finder you agree to these terms. If you do not agree, do not use the service.';

  @override
  String get legalTerms1Heading => '1. The service';

  @override
  String get legalTerms1Body =>
      'Finder is a community notice board for lost and found items. We provide the place to post and talk; we do not take part in hand-overs, do not verify that an item belongs to a member, and are not a party to any reward arrangement between members.';

  @override
  String get legalTerms2Heading => '2. Your account';

  @override
  String get legalTerms2Body =>
      'You must be at least 16 years old. Keep your password private; you are responsible for activity on your account. One person, one account. Do not impersonate others.';

  @override
  String get legalTerms3Heading => '3. Your content';

  @override
  String get legalTerms3Body =>
      'You keep ownership of what you post. You give Finder a licence to store, display and distribute it inside the service so that other members can see it. Only post photos and information you have the right to share.';

  @override
  String get legalTerms4Heading => '4. Rules of conduct';

  @override
  String get legalTerms4Body1 =>
      'You must not: post false reports or claim an item that is not yours; ask for payment before returning an item or use the service for scams; harass, threaten or discriminate against other members; post illegal content or content that infringes someone else\'s rights; scrape the service, probe the API or interfere with its operation.';

  @override
  String get legalTerms4Body2 =>
      'We may remove content, suspend or delete accounts that break these rules, and cooperate with law enforcement where required.';

  @override
  String get legalTerms5Heading => '5. Safety';

  @override
  String get legalTerms5Body =>
      'Meet in public places, bring someone with you, and never pay a reward before you have your item. Use in-app chat so you can block and report. Finder cannot guarantee the honesty of any member.';

  @override
  String get legalTerms6Heading => '6. Identity verification';

  @override
  String get legalTerms6Body =>
      'The verified badge means a member submitted an identity document that our team reviewed. It is not a guarantee of identity or good faith.';

  @override
  String get legalTerms7Heading => '7. Availability and changes';

  @override
  String get legalTerms7Body =>
      'We may change or discontinue features at any time. We try to keep the service available but do not promise uninterrupted operation.';

  @override
  String get legalTerms8Heading => '8. Liability';

  @override
  String get legalTerms8Body =>
      'To the extent permitted by law, Finder is provided \"as is\" and we are not liable for losses arising from your use of the service, from other members\' conduct, or from items that are not recovered.';

  @override
  String get legalTerms9Heading => '9. Termination';

  @override
  String get legalTerms9Body =>
      'You can delete your account at any time from Privacy & safety. We can terminate accounts that violate these terms.';

  @override
  String get legalTerms10Heading => '10. Contact';

  @override
  String get legalTerms10Body =>
      'Questions about these terms: support@finder.app';

  @override
  String get adminConsoleTitle => 'Admin console';

  @override
  String get adminConsoleSubtitle => 'Users, posts, reports and verification';

  @override
  String get adminModeration => 'Moderation';

  @override
  String get adminUsersTitle => 'Users';

  @override
  String get adminUsersTileSubtitle =>
      'Search, verify, suspend, promote or delete accounts';

  @override
  String get adminPostsTileSubtitle =>
      'Every lost and found post, open or returned';

  @override
  String get adminReportsTitle => 'Reports';

  @override
  String get adminReportsSubtitle => 'Posts flagged by members';

  @override
  String get adminVerificationTitle => 'Identity verification';

  @override
  String get adminVerificationTileSubtitle => 'Review documents and selfies';

  @override
  String get adminStatMembers => 'Members';

  @override
  String get adminVerifiedLabel => 'Verified';

  @override
  String get adminStatOpenPosts => 'Open posts';

  @override
  String get adminStatToVerify => 'To verify';

  @override
  String get adminSuspendedLabel => 'Suspended';

  @override
  String get adminStatMessages24h => 'Messages 24h';

  @override
  String get adminPostsSubtitle => 'Everything on the feed';

  @override
  String get adminPostsSearchHint => 'Title, description, owner';

  @override
  String get adminFilterAll => 'All';

  @override
  String get adminFilterOpen => 'Open';

  @override
  String get adminFilterReported => 'Reported';

  @override
  String get adminFilterHandled => 'Handled';

  @override
  String get adminFilterAdmins => 'Admins';

  @override
  String get adminFilterPending => 'Pending';

  @override
  String get adminFilterApproved => 'Approved';

  @override
  String get adminFilterRejected => 'Rejected';

  @override
  String get adminNoPostsHere => 'No posts here';

  @override
  String adminPostSheetSubtitle(String owner, String status) {
    return 'by $owner · $status';
  }

  @override
  String get adminStatusReturned => 'returned';

  @override
  String get adminStatusOpen => 'open';

  @override
  String get adminOpenThePost => 'Open the post';

  @override
  String get adminReopenThePost => 'Reopen the post';

  @override
  String get adminPostReopened => 'Post reopened.';

  @override
  String get adminRemoveThePost => 'Remove the post';

  @override
  String get adminRemovePostOwnerNotified =>
      'The owner is notified with your reason';

  @override
  String get adminPostRemoved => 'Post removed.';

  @override
  String get adminRemovePostTitle => 'Remove this post?';

  @override
  String get adminRemovePostReasonSubtitle =>
      'A short reason is sent to the owner.';

  @override
  String get adminReasonOptionalLabel => 'Reason (optional)';

  @override
  String get adminReasonPostHint => 'e.g. Not a lost or found item';

  @override
  String get adminNoOpenReports => 'No open reports';

  @override
  String get adminNothingHandledYet => 'Nothing handled yet';

  @override
  String get adminBadgeOpen => 'OPEN';

  @override
  String get adminBadgeHandled => 'HANDLED';

  @override
  String get adminNoReasonGiven => 'No reason given';

  @override
  String adminQuotedReason(String reason) {
    return '\"$reason\"';
  }

  @override
  String adminReportedBy(String name, String time) {
    return 'Reported by $name · $time';
  }

  @override
  String adminPostBySuffix(String name) {
    return ' · post by $name';
  }

  @override
  String get adminDismissReport => 'Dismiss the report';

  @override
  String get adminPostStaysUp => 'The post stays up';

  @override
  String get adminRemovePostSettles =>
      'Settles every report on it; the owner is notified';

  @override
  String adminRemovePostConfirmBody(String title) {
    return '\"$title\" and its chats are deleted. This cannot be undone.';
  }

  @override
  String get adminReportDismissed => 'Report dismissed.';

  @override
  String get adminUsersSubtitle => 'Accounts on Finder';

  @override
  String get adminUsersSearchHint => 'Name, nickname or e-mail';

  @override
  String get adminNoAccountsMatch => 'No accounts match';

  @override
  String get adminRemoveVerifiedBadge => 'Remove verified badge';

  @override
  String get adminMarkAsVerified => 'Mark as verified';

  @override
  String get adminRemoveBadgeSubtitle =>
      'The tick disappears from their profile and posts';

  @override
  String get adminGrantBadgeSubtitle =>
      'Grants the tick without a document review';

  @override
  String get adminVerifiedBadgeRemoved => 'Verified badge removed.';

  @override
  String get adminMarkedAsVerified => 'Marked as verified.';

  @override
  String get adminRemoveAdminRole => 'Remove admin role';

  @override
  String get adminMakeAdministrator => 'Make administrator';

  @override
  String get adminLoseConsoleAccess => 'They lose access to this console';

  @override
  String get adminFullAccess => 'Full access to users, posts and reports';

  @override
  String get adminRemoveAdminRoleTitle => 'Remove admin role?';

  @override
  String adminMakeAdminTitle(String name) {
    return 'Make $name an administrator?';
  }

  @override
  String adminRemoveAdminBody(String name) {
    return '$name will no longer be able to moderate Finder.';
  }

  @override
  String get adminMakeAdminBody =>
      'Administrators can suspend or delete any account and remove any post.';

  @override
  String get adminRemoveRole => 'Remove role';

  @override
  String get adminMakeAdmin => 'Make admin';

  @override
  String get adminRoleRemoved => 'Admin role removed.';

  @override
  String adminNowAdmin(String name) {
    return '$name is now an admin.';
  }

  @override
  String get adminLiftSuspension => 'Lift suspension';

  @override
  String get adminSuspendAccount => 'Suspend account';

  @override
  String get adminCanSignInAgain => 'They can sign in again';

  @override
  String get adminSignedOutCannotSignIn =>
      'They are signed out and cannot sign in';

  @override
  String get adminLiftSuspensionTitle => 'Lift the suspension?';

  @override
  String adminSuspendTitle(String name) {
    return 'Suspend $name?';
  }

  @override
  String get adminLiftBody => 'The account works normally again.';

  @override
  String get adminSuspendBody =>
      'Their posts stay visible. They lose access until you lift the suspension.';

  @override
  String get adminLift => 'Lift';

  @override
  String get adminSuspend => 'Suspend';

  @override
  String get adminSuspensionLifted => 'Suspension lifted.';

  @override
  String get adminAccountSuspended => 'Account suspended.';

  @override
  String get adminDeleteAccount => 'Delete account';

  @override
  String get adminDeleteAccountSubtitle =>
      'Removes the account, its posts and chats. Cannot be undone.';

  @override
  String adminDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get adminDeleteBody =>
      'Everything they posted and every chat they were in is erased permanently.';

  @override
  String get adminAccountDeleted => 'Account deleted.';

  @override
  String adminYouSuffix(String name) {
    return '$name (you)';
  }

  @override
  String adminPostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
    );
    return '$_temp0';
  }

  @override
  String adminReportsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reports',
      one: '1 report',
    );
    return '$_temp0';
  }

  @override
  String adminJoined(String time) {
    return 'joined $time';
  }

  @override
  String get adminBadgeSuspended => 'SUSPENDED';

  @override
  String get adminQueueTitle => 'Review queue';

  @override
  String get adminQueueSubtitle => 'Identity verification requests';

  @override
  String get adminNothingToReview => 'Nothing to review';

  @override
  String get adminNoRequestsHere => 'No requests here';

  @override
  String get adminNewRequestsShowHere =>
      'New verification requests will show up here.';

  @override
  String get adminBadgeRejected => 'REJECTED';

  @override
  String get adminBadgePending => 'PENDING';

  @override
  String get adminDocIdCard => 'Identity card';

  @override
  String get adminDocDriversLicense => 'Driver\'s license';

  @override
  String get adminDocPassport => 'Passport';

  @override
  String get adminDocDocument => 'Document';

  @override
  String adminSubmitted(String doc, String time) {
    return '$doc · submitted $time';
  }

  @override
  String adminReviewedStatus(String status, String time) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'approved': 'approved $time',
      'rejected': 'rejected $time',
      'other': '$status $time',
    });
    return '$_temp0';
  }

  @override
  String adminReasonPrefix(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get adminDocumentSection => 'Document';

  @override
  String get adminStep1 => 'Step 1';

  @override
  String get adminLiveSelfie => 'Live selfie';

  @override
  String get adminStep2 => 'Step 2';

  @override
  String get adminFrontOfId => 'Front of ID';

  @override
  String get adminPhotoPage => 'Photo page';

  @override
  String get adminBackOfId => 'Back of ID';

  @override
  String get adminSelfieCaption => 'Selfie taken with the front camera';

  @override
  String get adminReviewGuidance =>
      'Compare the face on the document with the selfie, check the name matches the account, and that the document is not expired or edited.';

  @override
  String adminTapToZoom(String caption) {
    return '$caption · tap to zoom';
  }

  @override
  String get adminReject => 'Reject';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminApproveTitle => 'Approve this identity?';

  @override
  String adminApproveBody(String name) {
    return '$name gets the verified badge and a notification.';
  }

  @override
  String get adminIdentityApproved => 'Identity approved.';

  @override
  String get adminRejectRequestTitle => 'Reject request';

  @override
  String adminRejectReasonSubtitle(String name) {
    return 'The reason is sent to $name so they can fix it.';
  }

  @override
  String get adminReasonLabel => 'Reason';

  @override
  String get adminRejectReasonHint =>
      'e.g. The selfie is too dark to compare with the document.';

  @override
  String get adminRequestRejected => 'Request rejected.';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateLoading => 'Loading';

  @override
  String get uiShowPassword => 'Show password';

  @override
  String get uiHidePassword => 'Hide password';

  @override
  String get uiCouldNotLoad => 'Could not load';

  @override
  String get adminStatToApprove => 'To approve';

  @override
  String get adminStatRejected => 'Rejected';

  @override
  String adminFilterPendingCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String get adminNothingToApprove => 'Nothing to approve';

  @override
  String get adminNothingToApproveBody =>
      'New posts show up here before anyone else can see them.';

  @override
  String get adminReviewTitle => 'Review this post';

  @override
  String adminRiskLabel(int score) {
    return 'AI risk $score';
  }

  @override
  String get adminRiskUnavailable => 'AI check unavailable';

  @override
  String get adminRiskLow => 'Looks fine';

  @override
  String get adminRiskMedium => 'Check carefully';

  @override
  String get adminRiskHigh => 'Likely reject';

  @override
  String adminOriginalText(String lang) {
    return 'Original ($lang)';
  }

  @override
  String get adminRejectPostTitle => 'Reject this post?';

  @override
  String get adminRejectPostSubtitle =>
      'The reason is sent to the owner so they can fix it and resubmit.';

  @override
  String get adminRejectPostHint => 'e.g. The photo does not show the item.';

  @override
  String get adminPostApproved => 'Post approved. It is live now.';

  @override
  String get adminPostRejected => 'Post rejected. The owner has been told.';

  @override
  String get adminStatusPending => 'pending';

  @override
  String get adminStatusRejected => 'rejected';

  @override
  String get adminStatusExpired => 'archived';

  @override
  String get adminAiTitle => 'AI assistant';

  @override
  String get adminAiSubtitle =>
      'Provider, model and key for translations and the pre-check';

  @override
  String get adminAiNotConfigured =>
      'Not configured. Posts are not translated or pre-checked.';

  @override
  String get adminAiKeyLabel => 'API key';

  @override
  String get adminAiKeyHint => 'Paste the key from the provider\'s dashboard';

  @override
  String get adminAiKeyBody =>
      'The key is verified once, stored encrypted on the server and never shown again. It works for every user right away. Each new post costs roughly one cent on the cheapest models.';

  @override
  String get adminAiProvider => 'Provider';

  @override
  String get adminAiModelLabel => 'Model';

  @override
  String get adminAiModelHint => 'Leave the default unless you know better';

  @override
  String get adminAiBaseUrlLabel => 'Base URL';

  @override
  String get adminAiBaseUrlHint => 'https://openrouter.ai/api/v1';

  @override
  String get adminAiKeyHintReplace =>
      'Paste a new key to replace the saved one';

  @override
  String get adminAiSourceDb => 'Saved from the app';

  @override
  String get adminAiSourceEnv => 'Set on the server';

  @override
  String get adminAiSourceNone => 'Not set';

  @override
  String adminAiBacklog(int translations, int scores) {
    return '$translations posts waiting for translation · $scores waiting for a risk score';
  }

  @override
  String adminAiSaved(int count) {
    return 'Key verified. Translating $count posts for everyone…';
  }

  @override
  String get adminAiRemove => 'Remove key';

  @override
  String get adminAiRemoveBody =>
      'New posts will stop being translated and pre-checked until a key is saved again.';

  @override
  String get adminAiRemoved => 'AI settings removed.';

  @override
  String get onboardStepReport => 'Step 1 · Report';

  @override
  String get onboardStepMatch => 'Step 2 · Match';

  @override
  String get onboardStepReturn => 'Step 3 · Return';

  @override
  String get onboardHaveAccount => 'I already have an account';

  @override
  String get onboardSampleLost => 'LOST';

  @override
  String get onboardSampleFound => 'FOUND';

  @override
  String get onboardSamplePlace => 'Erbil · Family Mall';

  @override
  String get onboardSampleMinute => 'Posted in 1 min';

  @override
  String get onboardSampleMatch => '92% match';

  @override
  String get onboardSampleReviewed => 'Reviewed';

  @override
  String get onboardSampleAsk => 'What\'s engraved on the back?';

  @override
  String get onboardSampleAnswer => 'My initials, A.S. 😊';

  @override
  String get onboardSampleVerified => 'Owner verified';

  @override
  String get onboardSampleMeet => 'Meet in public';

  @override
  String get adminFilterExpired => 'Archived';

  @override
  String get adminTakeDown => 'Reject & take down';

  @override
  String get adminTakeDownSubtitle =>
      'Hides it from everyone; the owner gets your reason';

  @override
  String get adminApproveAgain => 'Approve and publish';

  @override
  String get adminApproveAgainSubtitle => 'Makes the post live again';

  @override
  String get adminPostTakenDown => 'Post taken down.';

  @override
  String get chatConversationTitle => 'Conversation';

  @override
  String get chatNotFoundTitle => 'Conversation not found';

  @override
  String get chatNotFoundSubtitle =>
      'Open a chat from a post or from Messages.';

  @override
  String get chatLoadingMessages => 'Loading messages...';

  @override
  String chatSayHello(String name) {
    return 'Say hello to $name';
  }

  @override
  String get chatStartSubtitle =>
      'Start the conversation by sending a message.';

  @override
  String chatAskAbout(String item) {
    return 'Ask about \"$item\" or arrange a safe hand-over.';
  }

  @override
  String get chatDirectMessageViewProfile => 'Direct message · view profile';

  @override
  String get chatDirectMessage => 'Direct message';

  @override
  String chatAboutItem(String item) {
    return 'About \"$item\"';
  }

  @override
  String get chatReopenPost => 'Reopen the post';

  @override
  String get chatReopenSubtitle => 'Show it on Home again';

  @override
  String get chatReturnedSubtitle => 'The item is back with its owner';

  @override
  String get chatViewPost => 'View the post';

  @override
  String get chatReportPost => 'Report the post';

  @override
  String get chatPostReported => 'Thanks, the post has been reported.';

  @override
  String get chatReopenTitle => 'Reopen this post?';

  @override
  String get chatMarkReturnedTitle => 'Mark as returned?';

  @override
  String chatReopenBody(String item) {
    return '\"$item\" will show on Home again as an open post.';
  }

  @override
  String chatMarkReturnedBody(String item) {
    return '\"$item\" leaves the Home feed but stays visible in Search. Everyone in this chat gets a note.';
  }

  @override
  String get chatPostReopened => 'Post reopened.';

  @override
  String get chatAutoReopened => 'I reopened this post.';

  @override
  String get chatAutoReturned => 'I marked this item as returned. Thank you!';

  @override
  String get chatYourMessage => 'Your message';

  @override
  String get chatMessage => 'Message';

  @override
  String get chatReply => 'Reply';

  @override
  String get chatCopyText => 'Copy text';

  @override
  String get chatDeleteForEveryone => 'Delete for everyone';

  @override
  String get chatDeleteTitle => 'Delete this message?';

  @override
  String get chatDeleteBody =>
      'It is removed for everyone in this chat. This cannot be undone.';

  @override
  String get chatSendPhoto => 'Send a photo';

  @override
  String get chatWriteReplyHint => 'Write a reply…';

  @override
  String get chatTypeMessageHint => 'Type a message…';

  @override
  String get chatMicPermission =>
      'Allow microphone access to send voice messages.';

  @override
  String get chatSendMessage => 'Send message';

  @override
  String get chatNotSent => 'Not sent';

  @override
  String get chatYouSaid => 'You said';

  @override
  String get chatTheySaid => 'They said';

  @override
  String get chatCancelReply => 'Cancel reply';

  @override
  String chatNewCount(int count) {
    return '$count new';
  }

  @override
  String get chatLatest => 'Latest';

  @override
  String get chatSignInToMessage => 'Please sign in to send messages.';

  @override
  String get chatOwnPost => 'This is your own post.';

  @override
  String get chatOpenFailed => 'Could not open the conversation.';

  @override
  String get chatLoadFailed => 'Unable to load messages.';

  @override
  String get chatNotSentFailure => 'Message not sent.';

  @override
  String get chatNothingToRetry => 'Nothing to retry.';

  @override
  String get chatDeleteFailed => 'Could not delete the message.';

  @override
  String get msgDeleted => 'This message was deleted';

  @override
  String get msgVoiceMessage => 'Voice message';

  @override
  String get msgPhoto => 'Photo';

  @override
  String get msgNoMessagesYet => 'No messages yet';

  @override
  String get msgNewConversation => 'New conversation';

  @override
  String get msgNewChat => 'New chat';

  @override
  String msgUnreadConversations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread conversations',
      one: '1 unread conversation',
    );
    return '$_temp0';
  }

  @override
  String get msgSubtitle => 'Chat safely with owners and finders';

  @override
  String get msgSearchHint => 'Search conversations…';

  @override
  String get msgLoading => 'Loading conversations...';

  @override
  String get msgNoConversations => 'No conversations yet';

  @override
  String get msgNoConversationsFound => 'No conversations found';

  @override
  String get msgEmptySubtitle =>
      'Contact an owner or finder from any post, or start a new chat.';

  @override
  String get msgTryAnother => 'Try another name or keyword.';

  @override
  String notifUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String get notifCaughtUp => 'You are all caught up';

  @override
  String get notifMarkAllRead => 'Mark all read';

  @override
  String get notifLoading => 'Loading notifications...';

  @override
  String get notifEmptyTitle => 'No notifications yet';

  @override
  String get notifEmptySubtitle =>
      'You will hear from us when someone messages you, your post gets activity, or an item is resolved.';

  @override
  String get notifUnreadSemantics => 'Unread notification';

  @override
  String get notifLoadingPreferences => 'Loading preferences...';

  @override
  String get notifStayConnected => 'Stay connected';

  @override
  String get notifStayConnectedBody =>
      'Choose which moments create a notification. Changes are saved instantly.';

  @override
  String get notifAll => 'All notifications';

  @override
  String get notifAllMuted => 'Everything is muted';

  @override
  String get notifAllOff => 'Turn everything off at once';

  @override
  String get notifConversations => 'Conversations';

  @override
  String get notifNewMessage => 'New message';

  @override
  String get notifNewMessageSubtitle =>
      'When someone writes to you about a post';

  @override
  String get notifSmartMatching => 'Smart matching';

  @override
  String get notifItemMatch => 'Item match alerts';

  @override
  String get notifItemMatchSubtitle =>
      'When a new post looks like something you lost or found';

  @override
  String get notifSmartBadge => 'SMART';

  @override
  String get notifPostUpdates => 'Post updates';

  @override
  String get notifPostUpdatesSubtitle =>
      'When an item you chatted about is resolved';

  @override
  String get notifFromFinder => 'From Finder';

  @override
  String get notifTips => 'Tips and news';

  @override
  String get notifTipsSubtitle => 'Occasional product updates. Off by default.';

  @override
  String get notifEmailCopies => 'E-mail copies';

  @override
  String get notifEmailCopiesSubtitle =>
      'Also send important notifications by e-mail';

  @override
  String get notifFooter =>
      'Notifications are delivered inside the app. Push delivery to your phone will follow the same preferences.';

  @override
  String get privacyTitle => 'Privacy & safety';

  @override
  String get privacyBlockMemberTitle => 'Block a member';

  @override
  String get privacyAdminCannotBlock =>
      'Finder administrators cannot be blocked.';

  @override
  String get privacyDeleteAccountTitle => 'Delete your account?';

  @override
  String get privacyDeleteAccountBody =>
      'Your posts, conversations, saved items and profile are removed immediately. This cannot be undone.';

  @override
  String get privacyTypeDeleteLabel => 'Type DELETE to confirm';

  @override
  String get privacyPasswordLabel => 'Your password';

  @override
  String get privacyTypeDeleteHint => 'DELETE';

  @override
  String get privacyPasswordHint => 'Password';

  @override
  String get privacyDeleteAccount => 'Delete account';

  @override
  String get privacyTypeDeleteError => 'Type DELETE to confirm.';

  @override
  String get privacyEnterPassword => 'Please enter your password.';

  @override
  String get privacyAccountDeleted => 'Your account has been deleted.';

  @override
  String get privacyLoadingSettings => 'Loading settings...';

  @override
  String get privacyHeadline => 'Your data, your control';

  @override
  String get privacyIntro =>
      'Decide what other members can see and who can reach you. Changes apply immediately.';

  @override
  String get privacyVisibility => 'Visibility';

  @override
  String get privacyShowProfile => 'Show my profile';

  @override
  String get privacyShowProfileSubtitle =>
      'Off shows only your name and photo on posts; job, phone and location stay hidden.';

  @override
  String get privacyAllowMessages => 'Allow direct messages';

  @override
  String get privacyAllowMessagesSubtitle =>
      'Let members start a conversation with you. Existing chats stay open.';

  @override
  String get privacyShowCity => 'Show my city';

  @override
  String get privacyShowCitySubtitle =>
      'Shares the address from your profile with other members.';

  @override
  String get privacyHidePhone => 'Hide my phone number';

  @override
  String get privacyHidePhoneSubtitle =>
      'When on, members can only reach you through in-app chat.';

  @override
  String get privacyBlockedMembersLabel => 'BLOCKED MEMBERS';

  @override
  String get privacyBlockedMembers => 'Blocked members';

  @override
  String get privacyBlockedMembersBody =>
      'Blocked members can\'t see your posts or message you, and you won\'t see theirs.';

  @override
  String privacyBlockedTotal(int count) {
    return '$count total';
  }

  @override
  String get privacyLoadingBlocked => 'Loading blocked members...';

  @override
  String get privacyNoBlocked => 'No blocked members';

  @override
  String get privacyNoBlockedSubtitle => 'Members you block will appear here.';

  @override
  String get privacyBlockAnother => 'Block another member';

  @override
  String get privacyDeleteAccountSubtitle =>
      'Permanently remove your account, posts and conversations.';

  @override
  String blockUserLabel(String name) {
    return 'Block $name';
  }

  @override
  String blockUserTitle(String name) {
    return 'Block $name?';
  }

  @override
  String blockUserDone(String name) {
    return '$name has been blocked.';
  }

  @override
  String blockUnblocked(String name) {
    return '$name can contact you again.';
  }

  @override
  String get blockChatConfirmBody =>
      'This conversation will disappear and neither of you can message the other. Undo it any time in Privacy & safety.';

  @override
  String get blockProfileSubtitle =>
      'Neither of you can see or message the other';

  @override
  String get blockProfileConfirmBody => 'Undo it any time in Privacy & safety.';

  @override
  String get blockStaffSubtitle => 'Staff accounts cannot be blocked';

  @override
  String get blockMemberFallback => 'Member';

  @override
  String get profileFinderMember => 'Finder member';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileStatActive => 'Active';

  @override
  String get profileStatResolved => 'Resolved';

  @override
  String get profileStatSaved => 'Saved';

  @override
  String profileShareLine(String id) {
    return 'Find me on Finder · member id $id';
  }

  @override
  String get profileCopied => 'Profile details copied to clipboard.';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileCopyDetails => 'Copy profile details';

  @override
  String get profileAboutTitle => 'About Finder';

  @override
  String get profileAboutVersion => 'Version 1.0 · Beacon design';

  @override
  String get profileAboutBody =>
      'Finder helps a community reunite lost belongings with their owners. Report what you lost or found, chat safely inside the app and mark items as resolved when they are back home.';

  @override
  String get profileSafetyFirst => 'Safety first';

  @override
  String get profileSafetyBody =>
      'Meet in public places, never pay a reward before you have your item, and use in-app chat so you can block and report.';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileMyPosts => 'My posts';

  @override
  String get profileMyPostsSubtitle => 'Manage what you have reported';

  @override
  String get profileSavedItems => 'Saved items';

  @override
  String get profileSavedItemsSubtitle => 'Items you are keeping an eye on';

  @override
  String get profileAdminConsole => 'Admin console';

  @override
  String get profileAdminConsoleSubtitle =>
      'Users, posts, reports and verification';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileDarkMode => 'Dark mode';

  @override
  String get profileNightTheme => 'Nightwatch theme';

  @override
  String get profileDayTheme => 'Daylight theme';

  @override
  String get profileSupportLegal => 'Support & legal';

  @override
  String get profileTerms => 'Terms of service';

  @override
  String get profilePrivacyPolicy => 'Privacy policy';

  @override
  String get profileLogOutTitle => 'Log out?';

  @override
  String get profileLogOutBody => 'You can sign back in at any time.';

  @override
  String get profileDiscardTitle => 'Discard changes?';

  @override
  String get profileDiscardBody => 'Your edits have not been saved.';

  @override
  String get profileKeepEditing => 'Keep editing';

  @override
  String get profileLoading => 'Loading your profile...';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileFullNameHint => 'Your name';

  @override
  String get profileNickname => 'Nickname';

  @override
  String get profileNicknameHint => 'How friends know you';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profilePhoneHint => '+1 234 567 8900';

  @override
  String get profileCity => 'City';

  @override
  String get profileCityHint => 'City, country';

  @override
  String get profileJob => 'Job / occupation';

  @override
  String get profileJobHint => 'What do you do?';

  @override
  String get profileSignInEmailLabel => 'SIGN-IN E-MAIL';

  @override
  String get profileEmailNote =>
      'Your e-mail is used to sign in and cannot be changed here.';

  @override
  String get profileSaveChanges => 'Save changes';

  @override
  String get profileEnterName => 'Please enter your name.';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String get profileLoadingOther => 'Loading profile…';

  @override
  String get profileUnavailableTitle => 'This member is not available';

  @override
  String get profileUnavailableSubtitle =>
      'The account may have been removed, or you cannot see each other.';

  @override
  String get profileMore => 'More';

  @override
  String profileMemberSince(String time) {
    return 'Member since $time';
  }

  @override
  String profilePostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
    );
    return '$_temp0';
  }

  @override
  String profileMessageFirstName(String name) {
    return 'Message $name';
  }

  @override
  String profileItemsReported(String name) {
    return 'Items $name reported';
  }

  @override
  String get profileNoPosts => 'No posts yet';

  @override
  String get profileSendMessage => 'Send a message';

  @override
  String get profileFinderAdmin => 'Finder administrator';

  @override
  String get profileAdminBadge => 'ADMIN';

  @override
  String get profileFindMember => 'Find a member';

  @override
  String get profileSearchMemberHint => 'Search by name or email…';

  @override
  String get profileSelect => 'Select';

  @override
  String get profileSearchFailed => 'Search failed.';

  @override
  String get profileSearchSubtitle =>
      'Type at least two letters of a name or e-mail address.';

  @override
  String get profileSearchBlockedNote =>
      'Members you have blocked will not appear here.';

  @override
  String profileSearchNoMatch(String query) {
    return 'No members match \"$query\".';
  }

  @override
  String profileUserRowSemantics(String name, String action) {
    return '$name, $action';
  }

  @override
  String get verifyVerifiedIdentity => 'Verified identity';

  @override
  String get verifyGetVerified => 'Get verified';

  @override
  String get verifyBadgeVisible => 'Your badge is visible to the community';

  @override
  String get verifyBuildTrust => 'Build trust with a verified badge';

  @override
  String get verifyPassport => 'Passport';

  @override
  String get verifyIdentityCard => 'Identity card';

  @override
  String get verifyDriversLicense => 'Driver\'s license';

  @override
  String get verifyTitle => 'Verify identity';

  @override
  String get verifyApprovedSubtitle => 'Your identity is verified';

  @override
  String get verifyUnderReview => 'Under review';

  @override
  String get verifyNeedsNewPhotos => 'Needs new photos';

  @override
  String verifyStepsComplete(int count) {
    return '$count of 3 steps complete';
  }

  @override
  String get verifyCheckingStatus => 'Checking your status...';

  @override
  String get verifyVerifiedMember => 'Verified member';

  @override
  String get verifyReviewedByPerson => 'Reviewed by a person';

  @override
  String get verifyThanks => 'Thanks for helping keep Finder trustworthy.';

  @override
  String get verifyHeroHeadline =>
      'Verified accounts help build a safer community for everyone.';

  @override
  String get verifyApprovedBody =>
      'Your posts and messages now show the verified badge.';

  @override
  String get verifyHeroBody =>
      'Your photos are stored privately and only seen by the Finder team member who checks them. Review usually takes a day.';

  @override
  String get verifyHowItWorks => 'How it works';

  @override
  String get verifyStep1Title => 'Photograph your ID';

  @override
  String get verifyStep1Body =>
      'Camera or gallery. Every corner in frame, no glare.';

  @override
  String get verifyStep2Title => 'Take a live selfie';

  @override
  String get verifyStep2Body =>
      'Front camera only, so we know it is really you.';

  @override
  String get verifyStep3Title => 'A person reviews it';

  @override
  String get verifyStep3Body =>
      'They compare the face on the ID with your selfie and the name on your account. You get a notification either way.';

  @override
  String get verifyIdentityVerified => 'Identity verified';

  @override
  String get verifyPending => 'Verification pending';

  @override
  String get verifyPendingBadge => 'PENDING';

  @override
  String verifyVerifiedWith(String doc) {
    return 'Verified with your $doc.';
  }

  @override
  String verifyReceived(String doc, String time) {
    return 'We received your $doc $time. A Finder team member is reviewing it; you will get a notification when it is done.';
  }

  @override
  String get verifyNotApproved => 'Not approved yet';

  @override
  String get verifyNeedsPhotosBadge => 'NEEDS PHOTOS';

  @override
  String get verifyPhotosRejected => 'The photos could not be verified.';

  @override
  String verifyReviewedAt(String time) {
    return 'Reviewed $time';
  }

  @override
  String get verifySubmitNewPhotos => 'Submit new photos';

  @override
  String verifyDocTypeLower(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'id_card': 'identity card',
      'drivers_license': 'driver\'s license',
      'passport': 'passport',
      'other': 'document',
    });
    return '$_temp0';
  }

  @override
  String get verifyDocSelection => 'Document selection';

  @override
  String get verifyDocSelectionSubtitle =>
      'Choose the ID you wish to use for verification';

  @override
  String get verifyDocPhotos => 'Document photos';

  @override
  String get verifyBothSides => 'Both sides of your ID, camera or gallery';

  @override
  String get verifyPhotoPage => 'The photo page, camera or gallery';

  @override
  String get verifyFrontOfId => 'Front of ID';

  @override
  String get verifyPhotoPageLabel => 'Photo page';

  @override
  String get verifyBackOfId => 'Back of ID';

  @override
  String get verifyLiveSelfie => 'Live selfie';

  @override
  String get verifyLiveSelfieSubtitle =>
      'Taken now with the front camera; gallery photos are not accepted.';

  @override
  String get verifyRetakeSelfie => 'Retake selfie';

  @override
  String get verifyTakeSelfie => 'Take a selfie';

  @override
  String get verifyTip =>
      'Use a well-lit area, keep the whole document in frame and remove hats or sunglasses for the selfie.';

  @override
  String get verifyFrontOfYourId => 'Front of your ID';

  @override
  String get verifyBackOfYourId => 'Back of your ID';

  @override
  String get verifyStoredPrivately =>
      'Stored privately, seen only by the reviewer.';

  @override
  String verifyAddDocumentFirst(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Please add your document photos first.',
      one: 'Please add your document photo first.',
    );
    return '$_temp0';
  }

  @override
  String get verifyTakeSelfieFirst => 'Please take a selfie to finish.';

  @override
  String get verifySubmitted =>
      'Submitted. You will be notified once it has been reviewed.';

  @override
  String verifyStepLabel(int index) {
    return 'STEP $index';
  }

  @override
  String get verifySubmitForReview => 'Submit for review';

  @override
  String get verifyConfirmOwnership =>
      'By submitting you confirm the documents are yours.';

  @override
  String get verifyAddToContinue =>
      'Add your document photos and a selfie to continue.';

  @override
  String verifyUploadAddedSemantics(String label) {
    return '$label added, tap to replace';
  }

  @override
  String verifyUploadAddSemantics(String label) {
    return 'Add $label';
  }

  @override
  String verifyUploadAdded(String label) {
    return '$label added';
  }

  @override
  String get verifyTapToReplace => 'Tap to replace';

  @override
  String get verifyCameraOrGallery => 'Camera or gallery';

  @override
  String get helpTitle => 'Help & support';

  @override
  String get helpHeroPrefix => 'How can we ';

  @override
  String get helpHeroAccent => 'support';

  @override
  String get helpHeroSuffix => ' you today?';

  @override
  String get helpIntro =>
      'Whether you\'ve lost a treasure or found a memory, the answers below cover most questions.';

  @override
  String get helpSearchHint => 'Search questions (e.g. \'password\')';

  @override
  String helpNoAnswers(String query) {
    return 'No answers match \"$query\". Try another word or contact us below.';
  }

  @override
  String helpAnswersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers',
      one: '1 answer',
    );
    return '$_temp0';
  }

  @override
  String get helpBrowseByTopic => 'Browse by topic';

  @override
  String get helpStillQuestions => 'Still have questions?';

  @override
  String get helpEmailReply => 'E-mail us and we reply within one working day.';

  @override
  String get helpEmailSupport => 'E-mail support';

  @override
  String get helpEmailSubject => 'Finder support request';

  @override
  String get helpEmailBody => 'Hi Finder team,\n\n';

  @override
  String get helpCopyAddress => 'Copy support address';

  @override
  String helpAddressCopied(String email) {
    return '$email copied.';
  }

  @override
  String get helpTechnicalFeedback => 'TECHNICAL FEEDBACK';

  @override
  String get helpFoundGlitch => 'Found a glitch?';

  @override
  String get helpGlitchBody =>
      'Tell us what you did, what you expected and what happened instead. Screenshots help a lot.';

  @override
  String get helpReportIssue => 'Report a technical issue';

  @override
  String get helpBugSubject => 'Finder bug report';

  @override
  String get helpBugBody =>
      'What I did:\n\nWhat I expected:\n\nWhat happened:\n\nDevice / platform:\n';

  @override
  String helpNoEmailApp(String email) {
    return 'No e-mail app found. $email was copied to your clipboard.';
  }

  @override
  String get helpGotIt => 'Got it';

  @override
  String get helpTopicAccountSubtitle => 'Profile, verification and passwords';

  @override
  String get helpFaqChangeNameQ => 'How do I change my name or photo?';

  @override
  String get helpFaqChangeNameA =>
      'Open Profile, tap \"Edit profile\", change the fields and save. The new photo shows on all your posts and messages.';

  @override
  String get helpFaqForgotPasswordQ => 'I forgot my password.';

  @override
  String get helpFaqForgotPasswordA =>
      'On the sign-in screen tap \"Forgot password?\". A reset code is sent to your e-mail; enter it together with your new password.';

  @override
  String get helpFaqVerifiedBadgeQ => 'What does the verified badge mean?';

  @override
  String get helpFaqVerifiedBadgeA =>
      'A verified member confirmed their identity with an ID document and a selfie. Start from Profile → Get verified. Review takes about a day.';

  @override
  String get helpFaqDeleteAccountQ => 'How do I delete my account?';

  @override
  String get helpFaqDeleteAccountA =>
      'Go to Privacy & safety → Request data deletion. We remove your posts, conversations and profile within 30 days.';

  @override
  String get helpTopicSafety => 'Safety';

  @override
  String get helpTopicSafetySubtitle => 'Meet-ups and blocking';

  @override
  String get helpFaqMeetQ => 'Where should I meet to hand over an item?';

  @override
  String get helpFaqMeetA =>
      'Choose a busy public place in daylight, such as a café, a police station or a shopping centre. Bring a friend if you can.';

  @override
  String get helpFaqBotheringQ => 'Someone is bothering me.';

  @override
  String get helpFaqBotheringA =>
      'Open the conversation, tap the menu in the top-right corner and choose \"Block\". They can no longer see your posts or message you. Report the post too if it looks fake.';

  @override
  String get helpFaqRewardQ =>
      'Should I pay a reward before I get my item back?';

  @override
  String get helpFaqRewardA =>
      'No. Never send money before you have the item in your hands. Rewards are voluntary and paid at the hand-over.';

  @override
  String get helpTopicPosting => 'Posting items';

  @override
  String get helpTopicPostingSubtitle => 'Writing reports that get matches';

  @override
  String get helpFaqGoodPostQ => 'What makes a good post?';

  @override
  String get helpFaqGoodPostA =>
      'A clear photo, a precise location, the date and time, and distinctive details (scratches, stickers, engravings). Keep serial numbers private until someone proves they own the item.';

  @override
  String get helpFaqMarkReturnedQ => 'How do I mark an item as returned?';

  @override
  String get helpFaqMarkReturnedA =>
      'Open the post or go to My posts and choose \"Mark as resolved\". Everyone who chatted with you about it gets a notification.';

  @override
  String get helpFaqEditPostQ => 'Can I edit or delete a post?';

  @override
  String get helpFaqEditPostA =>
      'Yes. From My posts tap Edit, or open the post and use the menu in the top-right corner to edit, resolve or delete it.';

  @override
  String get helpTopicMessaging => 'Messaging';

  @override
  String get helpTopicMessagingSubtitle => 'Contacting owners and finders';

  @override
  String get helpFaqContactOwnerQ => 'How do I contact the owner of a post?';

  @override
  String get helpFaqContactOwnerA =>
      'Open the post and tap \"Chat with owner\" (or \"I found this item\"). A conversation about that item opens in Messages.';

  @override
  String get helpFaqSendPhotosQ => 'Can I send photos?';

  @override
  String get helpFaqSendPhotosA =>
      'Yes. In a conversation tap the photo button next to the message field to send a picture as proof.';

  @override
  String get helpFaqCantMessageQ => 'Why can\'t I message someone?';

  @override
  String get helpFaqCantMessageA =>
      'Either one of you blocked the other, or they turned off direct messages in their privacy settings.';

  @override
  String helpComingSoon(String feature) {
    return '$feature is coming soon.';
  }

  @override
  String get helpThisFeature => 'This feature';

  @override
  String get voicePlay => 'Play voice message';

  @override
  String get voicePause => 'Pause voice message';

  @override
  String get voiceHoldHint => 'Hold the microphone to record a voice message.';

  @override
  String get voiceHoldTap => 'Hold to record a voice message.';

  @override
  String get voiceSlideToCancel => 'Slide to cancel';

  @override
  String get voiceCancelRecording => 'Cancel recording';

  @override
  String get photoAddTitle => 'Add a photo';

  @override
  String get photoTakePhoto => 'Take a photo';

  @override
  String get photoOpenCamera => 'Open the camera';

  @override
  String get photoChooseGallery => 'Choose from gallery';

  @override
  String get photoPickExisting => 'Pick an existing picture';

  @override
  String get photoOpenFailed => 'This picture could not be opened.';

  @override
  String get photoPrepareFailed => 'Could not prepare the photo. Try again.';

  @override
  String get photoAdjustAvatar => 'Adjust your photo';

  @override
  String get photoAdjustCover => 'Adjust your cover';

  @override
  String get photoUse => 'Use photo';

  @override
  String get photoGestureHint =>
      'Pinch to zoom · drag to move · double-tap to zoom';

  @override
  String get photoRotate => 'Rotate';

  @override
  String get photoReset => 'Reset';

  @override
  String get photoRemoveCover => 'Remove cover photo';

  @override
  String get photoAddCover => 'Add a cover photo';

  @override
  String get photoChangeCover => 'Change cover photo';

  @override
  String get photoChangeProfile => 'Change profile photo';

  @override
  String get photoAddProfile => 'Add profile photo';

  @override
  String get photoProfileTitle => 'Profile photo';

  @override
  String get photoCoverTitle => 'Cover photo';

  @override
  String photoUploadFailed(String detail) {
    return 'Photo upload failed. $detail';
  }

  @override
  String get photoFileEmpty => 'The selected file is empty.';

  @override
  String get photoTooLarge => 'Please choose an image under 8 MB.';

  @override
  String get photoNoFileId => 'The server returned no file id.';

  @override
  String get photoNoUrl => 'The server returned no image URL.';

  @override
  String get photoCameraDenied =>
      'Camera access was denied. Allow it in your phone settings or choose a photo from the gallery.';

  @override
  String get photoAccessDenied =>
      'Photo access was denied. Allow it in your phone settings and try again.';

  @override
  String get photoCameraOpenFailed => 'Could not open the camera.';

  @override
  String get photoPickerOpenFailed => 'Could not open the photo picker.';

  @override
  String get pushMessagesChannelDesc => 'New chat messages';

  @override
  String get pushUpdatesChannel => 'Updates';

  @override
  String get pushUpdatesChannelDesc => 'Post and account updates';

  @override
  String get chatTyping => 'typing…';

  @override
  String get chatOnline => 'online';

  @override
  String chatLastSeen(String when) {
    return 'last seen $when';
  }

  @override
  String get chatYouPrefix => 'You: ';

  @override
  String get chatAddCaption => 'Add a caption…';

  @override
  String get chatLoadingOlder => 'Loading older messages…';

  @override
  String get voiceTapToLock => 'Tap to record hands-free, hold to record';

  @override
  String get voiceSlideUpToLock => 'Slide up to lock';

  @override
  String get voiceSend => 'Send voice message';

  @override
  String get voiceDiscard => 'Discard recording';

  @override
  String voiceSpeed(String speed) {
    return '$speed×';
  }

  @override
  String get chatForwarded => 'Forwarded';

  @override
  String get chatDeleteForMe => 'Delete for me';

  @override
  String get chatForward => 'Forward';

  @override
  String get chatForwardTo => 'Forward to';

  @override
  String get chatForwardSent => 'Forwarded.';

  @override
  String chatUnreadMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenPhoto => 'Open photo';

  @override
  String get welcomeTitle => 'Welcome to Finder';

  @override
  String get welcomeSubtitle =>
      'Lost-and-found for your city: reviewed by people, matched for you, in your language.';

  @override
  String get welcomeStep1Title => 'Post it';

  @override
  String get welcomeStep1Body =>
      'Lost or found, add a photo and the place. A moderator checks it before it goes live.';

  @override
  String get welcomeStep2Title => 'Get matched';

  @override
  String get welcomeStep2Body =>
      'We alert you when a post matches yours and show every post in your app language.';

  @override
  String get welcomeStep3Title => 'Return it safely';

  @override
  String get welcomeStep3Body =>
      'Chat here, ask for a detail only the owner knows, and meet in a public place.';

  @override
  String get welcomeHelpHint =>
      'Step-by-step guides, including how to make sure you are talking to the real owner, are in Profile → Help & Support.';

  @override
  String get welcomeGotIt => 'Got it';

  @override
  String get welcomeOpenHelp => 'See the guides';

  @override
  String get helpTileSubtitle => 'Guides, safety tips and contact';

  @override
  String get helpGuideTitle => 'How Finder works';

  @override
  String get helpGuideStartTitle => 'Getting started';

  @override
  String get helpGuideStartSubtitle =>
      'Language, profile, notifications, badges';

  @override
  String get helpGuideStart1 =>
      'Pick your language from the globe icon on the sign-in screen or in Profile. Every post is shown in that language.';

  @override
  String get helpGuideStart2 =>
      'Complete your profile with a real name and a photo: people are more likely to return an item to someone they can recognise.';

  @override
  String get helpGuideStart3 =>
      'Allow notifications so you hear about matches and messages right away.';

  @override
  String get helpGuideStart4 =>
      'Badges: Pending means a moderator is still checking the post, Live means everyone can see it, Returned means the item is back with its owner.';

  @override
  String get helpGuideLostTitle => 'Posting a lost item';

  @override
  String get helpGuideLostSubtitle => 'What to include, what to keep back';

  @override
  String get helpGuideLost1 =>
      'Add a clear photo of the item, or of the same model, so people recognise it at a glance.';

  @override
  String get helpGuideLost2 =>
      'Give the exact place and the time you last had it. Nearby people see your post first.';

  @override
  String get helpGuideLost3 =>
      'Describe it, but keep one or two details to yourself (a scratch, the contents, an engraving). You will use them to check that a finder really has it.';

  @override
  String get helpGuideLost4 =>
      'A reward is optional. Never pay anything before the item is in your hands.';

  @override
  String get helpGuideLost5 =>
      'Your post shows Pending until a moderator approves it, usually within a few hours. You get a notification when it is live and whenever a found post matches.';

  @override
  String get helpGuideFoundTitle => 'Posting a found item';

  @override
  String get helpGuideFoundSubtitle =>
      'Protect the owner while you look for them';

  @override
  String get helpGuideFound1 =>
      'Photograph the item, but hide anything personal: names, ID numbers, bank cards, addresses, phone screens.';

  @override
  String get helpGuideFound2 =>
      'Do not post serial numbers, IMEI or the contents of a wallet or bag. Keep them to check claims.';

  @override
  String get helpGuideFound3 =>
      'Say where and when you found it and roughly where it is now. You do not have to share your home address.';

  @override
  String get helpGuideFound4 =>
      'Documents, passports, phones, bank cards and money: hand them to the police or the venue\'s lost-property desk as well, and say so in the post.';

  @override
  String get helpGuideFound5 =>
      'Once approved, the app matches your post with people searching for it and alerts them, in their own language.';

  @override
  String get helpGuideMatchTitle => 'When you get a match or a message';

  @override
  String get helpGuideMatchSubtitle => 'What to do next';

  @override
  String get helpGuideMatch1 =>
      'Open the matching post and compare the photo, place and time with yours.';

  @override
  String get helpGuideMatch2 =>
      'Reply inside the app chat. Keep your phone number and address private until you have met.';

  @override
  String get helpGuideMatch3 =>
      'If you found the item, ask the claimant for a detail that is not in the post before you agree to meet.';

  @override
  String get helpGuideMatch4 =>
      'Not the right item? Just say so politely. Someone who pressures you, asks for money or pushes to move to another app is a red flag: block and report them.';

  @override
  String get helpGuideVerifyTitle => 'Making sure it is the real owner';

  @override
  String get helpGuideVerifySubtitle => 'Simple checks that stop false claims';

  @override
  String get helpGuideVerify1 =>
      'Ask for something only the owner would know: what is inside, a scratch or sticker, the lock-screen photo, an engraving, the exact colour of a strap.';

  @override
  String get helpGuideVerify2 =>
      'Ask for a photo of the item from before it was lost, or a receipt, the box, or a serial number you can compare.';

  @override
  String get helpGuideVerify3 =>
      'For phones: the owner can call the number or unlock it in front of you. For keys: they can name the car or open the door.';

  @override
  String get helpGuideVerify4 =>
      'For documents and bank cards, hand them over only to the person named on them, with a matching ID, or to the issuing office or police.';

  @override
  String get helpGuideVerify5 =>
      'Never send a deposit, transfer money or share bank details to \"release\" an item. Finder never asks for payments.';

  @override
  String get helpGuideVerify6 =>
      'Still unsure? Ask to meet at a police station, or report the conversation and let a moderator look at it.';

  @override
  String get helpGuideMeetTitle => 'Meeting safely';

  @override
  String get helpGuideMeetSubtitle => 'The hand-over';

  @override
  String get helpGuideMeet1 =>
      'Meet in a busy public place in daylight: a mall, a café, a police station or a lost-property desk.';

  @override
  String get helpGuideMeet2 =>
      'Bring a friend or tell someone where you are going and when you expect to be back.';

  @override
  String get helpGuideMeet3 =>
      'Do not get into a car or go to a private home for a hand-over.';

  @override
  String get helpGuideMeet4 =>
      'Give a reward only after you have the item, and only if you offered one. Nobody can demand it.';

  @override
  String get helpGuideMeet5 =>
      'Afterwards, mark the post as Returned so the alert stops and others can celebrate with you.';

  @override
  String get helpGuideReportTitle => 'Reporting a problem';

  @override
  String get helpGuideReportSubtitle => 'Posts, people, bugs';

  @override
  String get helpGuideReport1 =>
      'Report a post from its menu and pick a reason. A moderator reviews it and can remove it or warn the author.';

  @override
  String get helpGuideReport2 =>
      'Block a user from their profile or the chat to stop their messages. They are not told.';

  @override
  String get helpGuideReport3 =>
      'Every new post is checked by a moderator, with an AI pre-check for scams, ads and inappropriate images. Approved posts can still be reported.';

  @override
  String get helpGuideReport4 =>
      'Something broken? Use \"Report an issue\" below. Urgent safety matters: contact the police first.';

  @override
  String get navPost => 'Post';

  @override
  String navTab(String label) {
    return '$label tab';
  }

  @override
  String get categoryAllItems => 'All Items';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryNearby => 'Nearby';

  @override
  String get categoryRecent => 'Recent';

  @override
  String get categoryWithReward => 'With Reward';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryWatchesJewelry => 'Watches & Jewelry';

  @override
  String get categoryWalletsBags => 'Wallets & Bags';

  @override
  String get categoryKeys => 'Keys';

  @override
  String get categoryPets => 'Pets';

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryWallets => 'Wallets';

  @override
  String get categoryBags => 'Bags';

  @override
  String get categoryWallet => 'Wallet';

  @override
  String get categoryJewelry => 'Jewelry';

  @override
  String get categoryOthers => 'Others';

  @override
  String get categoryVisibilityPublic => 'Public';

  @override
  String get categoryVisibilityFriendsOnly => 'Friends Only';

  @override
  String get categoryVisibilityPrivate => 'Private';

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterSubtitle => 'Narrow down what you are looking for';

  @override
  String get filterReset => 'Reset';

  @override
  String get filterApply => 'Apply filters';

  @override
  String get filterType => 'Type';

  @override
  String get filterLocationHint => 'Enter city or area';

  @override
  String get filterDateRange => 'Date range';

  @override
  String get filterFrom => 'From';

  @override
  String get filterTo => 'To';

  @override
  String get filterSelectDate => 'Select date';

  @override
  String get filterRewardOffered => 'Reward offered';

  @override
  String get filterRewardSubtitle => 'Only posts that offer a reward';

  @override
  String get filterVerifiedOnly => 'Verified users only';

  @override
  String get filterVerifiedSubtitle => 'Posted by identity-verified members';

  @override
  String get filterSortBy => 'Sort by';

  @override
  String get filterMostRecent => 'Most Recent';

  @override
  String get filterNearest => 'Nearest to Me';

  @override
  String get filterAnyTime => 'Any time';

  @override
  String get filterLast24h => 'Last 24h';

  @override
  String get filterLastWeek => 'Last Week';

  @override
  String get filterLastMonth => 'Last Month';

  @override
  String filterDate(int day, String month, int year) {
    return '$day $month, $year';
  }

  @override
  String get searchSubtitle => 'Find lost and found items near you';

  @override
  String get searchHint => 'Search items, places…';

  @override
  String get searchClear => 'Clear search';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get searchClearFilters => 'Clear filters';

  @override
  String get searchResetFilters => 'Reset filters';

  @override
  String get searchNoResultsTitle => 'No matching items found';

  @override
  String get searchNoResultsSubtitle =>
      'Try a different keyword or adjust your filters.';

  @override
  String get homeReportLost => 'Report lost';

  @override
  String get homeReportLostSubtitle => 'Ask the community';

  @override
  String get homeReportFound => 'Report found';

  @override
  String get homeReportFoundSubtitle => 'Return it home';

  @override
  String get homeLoadingPosts => 'Loading posts...';

  @override
  String get homeNoLostItems => 'No lost items';

  @override
  String get homeNoFoundItems => 'No found items';

  @override
  String get homeNoPostsYet => 'No posts yet';

  @override
  String get homeCreateFirstPost => 'Create the first post to get started.';

  @override
  String get homeTrySwitchingAll => 'Try switching to All Items.';

  @override
  String get homeOpenProfile => 'Open profile';

  @override
  String get homeContactOwner => 'Contact Owner';

  @override
  String get homeContactFinder => 'Contact Finder';

  @override
  String get homeGoodMorning => 'Good morning';

  @override
  String get homeGoodAfternoon => 'Good afternoon';

  @override
  String get homeGoodEvening => 'Good evening';

  @override
  String get homeGuest => 'Guest';

  @override
  String homeNotificationsUnread(int count) {
    return 'Notifications, $count unread';
  }

  @override
  String get mapPickLocation => 'Pick a location';

  @override
  String get mapSearchHint => 'Search a place or address';

  @override
  String get mapSearching => 'Searching…';

  @override
  String get mapMoveToPlacePin => 'Move the map to place the pin';

  @override
  String get mapUseMyLocation => 'Use my current location';

  @override
  String get mapFindingAddress => 'Finding the address…';

  @override
  String get mapUseThisLocation => 'Use this location';

  @override
  String get mapAttribution => 'Map data © OpenStreetMap contributors';

  @override
  String get mapErrGpsOff =>
      'Turn on location services (GPS) to use your current location.';

  @override
  String get mapErrBlocked =>
      'Location access is blocked. Allow it in your phone settings to use your current location.';

  @override
  String get mapErrDenied => 'Location permission was not granted.';

  @override
  String get mapErrNoFix =>
      'Could not get a GPS fix. Move somewhere with a clearer view of the sky and try again.';

  @override
  String shareKindTitle(String kind, String title) {
    return '$kind: $title';
  }

  @override
  String shareFindMe(String id) {
    return 'Find me on Finder · member id $id';
  }

  @override
  String shareProfileSubject(String name) {
    return '$name on Finder';
  }

  @override
  String get postItemDetailsTitle => 'Item Details';

  @override
  String get postItemDetails => 'Item details';

  @override
  String get postNoDescription => 'No description provided yet.';

  @override
  String get postReward => 'REWARD';

  @override
  String postRewardAmount(String amount) {
    return 'REWARD $amount';
  }

  @override
  String get postIFoundThis => 'I found this item';

  @override
  String get postThisIsMine => 'This is mine';

  @override
  String get postReturnedOwnerNote =>
      'Marked as returned. It no longer shows on Home, but stays in Search so people can see the outcome.';

  @override
  String get postRemoveFromSaved => 'Remove from saved';

  @override
  String get postSaveItem => 'Save item';

  @override
  String get postMoreActions => 'More actions';

  @override
  String get postLinkCopied => 'Link copied.';

  @override
  String get postDetailsCopied => 'Item details copied to clipboard.';

  @override
  String get postSavedToList => 'Saved to your list.';

  @override
  String get postRemovedFromSaved => 'Removed from saved items.';

  @override
  String get postManageSheetTitle => 'Manage post';

  @override
  String get postMoreSheetTitle => 'More';

  @override
  String get postShareSubtitle => 'Send the photo and a link to anyone';

  @override
  String get postCopyLink => 'Copy link';

  @override
  String get postEditPost => 'Edit post';

  @override
  String get postReopenPost => 'Reopen post';

  @override
  String get postDeletePost => 'Delete post';

  @override
  String get postReportPost => 'Report post';

  @override
  String get postBlockThisMember => 'Block this member';

  @override
  String get postBlockMember => 'Block member';

  @override
  String get postActiveAgain => 'Post is active again.';

  @override
  String get postDeleteTitle => 'Delete post?';

  @override
  String postDeleteBody(String title) {
    return '\"$title\" will be removed for everyone. This cannot be undone.';
  }

  @override
  String postDeleteBodyConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This cannot be undone.';
  }

  @override
  String get postDeleted => 'Post deleted.';

  @override
  String get postReportReasonSpam => 'Spam or scam';

  @override
  String get postReportReasonInappropriate => 'Inappropriate content';

  @override
  String get postReportReasonMisleading => 'Wrong or misleading information';

  @override
  String get postReportReasonOther => 'Something else';

  @override
  String get postReportSheetTitle => 'Report this post';

  @override
  String get postReportSheetSubtitle =>
      'Tell us what is wrong. Reports are reviewed by the team.';

  @override
  String get postReported => 'Thanks, the post has been reported.';

  @override
  String get postThisMember => 'this member';

  @override
  String postBlockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get postBlockBody =>
      'You will no longer see each other\'s posts or messages. You can undo this in Privacy & safety.';

  @override
  String postBlocked(String name) {
    return '$name has been blocked.';
  }

  @override
  String get postCategory => 'Category';

  @override
  String get postLostOn => 'Lost on';

  @override
  String get postFoundOn => 'Found on';

  @override
  String get postOpenInMaps => 'Open in Maps';

  @override
  String get postCouldNotOpenMaps => 'Could not open a maps app.';

  @override
  String get postNotProvided => 'Not provided';

  @override
  String get postPostedByOwner => 'POSTED BY THE OWNER';

  @override
  String get postPostedByFinder => 'POSTED BY THE FINDER';

  @override
  String get postLoadingProfile => 'Loading profile…';

  @override
  String get postProfileNotAvailable => 'Profile not available';

  @override
  String get postVerifiedMember => 'Verified member';

  @override
  String postMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String postPostsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts',
      one: '1 post',
    );
    return '$_temp0';
  }

  @override
  String postMonthYear(String month, int year) {
    return '$month $year';
  }

  @override
  String get postPhone => 'Phone';

  @override
  String get postCouldNotOpenDialer => 'Could not open the phone dialer.';

  @override
  String get postChatWithOwner => 'Chat with owner';

  @override
  String get postChatWithFinder => 'Chat with finder';

  @override
  String get postCall => 'Call';

  @override
  String get postPhoneNotShared =>
      'Phone number not shared. In-app chat is the safest way to coordinate.';

  @override
  String get postOwnerActions => 'OWNER ACTIONS';

  @override
  String get postSafety => 'SAFETY';

  @override
  String get postPossibleMatches => 'Possible matches';

  @override
  String get postMatchesEyebrowLost => 'Found items that look like yours';

  @override
  String get postMatchesEyebrowFound => 'Lost items that look like this one';

  @override
  String get postNoMatchesLost =>
      'No matches yet. We keep comparing new found posts with this one and notify you the moment something looks alike.';

  @override
  String get postNoMatchesFound =>
      'No matches yet. We keep comparing new lost posts with this one and notify you the moment something looks alike.';

  @override
  String get postSimilarItems => 'Similar items';

  @override
  String get postSimilarEyebrowLost => 'Found items in this category';

  @override
  String get postSimilarEyebrowFound => 'Lost items in this category';

  @override
  String get postViewAll => 'View all';

  @override
  String get postLoadingSimilar => 'Loading similar items...';

  @override
  String get postNoSimilarTitle => 'No similar items yet';

  @override
  String get postNoSimilarSubtitle => 'Check back later for matches nearby.';

  @override
  String get postMatchBannerTitleLost => 'Could this be the item you found?';

  @override
  String get postMatchBannerTitleFound => 'Could this be your item?';

  @override
  String get postMatchBannerBodyLost =>
      'Someone reported losing something that looks like the item you found. Compare the details and message them.';

  @override
  String get postMatchBannerBodyFound =>
      'Someone reported finding something that looks like what you lost. Compare the details and message them.';

  @override
  String get postMessageOwner => 'Message the owner';

  @override
  String get postMessageFinder => 'Message the finder';

  @override
  String postItemSemantics(String status, String title) {
    return '$status item, $title';
  }

  @override
  String get postLocationNotSet => 'Location not set';

  @override
  String get postNewPost => 'New post';

  @override
  String get postHeaderLost => 'Tell the community what you lost.';

  @override
  String get postHeaderFound => 'Help return what you found.';

  @override
  String get postReadyToPost => 'Ready to post';

  @override
  String postDetailsAdded(int count) {
    return '$count of 5 details added';
  }

  @override
  String get postPhotos => 'Photos';

  @override
  String get postPhoto => 'Photo';

  @override
  String postStep(int number) {
    return 'Step $number';
  }

  @override
  String get postPhotosHint => 'Clear photos help others identify the item.';

  @override
  String get postCamera => 'Camera';

  @override
  String get postGallery => 'Gallery';

  @override
  String get postRemovePhoto => 'Remove photo';

  @override
  String get postUploadingPhoto => 'Uploading photo';

  @override
  String postAddPhotoFrom(String source) {
    return 'Add photo from $source';
  }

  @override
  String get postItemName => 'Item name';

  @override
  String get postItemNameHint => 'e.g. Blue backpack';

  @override
  String get postItemNameHintEdit => 'e.g. Black wallet';

  @override
  String get postChooseCategory => 'Choose a category';

  @override
  String get postChooseCategoryTitle => 'Choose category';

  @override
  String get postDescription => 'Description';

  @override
  String get postDescriptionHint =>
      'e.g. Last seen near the fountain at Central Park. It has a small scratch on the front…';

  @override
  String postDescriptionHelper(int count) {
    return '$count/500 · at least 10 characters';
  }

  @override
  String get postDescriptionHintEdit => 'Describe the item in detail…';

  @override
  String get postDescriptionHelperEdit => 'At least 10 characters';

  @override
  String get postRewardOptional => 'Reward (optional)';

  @override
  String get postRewardHint => 'e.g. \$100';

  @override
  String get postRewardHintEdit => 'e.g. 50';

  @override
  String get postRewardNote =>
      'A reward is shown as an amber tag on your post.';

  @override
  String get postLocationTime => 'Location & time';

  @override
  String get postNoLocationSelected => 'No location selected';

  @override
  String get postLocateMe => 'Locate me';

  @override
  String get postOpenMap => 'Open map';

  @override
  String get postMovePin => 'Move pin';

  @override
  String get postPickOnMap => 'Pick on map';

  @override
  String get postMovePinOnMap => 'Move pin on map';

  @override
  String get postTypeAddress => 'Type an address instead';

  @override
  String get postDate => 'Date';

  @override
  String get postTime => 'Time';

  @override
  String get postDateTime => 'Date / time';

  @override
  String get postTapToPickDate => 'Tap to pick date';

  @override
  String get postLocationHint => 'Where was it lost or found?';

  @override
  String get postHowPeopleReachYou => 'How people reach you';

  @override
  String get postInAppChat => 'In-app chat';

  @override
  String get postInAppChatNote =>
      'Always on. Members contact you through Finder messages.';

  @override
  String get postOn => 'ON';

  @override
  String get postShowPhone => 'Show my phone number';

  @override
  String get postShowPhoneNote => 'Shown on your profile to signed-in members';

  @override
  String get postPhoneNumber => 'Phone number';

  @override
  String get postPhoneHint => 'e.g. +1 234 567 8900';

  @override
  String get postPhoneHelper =>
      'Saved to your profile and shared with signed-in members.';

  @override
  String get postPostNow => 'Post now';

  @override
  String get postSaveDraft => 'Save draft';

  @override
  String get postSaveChanges => 'Save changes';

  @override
  String postLocationSetTo(String label) {
    return 'Location set to $label.';
  }

  @override
  String get postEnterLocation => 'Enter location';

  @override
  String get postEnterLocationHint => 'City, street or area';

  @override
  String get postErrTitleRequired =>
      'Please enter the item name before posting.';

  @override
  String get postErrDescriptionShort =>
      'Please add at least 10 characters in the description.';

  @override
  String get postErrPhoneRequired =>
      'Please enter a phone number or turn off phone sharing.';

  @override
  String get postErrLoginRequired => 'You must be logged in to post.';

  @override
  String get postErrTitleRequiredEdit => 'Please enter a title.';

  @override
  String get postErrDescriptionShortEdit =>
      'Description must be at least 10 characters.';

  @override
  String get postLive => 'Your post is live.';

  @override
  String get postUpdated => 'Post updated.';

  @override
  String get postPhotoAdded => 'Photo added.';

  @override
  String get postDraftSaved => 'Draft saved locally.';

  @override
  String get postUploadingImage => 'Uploading image…';

  @override
  String get postTapToChange => 'Tap to change';

  @override
  String get postTapToPickFromGallery => 'Tap to pick from gallery';

  @override
  String get postAddPhoto => 'Add a photo';

  @override
  String get postChangePhoto => 'Change photo';

  @override
  String get postILostSomething => 'I lost something';

  @override
  String get postIFoundSomething => 'I found something';

  @override
  String get postAskCommunityHelp => 'Ask the community for help';

  @override
  String get postHelpReturnHome => 'Help return it home';

  @override
  String get postMyPosts => 'My posts';

  @override
  String postOpenReturnedCount(int open, int returned) {
    return '$open open · $returned returned';
  }

  @override
  String get postNoOpenPosts => 'No open posts';

  @override
  String get postNoReturnedYet => 'No returned items yet';

  @override
  String get postCreateYourFirst => 'Create your first post to get started.';

  @override
  String get postReturnedAppearHere =>
      'Posts you mark as returned will appear here.';

  @override
  String get postMarkReturnedTitle => 'Mark as returned?';

  @override
  String postMarkReturnedBody(String title) {
    return 'Mark \"$title\" as returned? It leaves the Home feed but stays visible in Search.';
  }

  @override
  String get postErrLoad => 'Unable to load your posts.';

  @override
  String get postErrDelete => 'Unable to delete the post.';

  @override
  String get postErrResolve => 'Unable to resolve the post.';

  @override
  String get postErrReopen => 'Unable to reopen the post.';

  @override
  String get postErrSave => 'Unable to save the post.';

  @override
  String get postSavedItems => 'Saved items';

  @override
  String get postSavedSubtitle =>
      'Keep track of items you\'re helping to return or find.';

  @override
  String postSavedCount(int count) {
    return '$count saved · items you are helping to return or find';
  }

  @override
  String get postLoadingSaved => 'Loading saved items...';

  @override
  String get postNoSavedTitle => 'No saved items yet';

  @override
  String get postNoSavedSubtitle =>
      'Tap the bookmark on any post to keep it here.';

  @override
  String get postSentForReview =>
      'Sent for review. We\'ll tell you when it\'s live.';

  @override
  String get postWaitingForReview => 'Waiting for review';

  @override
  String get postWaitingForReviewBody =>
      'An admin checks every post before it goes public, usually within a few hours.';

  @override
  String get postRejectedTitle => 'Not approved';

  @override
  String postRejectedReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get postEditAndResubmit => 'Edit & resubmit';

  @override
  String get postBadgeRejected => 'NOT APPROVED';

  @override
  String get postBadgeExpired => 'ARCHIVED';

  @override
  String get postExpiredTitle => 'Archived';

  @override
  String get postExpiredBody =>
      'This post was archived after 90 days. Reopen it if it is still relevant.';

  @override
  String get postTranslatedNote => 'Translated automatically';

  @override
  String get postSeeOriginal => 'See original';

  @override
  String get postSeeTranslation => 'See translation';

  @override
  String get postPostLostCta => 'Post lost item';

  @override
  String get postPostFoundCta => 'Post found item';

  @override
  String get mapNearbyTitle => 'Nearby';

  @override
  String mapNearbyCount(int count, int km) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posts within $km km',
      one: '1 post within $km km',
      zero: 'No posts within $km km',
    );
    return '$_temp0';
  }

  @override
  String mapRadius(int km) {
    return '$km km';
  }

  @override
  String get mapNearbyEmpty => 'No posts around here yet. Try a larger radius.';

  @override
  String get repoUnableLogin => 'Unable to login';

  @override
  String get repoUnableLoginGoogle => 'Unable to login with Google';

  @override
  String get repoUnableLogout => 'Unable to logout';

  @override
  String get repoUnableSignUp => 'Unable to sign up';

  @override
  String get repoUnableSendResetCode => 'Unable to send password reset code';

  @override
  String get repoUnableVerifyCode => 'Unable to verify verification code';

  @override
  String get repoUnableResetPassword => 'Unable to reset password';

  @override
  String get repoUnableVerifyEmail => 'Unable to verify email address';

  @override
  String get repoUnableResendCode => 'Unable to resend verification code';

  @override
  String get repoUnableLoadNotifications => 'Unable to load notifications.';

  @override
  String get repoUnableUpdateNotification =>
      'Unable to update the notification.';

  @override
  String get repoUnableUpdateNotifications => 'Unable to update notifications.';

  @override
  String get repoUnableLoadProfile => 'Unable to load your profile.';

  @override
  String get repoUnableUpdateProfile => 'Unable to update your profile.';

  @override
  String get repoUnableLoadPrivacy => 'Unable to load privacy settings.';

  @override
  String get repoUnableUpdatePrivacy => 'Unable to update privacy settings.';

  @override
  String get repoUnableLoadNotifSettings =>
      'Unable to load notification settings.';

  @override
  String get repoUnableUpdateNotifSettings =>
      'Unable to update notification settings.';

  @override
  String get repoUnableLoadBlocked => 'Unable to load blocked users.';

  @override
  String get repoUnableBlock => 'Unable to block this user.';

  @override
  String get repoUnableUnblock => 'Unable to unblock this user.';

  @override
  String get repoUnableSubmitVerification =>
      'Unable to submit your verification.';

  @override
  String get repoUnableLoadVerification =>
      'Unable to load verification status.';

  @override
  String get repoUnableDeleteAccount => 'Unable to delete your account.';

  @override
  String get repoUnableLoadSaved => 'Unable to load saved items.';

  @override
  String get repoUnableUpdateSaved => 'Unable to update saved items.';

  @override
  String get repoLoginToSave => 'Please log in to save items.';

  @override
  String get repoLoginToManageNotifications =>
      'Please log in to manage notifications.';

  @override
  String get repoActionBlockUsers => 'block users';

  @override
  String get repoActionCheckVerification => 'check verification';

  @override
  String get repoActionDeleteAccount => 'delete your account';

  @override
  String get repoActionSubmitVerification => 'submit verification';

  @override
  String get repoActionUpdateBlocked => 'update blocked users';

  @override
  String get repoActionUpdateNotifSettings => 'update notification settings';

  @override
  String get repoActionUpdatePrivacy => 'update privacy settings';

  @override
  String get repoActionUpdateProfile => 'update your profile';

  @override
  String get repoActionViewBlocked => 'view blocked users';

  @override
  String get repoActionViewNotifSettings => 'view notification settings';

  @override
  String get repoActionViewPrivacy => 'view privacy settings';

  @override
  String get repoActionViewProfile => 'view your profile';

  @override
  String repoPleaseLogInTo(String action) {
    return 'Please log in to $action.';
  }

  @override
  String get serverAccountDeleted => 'Account deleted.';

  @override
  String get serverAccountIsAlreadyVerified => 'Account is already verified.';

  @override
  String get serverCouldNotApproveTheRequest =>
      'Could not approve the request.';

  @override
  String get serverCouldNotDeleteTheAccount => 'Could not delete the account.';

  @override
  String get serverCouldNotDeleteThePost => 'Could not delete the post.';

  @override
  String get serverCouldNotRegisterThisDevice =>
      'Could not register this device.';

  @override
  String get serverCouldNotRejectTheRequest => 'Could not reject the request.';

  @override
  String get serverCouldNotResolveTheReport => 'Could not resolve the report.';

  @override
  String get serverCouldNotStoreTheImage => 'Could not store the image.';

  @override
  String get serverCouldNotUpdateTheAccount => 'Could not update the account.';

  @override
  String get serverCouldNotUpdateThePost => 'Could not update the post.';

  @override
  String get serverDatabaseErrorOccurredDuringLogin =>
      'Database error occurred during login.';

  @override
  String get serverDatabaseErrorOccurredDuringRegistration =>
      'Database error occurred during registration.';

  @override
  String get serverDatabaseErrorOccurred => 'Database error occurred.';

  @override
  String get serverDatabaseError => 'Database error.';

  @override
  String get serverEmailAndCodeAreRequired => 'Email and code are required.';

  @override
  String get serverEmailIsAlreadyRegistered => 'Email is already registered.';

  @override
  String get serverEmailVerifiedSuccessfully => 'Email verified successfully.';

  @override
  String get serverErrorBlockingUser => 'Error blocking user.';

  @override
  String get serverErrorCreatingPost => 'Error creating post.';

  @override
  String get serverErrorDeletingAccount => 'Error deleting account.';

  @override
  String get serverErrorDeletingMessage => 'Error deleting message.';

  @override
  String get serverErrorDeletingPost => 'Error deleting post.';

  @override
  String get serverErrorFetchingBlockedUsers => 'Error fetching blocked users.';

  @override
  String get serverErrorFetchingProfile => 'Error fetching profile.';

  @override
  String get serverErrorFetchingUserProfile => 'Error fetching user profile.';

  @override
  String get serverErrorInitiatingConversation =>
      'Error initiating conversation.';

  @override
  String get serverErrorLoadingConversations => 'Error loading conversations.';

  @override
  String get serverErrorLoadingMatches => 'Error loading matches.';

  @override
  String get serverErrorLoadingMessages => 'Error loading messages.';

  @override
  String get serverErrorLoadingNotificationSettings =>
      'Error loading notification settings.';

  @override
  String get serverErrorLoadingNotifications => 'Error loading notifications.';

  @override
  String get serverErrorLoadingPost => 'Error loading post.';

  @override
  String get serverErrorLoadingPosts => 'Error loading posts.';

  @override
  String get serverErrorLoadingPrivacySettings =>
      'Error loading privacy settings.';

  @override
  String get serverErrorLoadingReports => 'Error loading reports.';

  @override
  String get serverErrorLoadingSavedItems => 'Error loading saved items.';

  @override
  String get serverErrorLoadingSimilarPosts => 'Error loading similar posts.';

  @override
  String get serverErrorLoadingStatistics => 'Error loading statistics.';

  @override
  String get serverErrorLoadingTheFile => 'Error loading the file.';

  @override
  String get serverErrorLoadingTheRequest => 'Error loading the request.';

  @override
  String get serverErrorLoadingTheUser => 'Error loading the user.';

  @override
  String get serverErrorLoadingUsers => 'Error loading users.';

  @override
  String get serverErrorLoadingVerificationRequests =>
      'Error loading verification requests.';

  @override
  String get serverErrorLoadingVerificationStatus =>
      'Error loading verification status.';

  @override
  String get serverErrorRemovingSavedPost => 'Error removing saved post.';

  @override
  String get serverErrorSavingPost => 'Error saving post.';

  @override
  String get serverErrorSearchingUsers => 'Error searching users.';

  @override
  String get serverErrorSendingMessage => 'Error sending message.';

  @override
  String get serverErrorSubmittingReport => 'Error submitting report.';

  @override
  String get serverErrorSubmittingVerification =>
      'Error submitting verification.';

  @override
  String get serverErrorUnblockingUser => 'Error unblocking user.';

  @override
  String get serverErrorUpdatingChat => 'Error updating chat.';

  @override
  String get serverErrorUpdatingNotificationSettings =>
      'Error updating notification settings.';

  @override
  String get serverErrorUpdatingNotification => 'Error updating notification.';

  @override
  String get serverErrorUpdatingNotifications =>
      'Error updating notifications.';

  @override
  String get serverErrorUpdatingPost => 'Error updating post.';

  @override
  String get serverErrorUpdatingPrivacySettings =>
      'Error updating privacy settings.';

  @override
  String get serverErrorUpdatingProfile => 'Error updating profile.';

  @override
  String get serverFileNoLongerExists => 'File no longer exists.';

  @override
  String get serverFinderAdministratorsCannotBeBlocked =>
      'Finder administrators cannot be blocked.';

  @override
  String get serverGoogleAuthenticationFailed =>
      'Google authentication failed.';

  @override
  String get serverIfThatAddressIsRegisteredACode =>
      'If that address is registered, a code is on its way.';

  @override
  String get serverIncorrectEmailOrPassword => 'Incorrect email or password.';

  @override
  String get serverIncorrectPassword => 'Incorrect password.';

  @override
  String get serverInvalidOrExpiredToken => 'Invalid or expired token.';

  @override
  String get serverInvalidToken => 'Invalid token.';

  @override
  String get serverInvalidVerificationCode => 'Invalid verification code.';

  @override
  String get serverLocationSearchIsUnavailableRightNowTry =>
      'Location search is unavailable right now. Try again in a moment.';

  @override
  String get serverMessageCannotBeEmpty => 'Message cannot be empty.';

  @override
  String get serverMessageNotFound => 'Message not found.';

  @override
  String get serverNoImageReceived => 'No image received.';

  @override
  String get serverNoVerificationRequest => 'No verification request.';

  @override
  String get serverNotAuthenticated => 'Not authenticated.';

  @override
  String get serverNotAuthorized => 'Not authorized.';

  @override
  String get serverNotFound => 'Not found.';

  @override
  String get serverPasswordHasBeenResetSuccessfully =>
      'Password has been reset successfully.';

  @override
  String get serverPasswordIsRequired => 'Password is required.';

  @override
  String get serverPleaseChooseAnImageUnder8Mb =>
      'Please choose an image under 8 MB.';

  @override
  String get serverPostDeletedSuccessfully => 'Post deleted successfully.';

  @override
  String get serverPostDeleted => 'Post deleted.';

  @override
  String get serverPostNotFound => 'Post not found.';

  @override
  String get serverPostRemovedFromSavedList => 'Post removed from saved list.';

  @override
  String get serverPostSavedSuccessfully => 'Post saved successfully.';

  @override
  String get serverRemoveTheAdminRoleBeforeDeletingThis =>
      'Remove the admin role before deleting this account.';

  @override
  String get serverRemoveTheAdminRoleBeforeSuspendingThis =>
      'Remove the admin role before suspending this account.';

  @override
  String get serverReportNotFound => 'Report not found.';

  @override
  String get serverReportSubmittedSuccessfully =>
      'Report submitted successfully.';

  @override
  String get serverRequestNotFound => 'Request not found.';

  @override
  String get serverThatFileDoesNotLookLikeAn =>
      'That file does not look like an image we can read.';

  @override
  String get serverTheMessageYouAreReplyingToIs =>
      'The message you are replying to is not in this chat.';

  @override
  String get serverThisAccountHasBeenSuspendedContactSupport =>
      'This account has been suspended. Contact support if you think this is a mistake.';

  @override
  String get serverThisUserDoesNotAcceptDirectMessages =>
      'This user does not accept direct messages.';

  @override
  String get serverTooManyLocationLookupsPleaseSlowDown =>
      'Too many location lookups. Please slow down.';

  @override
  String get serverUserBlockedSuccessfully => 'User blocked successfully.';

  @override
  String get serverUserNotFound => 'User not found.';

  @override
  String get serverUserUnblockedSuccessfully => 'User unblocked successfully.';

  @override
  String get serverVerificationCodeHasExpiredPleaseRequestA =>
      'Verification code has expired. Please request a new one.';

  @override
  String get serverVerificationCodeIsValid => 'Verification code is valid.';

  @override
  String get serverVerificationCodeResentSuccessfully =>
      'Verification code resent successfully.';

  @override
  String get serverVerificationCodeSentSuccessfully =>
      'Verification code sent successfully.';

  @override
  String get serverYouAlreadyHaveAVerificationRequestUnder =>
      'You already have a verification request under review.';

  @override
  String get serverYouAlreadyReportedThisPost =>
      'You already reported this post.';

  @override
  String get serverYouAreNotAParticipantInThis =>
      'You are not a participant in this chat.';

  @override
  String get serverYouAreNotAParticipant => 'You are not a participant.';

  @override
  String get serverYouCanOnlyDeleteYourOwnMessages =>
      'You can only delete your own messages.';

  @override
  String get serverYouCannotBlockYourself => 'You cannot block yourself.';

  @override
  String get serverYouCannotDeleteYourOwnAccountHere =>
      'You cannot delete your own account here.';

  @override
  String get serverYouCannotMessageThisUser => 'You cannot message this user.';

  @override
  String get serverYouCannotMessageYourself => 'You cannot message yourself.';

  @override
  String get serverYouCannotRemoveYourOwnAdminRole =>
      'You cannot remove your own admin role.';

  @override
  String get serverYouCannotSuspendYourOwnAccount =>
      'You cannot suspend your own account.';

  @override
  String get serverYouDoNotOwnThisPost => 'You do not own this post.';

  @override
  String get serverYourAccountAndDataHaveBeenDeleted =>
      'Your account and data have been deleted.';

  @override
  String get serverYourIdentityIsAlreadyVerified =>
      'Your identity is already verified.';

  @override
  String get serverThisRequestWasAlreadyHandled =>
      'This request was already handled.';

  @override
  String get serverRequestNotValid => 'The request was not valid.';

  @override
  String get serverSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get serverNotAllowed => 'You are not allowed to do that.';

  @override
  String get serverProblem =>
      'The server ran into a problem. Please try again.';

  @override
  String serverRequestFailed(int status) {
    return 'Request failed ($status).';
  }

  @override
  String get serverTimeout =>
      'The server took too long to respond. Check your connection and try again.';

  @override
  String get serverOffline =>
      'You seem to be offline. Check your connection and try again.';

  @override
  String get serverThisPostIsAwaitingReview => 'This post is awaiting review.';

  @override
  String get serverApproveOrRejectThisPostFirst =>
      'Approve or reject this post first.';

  @override
  String get serverCouldNotApproveThePost => 'Could not approve the post.';

  @override
  String get serverCouldNotRejectThePost => 'Could not reject the post.';

  @override
  String get serverThatStatusIsNotPublic => 'That status is not public.';

  @override
  String get serverNotAnApiKey => 'That does not look like an API key.';

  @override
  String get serverProviderRejectedTheKey => 'The provider rejected the key.';

  @override
  String get serverModelNotFound => 'Model not found.';

  @override
  String get serverModelNameRequired => 'A model name is required.';

  @override
  String get serverBaseUrlRequired =>
      'A base URL and a model name are required for a custom provider.';

  @override
  String get serverCouldNotReachProvider => 'Could not reach the AI provider.';

  @override
  String get serverCouldNotLoadAiSettings => 'Could not load the AI settings.';

  @override
  String get serverCouldNotRemoveAiSettings =>
      'Could not remove the AI settings.';
}
