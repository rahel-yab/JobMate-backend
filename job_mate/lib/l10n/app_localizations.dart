import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// The title of the JobMate application
  ///
  /// In en, this message translates to:
  /// **'JobMate'**
  String get appTitle;

  /// Welcome message shown when the app starts
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m JobMate, your career buddy!'**
  String get welcomeMessage;

  /// Question asking how JobMate can assist the user
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get howCanIHelp;

  /// Button text for CV review feature
  ///
  /// In en, this message translates to:
  /// **'Review my CV'**
  String get cvReview;

  /// Button text for job search feature
  ///
  /// In en, this message translates to:
  /// **'Find jobs'**
  String get findJobs;

  /// Button text for interview practice feature
  ///
  /// In en, this message translates to:
  /// **'Practice interview'**
  String get practiceInterview;

  /// Button text for uploading CV file
  ///
  /// In en, this message translates to:
  /// **'Upload CV'**
  String get uploadCv;

  /// Button text for describing background instead of uploading CV
  ///
  /// In en, this message translates to:
  /// **'Describe your background'**
  String get describeBackground;

  /// Title for CV feedback section
  ///
  /// In en, this message translates to:
  /// **'CV Feedback'**
  String get cvFeedback;

  /// Title for job suggestions section
  ///
  /// In en, this message translates to:
  /// **'Job Suggestions'**
  String get jobSuggestions;

  /// Title for interview questions section
  ///
  /// In en, this message translates to:
  /// **'Interview Questions'**
  String get interviewQuestions;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Greeting message with user name
  ///
  /// In en, this message translates to:
  /// **'Hello {userName}'**
  String hello(String userName);

  /// Introduction text for CV improvement suggestions
  ///
  /// In en, this message translates to:
  /// **'Here are some tips to improve your CV:'**
  String get cvImprovementTips;

  /// Introduction text for job opportunities
  ///
  /// In en, this message translates to:
  /// **'Here are some job opportunities for you:'**
  String get jobOpportunities;

  /// Introduction text for interview practice mode
  ///
  /// In en, this message translates to:
  /// **'Let\'s practice some interview questions!'**
  String get interviewPracticeMode;

  /// Welcome back message for returning users
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Question asking what the user wants to do
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// Title for CV analysis feature
  ///
  /// In en, this message translates to:
  /// **'CV Analysis'**
  String get cvAnalysis;

  /// Description for CV analysis feature
  ///
  /// In en, this message translates to:
  /// **'Get feedback on your resume'**
  String get getFeedbackOnResume;

  /// Job search feature title
  ///
  /// In en, this message translates to:
  /// **'Job Search'**
  String get jobSearch;

  /// Job search feature description
  ///
  /// In en, this message translates to:
  /// **'Find perfect job matches'**
  String get findPerfectJobMatches;

  /// Interview preparation feature title
  ///
  /// In en, this message translates to:
  /// **'Interview Prep'**
  String get interviewPrep;

  /// Interview preparation feature description
  ///
  /// In en, this message translates to:
  /// **'Practice with mock interviews'**
  String get practiceWithMockInterviews;

  /// Skill boost feature title
  ///
  /// In en, this message translates to:
  /// **'Skill Boost'**
  String get skillBoost;

  /// Skill boost feature description
  ///
  /// In en, this message translates to:
  /// **'Get personalized learning plan'**
  String get getPersonalizedLearningPlan;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Your AI Career Buddy'**
  String get yourAiCareerBuddy;

  /// Sign in prompt message
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your career journey'**
  String get signInToContinue;

  /// Question for users without account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Link to sign up page
  ///
  /// In en, this message translates to:
  /// **'Sign up here'**
  String get signUpHere;

  /// Welcome message for new users
  ///
  /// In en, this message translates to:
  /// **'Welcome to JobMate'**
  String get welcomeToJobmate;

  /// Sign up prompt message
  ///
  /// In en, this message translates to:
  /// **'Create your account to start your career journey'**
  String get createAccountToStart;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Request OTP button text
  ///
  /// In en, this message translates to:
  /// **'Request OTP'**
  String get requestOtp;

  /// OTP field label
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// Question for existing users
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Link to sign in page
  ///
  /// In en, this message translates to:
  /// **'Sign in here'**
  String get signInHere;

  /// CV analysis help message
  ///
  /// In en, this message translates to:
  /// **'I would be happy to help you with your CV.\nYou can upload your current CV or describe your background below.'**
  String get cvHelpMessage;

  /// CV tab label
  ///
  /// In en, this message translates to:
  /// **'CV'**
  String get cvTab;

  /// Jobs tab label
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobsTab;

  /// Interview tab label
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get interviewTab;

  /// Skills tab label
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skillsTab;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'This section is coming soon'**
  String get comingSoon;

  /// Authentication error message
  ///
  /// In en, this message translates to:
  /// **'User not authenticated. Please log in.'**
  String get userNotAuthenticated;

  /// Splash screen tagline
  ///
  /// In en, this message translates to:
  /// **'Your AI Career Companion!'**
  String get yourAiCareerCompanion;

  /// AI powered feature description
  ///
  /// In en, this message translates to:
  /// **'AI powered'**
  String get aiPowered;

  /// Career focus feature description
  ///
  /// In en, this message translates to:
  /// **'Career Focus'**
  String get careerFocus;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email first'**
  String get pleaseEnterEmailFirst;

  /// Smart insights feature description
  ///
  /// In en, this message translates to:
  /// **'Smart Insights'**
  String get smartInsights;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Email address field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Email field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Password field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Sign up link text
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// First name field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterYourFirstName;

  /// Last name field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterYourLastName;

  /// Password creation hint text
  ///
  /// In en, this message translates to:
  /// **'Create a password (min 8 chars, e.g., Tsige@123)'**
  String get createPassword;

  /// Confirm password field hint text
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// OTP field label
  ///
  /// In en, this message translates to:
  /// **'One Time Password'**
  String get oneTimePassword;

  /// OTP field hint text
  ///
  /// In en, this message translates to:
  /// **'#OTP Code'**
  String get otpCode;

  /// Send OTP button text
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Password minimum length validation message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// Password uppercase validation message
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter'**
  String get passwordUppercase;

  /// Password number validation message
  ///
  /// In en, this message translates to:
  /// **'Password must contain a number'**
  String get passwordNumber;

  /// Password special character validation message
  ///
  /// In en, this message translates to:
  /// **'Password must contain a special character'**
  String get passwordSpecialChar;

  /// Password mismatch validation message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Server error message for registration
  ///
  /// In en, this message translates to:
  /// **'Registration failed: Server error. Please try again later.'**
  String get registrationFailedServer;

  /// Invalid data error message for registration
  ///
  /// In en, this message translates to:
  /// **'Registration failed: Invalid email, password, or OTP.'**
  String get registrationFailedInvalid;

  /// Unexpected error message for registration
  ///
  /// In en, this message translates to:
  /// **'Registration failed: An unexpected error occurred.'**
  String get registrationFailedUnexpected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
