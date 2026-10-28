import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Supported application locales
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ml'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isMalayalam => locale.languageCode == 'ml';

  // --- App General ---
  String get appTitle => isMalayalam ? 'അഗ്രി-കീ' : 'Agry-Key';
  String get appSubtitle => isMalayalam
      ? 'സ്മാർട്ട് കാർഷിക സഹായി'
      : 'Smart Agriculture Companion';
  String get aiAssistantName => isMalayalam ? 'അഗ്രി-കീ AI' : 'Agry-Key AI';

  // --- Navigation & Core Sections ---
  String get navHome => isMalayalam ? 'ഡാഷ്‌ബോർഡ്' : 'Dashboard';
  String get navMarket => isMalayalam ? 'മാർക്കറ്റ്' : 'Market';
  String get navSchemes => isMalayalam ? 'പദ്ധതികൾ' : 'Schemes';
  String get navCommunity => isMalayalam ? 'കൂട്ടായ്മ' : 'Community';
  String get navWeather => isMalayalam ? 'കാലാവസ്ഥ' : 'Weather';
  String get navAlerts => isMalayalam ? 'അറിയിപ്പുകൾ' : 'Alerts';
  String get navCropPlanner =>
      isMalayalam ? 'വിള വരുമാന പ്ലാനർ' : 'Crop Income Planner';
  String get navSettings => isMalayalam ? 'ക്രമീകരണങ്ങൾ' : 'Settings';
  String get navProfile => isMalayalam ? 'പ്രൊഫൈൽ' : 'Profile';
  String get navBack => isMalayalam ? 'പിന്നോട്ട്' : 'Back';

  // --- Actions ---
  String get actionSearch => isMalayalam ? 'തിരയുക...' : 'Search...';
  String get actionFilter => isMalayalam ? 'ഫിൽട്ടർ' : 'Filter';
  String get actionRefresh => isMalayalam ? 'പുതുക്കുക' : 'Refresh';
  String get actionSave => isMalayalam ? 'സംരക്ഷിക്കുക' : 'Save';
  String get actionCancel => isMalayalam ? 'റദ്ദാക്കുക' : 'Cancel';
  String get actionConfirm => isMalayalam ? 'സ്ഥിരീകരിക്കുക' : 'Confirm';
  String get actionClose => isMalayalam ? 'അടയ്ക്കുക' : 'Close';
  String get actionViewDetails =>
      isMalayalam ? 'വിശദാംശങ്ങൾ കാണുക' : 'View Details';
  String get actionApply => isMalayalam ? 'അപേക്ഷിക്കുക' : 'Apply';
  String get actionPost => isMalayalam ? 'പങ്കുവെക്കുക' : 'Post';
  String get actionCalculate => isMalayalam ? 'കണക്കാക്കുക' : 'Calculate';
  String get actionRetry => isMalayalam ? 'വീണ്ടും ശ്രമിക്കുക' : 'Retry';
  String get actionOpenOfficialPortal =>
      isMalayalam ? 'ഔദ്യോഗിക പോർട്ടൽ സന്ദർശിക്കുക' : 'Visit Official Portal';

  // --- Market & Mandi ---
  String get marketTitle => isMalayalam ? 'വിപണി നിരക്കുകൾ' : 'Market Prices';
  String get marketSubtitle => isMalayalam
      ? 'ഔദ്യോഗിക അഗ്മാർക്ക്നെറ്റ് (Agmarknet) ഡാറ്റ'
      : 'Official Agmarknet Mandi Rates';
  String get marketSearchHint => isMalayalam
      ? 'വിളയോ ചന്തയോ തിരയുക...'
      : 'Search commodity or mandi...';
  String get marketCommodity => isMalayalam ? 'വിള' : 'Commodity';
  String get marketMandi => isMalayalam ? 'വിപണി / ചന്ത' : 'Market / Mandi';
  String get marketDistrict => isMalayalam ? 'ജില്ല' : 'District';
  String get marketModalPrice => isMalayalam ? 'ശരാശരി വില' : 'Modal Price';
  String get marketMinPrice => isMalayalam ? 'കുറഞ്ഞ വില' : 'Min Price';
  String get marketMaxPrice => isMalayalam ? 'കൂടിയ വില' : 'Max Price';
  String get marketPriceUnit => isMalayalam ? 'ക്വിന്റലിന്' : 'per quintal';
  String get marketPriceUnavailable => isMalayalam
      ? 'ഈ ജില്ലയിൽ ഈ വിളയ്ക്ക് നിലവിലെ വിപണി വില ലഭ്യമല്ല'
      : 'No market price available for this commodity in this district';
  String get marketSourceLabel =>
      isMalayalam ? 'ഉറവിടം: അഗ്മാർക്ക്നെറ്റ്' : 'Source: Agmarknet';
  String get marketplaceTitle => isMalayalam ? 'ചന്തസ്ഥലം' : 'Marketplace';
  String get marketplaceBuyProduce =>
      isMalayalam ? 'വിളകൾ വാങ്ങുക' : 'Buy Produce';
  String get marketplaceSellProduce =>
      isMalayalam ? 'വിളകൾ വിൽക്കുക' : 'Sell Produce';

  // --- Government Schemes ---
  String get schemesTitle =>
      isMalayalam ? 'സർക്കാർ പദ്ധതികൾ' : 'Government Schemes';
  String get schemesSubtitle => isMalayalam
      ? 'കേന്ദ്ര - സംസ്ഥാന കർഷക ക്ഷേമ പദ്ധതികൾ'
      : 'Central & State Farmer Welfare Schemes';
  String get schemesSearchHint => isMalayalam
      ? 'പദ്ധതിയുടെ പേര് തിരയുക...'
      : 'Search scheme name or code...';
  String get schemesCentral => isMalayalam ? 'കേന്ദ്ര പദ്ധതി' : 'Central Scheme';
  String get schemesState => isMalayalam ? 'സംസ്ഥാന പദ്ധതി' : 'State Scheme';
  String get schemesEligibility =>
      isMalayalam ? 'അർഹത മാനദണ്ഡങ്ങൾ' : 'Eligibility Criteria';
  String get schemesBenefits =>
      isMalayalam ? 'ലഭിക്കുന്ന ആനുകൂല്യങ്ങൾ' : 'Benefits';
  String get schemesApplicationProcess =>
      isMalayalam ? 'അപേക്ഷിക്കേണ്ട വിധം' : 'Application Process';
  String get schemesDocuments =>
      isMalayalam ? 'ആവശ്യമായ രേഖകൾ' : 'Required Documents';
  String get schemesVerifiedBadge =>
      isMalayalam ? 'പരിശോധിച്ച് ഉറപ്പാക്കിയത്' : 'Verified by Official Portal';
  String get schemesUnverifiedBadge => isMalayalam
      ? 'പരിശോധന പുരോഗമിക്കുന്നു'
      : 'Pending Official Verification';
  String get schemesLastChecked =>
      isMalayalam ? 'അവസാനം പരിശോധിച്ചത്' : 'Last Checked';
  String get schemesTranslationUnavailableNote => isMalayalam
      ? 'കുറിപ്പ്: ഈ പദ്ധതിയുടെ മലയാള പരിഭാഷ നിലവിൽ ലഭ്യമല്ല. ഔദ്യോഗിക വിവരങ്ങൾ ഇംഗ്ലീഷിൽ നൽകിയിരിക്കുന്നു.'
      : 'Note: Full local translation is in review. Official verified details shown in English.';

  // --- Community ---
  String get communityTitle => isMalayalam ? 'കർഷക കൂട്ടായ്മ' : 'Farmer Community';
  String get communitySubtitle => isMalayalam
      ? 'അറിവുകളും അനുഭവങ്ങളും പരസ്പരം പങ്കുവെക്കാം'
      : 'Share knowledge, ask advice, and connect';
  String get communityAskQuestion =>
      isMalayalam ? 'ചോദ്യങ്ങൾ ചോദിക്കുക' : 'Ask a Question';
  String get communityQuestionHint => isMalayalam
      ? 'നിങ്ങളുടെ കാർഷിക സംശയങ്ങൾ ഇവിടെ എഴുതുക...'
      : 'Describe your farming question or observation...';
  String get communityComments => isMalayalam ? 'അഭിപ്രായങ്ങൾ' : 'Comments';
  String get communityAddComment =>
      isMalayalam ? 'അഭിപ്രായം രേഖപ്പെടുത്തുക...' : 'Write a comment...';
  String get communityNoPosts => isMalayalam
      ? 'പോസ്റ്റുകളൊന്നും കണ്ടെത്തിയില്ല. ആദ്യമായി ഒരു ചോദ്യം ചോദിക്കൂ!'
      : 'No community discussions found. Be the first to start a conversation!';
  String get communityOriginalPost =>
      isMalayalam ? 'യഥാർത്ഥ പോസ്റ്റ്' : 'Original Post';
  String get communityAuthorUnknown =>
      isMalayalam ? 'അജ്ഞാത കർഷകൻ' : 'Unknown User';

  // --- Weather & Alerts ---
  String get weatherTitle =>
      isMalayalam ? 'കാലാവസ്ഥ പ്രവചനം' : 'Weather Forecast';
  String get weatherModelDisclaimer => isMalayalam
      ? 'ഓപ്പൺ-മെറ്റിയോ (Open-Meteo) കാലാവസ്ഥ മോഡൽ പ്രവചനം. നേരിട്ടുള്ള ഫീൽഡ് സെൻസർ നിരീക്ഷണമല്ല.'
      : 'Open-Meteo gridded forecast model. Not a direct on-field ground observation.';
  String get weatherTemp => isMalayalam ? 'താപനില' : 'Temperature';
  String get weatherHumidity => isMalayalam ? 'ഈർപ്പം' : 'Humidity';
  String get weatherWind => isMalayalam ? 'കാറ്റിന്റെ വേഗത' : 'Wind Speed';
  String get weatherPrecipitation => isMalayalam ? 'മഴ സാധ്യത' : 'Precipitation';
  String get weatherCondition => isMalayalam ? 'സ്ഥിതി' : 'Condition';
  String get weatherUnavailable => isMalayalam
      ? 'കാലാവസ്ഥാ വിവരങ്ങൾ നിലവിൽ ലഭ്യമല്ല'
      : 'Weather data currently unavailable';
  String get alertsTitle => isMalayalam ? 'കാലാവസ്ഥാ മുന്നറിയിപ്പുകൾ' : 'Weather Alerts';
  String get alertsNoActive => isMalayalam
      ? 'നിലവിൽ കാലാവസ്ഥാ മുന്നറിയിപ്പുകളൊന്നുമില്ല'
      : 'No active severe weather alerts for your district';

  // --- Crop Income Planner (renamed from Profit Maximizer) ---
  String get cropPlannerTitle =>
      isMalayalam ? 'വിള വരുമാന പ്ലാനർ' : 'Crop Income Planner';
  String get cropPlannerSubtitle => isMalayalam
      ? 'വിസ്തൃതിയും വിളവും അടിസ്ഥാനമാക്കിയുള്ള ചെലവ്-വരവ് കണക്കുകൂട്ടൽ'
      : 'Transparent cost-income calculation from identified inputs';
  String get cropPlannerAcreage =>
      isMalayalam ? 'കൃഷിഭൂമി (ഏക്കർ)' : 'Farmland (Acres)';
  String get cropPlannerAcreageHint =>
      isMalayalam ? 'ഏക്കർ രേഖപ്പെടുത്തുക' : 'Enter acres';
  String get cropPlannerExpectedYield =>
      isMalayalam ? 'പ്രതീക്ഷിക്കുന്ന വിളവ് (ക്വിന്റൽ)' : 'Expected Yield (Quintals)';
  String get cropPlannerEstimatedIncome =>
      isMalayalam ? 'പ്രതീക്ഷിത വരുമാനം' : 'Estimated Gross Income';
  String get cropPlannerEstimatedCost =>
      isMalayalam ? 'പ്രതീക്ഷിത ചെലവ്' : 'Estimated Total Cost';
  String get cropPlannerNetMargin =>
      isMalayalam ? 'പ്രതീക്ഷിത അറ്റാദായം' : 'Estimated Net Margin';
  String get cropPlannerInputsRequired => isMalayalam
      ? 'കണക്കുകൂട്ടാൻ ഭൂമിയുടെ വിസ്തൃതിയും കൃഷി വിവരങ്ങളും നൽകുക.'
      : 'Farmer-entered acreage and crop information required.';
  String get cropPlannerFormulaExplanation => isMalayalam
      ? 'സൂത്രവാക്യം: വരുമാനം = വിളവ് × വിപണി വില; അറ്റാദായം = വരുമാനം - കൃഷി ചെലവ്.'
      : 'Formula: Gross = Yield × Mandi Price; Net = Gross - Production Cost.';

  // --- Voice Controls & States ---
  String get voiceInteractionTitle =>
      isMalayalam ? 'ശബ്ദ സഹായി' : 'Voice Assistant';
  String get voiceStateIdle =>
      isMalayalam ? 'സംസാരിക്കാൻ അമർത്തുക' : 'Push to talk';
  String get voiceStateListening =>
      isMalayalam ? 'കേൾക്കുന്നു... കമാൻഡ് പറയൂ' : 'Listening... speak a command';
  String get voiceStateProcessing =>
      isMalayalam ? 'പരിശോധിക്കുന്നു...' : 'Processing command...';
  String get voiceStateSpeaking =>
      isMalayalam ? 'മറുപടി നൽകുന്നു...' : 'Speaking reply...';
  String get voiceStateClarifying => isMalayalam
      ? 'വ്യക്തത ആവശ്യമാണ്... വീണ്ടും പറയൂ'
      : 'Awaiting clarification... please repeat';
  String get voiceStateFailed => isMalayalam
      ? 'കമാൻഡ് മനസ്സിലായില്ല. വീണ്ടും ശ്രമിക്കൂ.'
      : 'Command not recognized. Please try again.';
  String get voiceMicPermissionTitle =>
      isMalayalam ? 'മൈക്രോഫോൺ അനുമതി' : 'Microphone Permission';
  String get voiceMicPermissionBody => isMalayalam
      ? 'ശബ്ദത്തിലൂടെ നാവിഗേറ്റ് ചെയ്യാൻ മൈക്രോഫോൺ അനുമതി ആവശ്യമാണ്.'
      : 'Microphone permission is required for voice navigation.';
  String get voiceMicPermissionGrant =>
      isMalayalam ? 'അനുമതി നൽകുക' : 'Grant Permission';
  String get voiceActionStop => isMalayalam ? 'നിർത്തുക' : 'Stop Speaking';
  String get voiceActionRepeat => isMalayalam ? 'വീണ്ടും പറയുക' : 'Repeat';
  String get voiceActionChangeLanguage =>
      isMalayalam ? 'ഭാഷ മാറ്റുക' : 'Change Language';
  String get voiceCommandUnderstood =>
      isMalayalam ? 'തുറക്കുന്നു...' : 'Opening...';

  // --- First-Run Language Selection & Location Prompt ---
  String get langPromptTitle =>
      isMalayalam ? 'ഭാഷ തിരഞ്ഞെടുക്കുക' : 'Choose Your Language';
  String get langPromptLocationRationale => isMalayalam
      ? 'നിങ്ങളുടെ കൃഷിസ്ഥലത്തിന് അനുയോജ്യമായ വിപണി നിരക്കുകളും പ്രാദേശിക ഭാഷയും നിർദ്ദേശിക്കാൻ ലൊക്കേഷൻ അനുമതി ചോദിക്കുന്നു.'
      : 'We request location to suggest regional market prices, weather advisories, and language preferences.';
  String get langPromptSuggestionHeader => isMalayalam
      ? 'മലയാളത്തിലേക്ക് മാറ്റണോ?'
      : 'Switch to Malayalam?';
  String get langPromptSuggestionBody => isMalayalam
      ? 'നിങ്ങൾ കേരളത്തിലാണെന്ന് കാണുന്നു. അഗ്രി-കീ മലയാളത്തിൽ ഉപയോഗിക്കാൻ താല്പര്യമുണ്ടോ?'
      : 'We noticed your farm location is in Kerala. Would you like to use Agry-Key in Malayalam?';
  String get langPromptSwitchMalayalam =>
      isMalayalam ? 'അതെ, മലയാളം' : 'Switch to Malayalam';
  String get langPromptKeepEnglish =>
      isMalayalam ? 'ഇംഗ്ലീഷിൽ തുടരുക' : 'Keep English';
  String get langPromptChooseOther =>
      isMalayalam ? 'മറ്റൊരു ഭാഷ' : 'Choose another language';
  String get langExplicitChoiceSaved => isMalayalam
      ? 'ഭാഷ മലയാളമായി തിരഞ്ഞെടുത്തു'
      : 'English language preference saved';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ml'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

