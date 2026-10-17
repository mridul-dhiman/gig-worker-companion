enum AppLang {
  en('English', 'English', 'Hello'),
  hi('हिंदी', 'Hindi (हिंदी)', 'नमस्ते'),
  pa('ਪੰਜਾਬੀ', 'Punjabi (ਪੰਜਾਬੀ)', 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ'),
  hl('Hinglish', 'Hinglish', 'Kaise ho');

  const AppLang(this.native, this.promptName, this.sample);

  /// Name shown in the language picker, in its own script.
  final String native;

  /// Name injected into the Gemini systemInstruction.
  final String promptName;
  final String sample;
}

/// Looks up [key] for [lang], filling `{name}` placeholders from [vars].
String tr(AppLang lang, String key, [Map<String, Object> vars = const {}]) {
  final row = _strings[key];
  var s = row?[lang.index] ?? row?[0] ?? key;
  vars.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
  return s;
}

List<String> tabNames(AppLang l) => [
      tr(l, 'tabEarn'),
      tr(l, 'tabComplaint'),
      tr(l, 'tabSchemes'),
      tr(l, 'tabPapers'),
      tr(l, 'tabSafety'),
    ];

// Each row: [English, Hindi, Punjabi, Hinglish]
const Map<String, List<String>> _strings = {
  'tabEarn': ['Earnings', 'कमाई', 'ਕਮਾਈ', 'Kamai'],
  'tabComplaint': ['Complaint', 'शिकायत', 'ਸ਼ਿਕਾਇਤ', 'Shikayat'],
  'tabSchemes': ['Schemes', 'योजनाएँ', 'ਸਕੀਮਾਂ', 'Yojana'],
  'tabPapers': ['Papers', 'कागज़', 'ਕਾਗਜ਼', 'Kagaz'],
  'tabSafety': ['Safety', 'सुरक्षा', 'ਸੁਰੱਖਿਆ', 'Suraksha'],
  'hi': ['Namaste', 'नमस्ते', 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ', 'Namaste'],

  // Earnings
  'tellDay': ['Tell Saathi about your day', 'आज का हाल बताइए', 'ਅੱਜ ਦਾ ਹਾਲ ਦੱਸੋ', 'Aaj ka haal batao'],
  'calc': ['Work out my take-home', 'मेरी असली कमाई निकालें', 'ਮੇਰੀ ਅਸਲ ਕਮਾਈ ਕੱਢੋ', 'Meri asli kamai nikalo'],
  'todayNet': ["Today's take-home", 'आज हाथ में आया', 'ਅੱਜ ਹੱਥ ਵਿੱਚ ਆਇਆ', 'Aaj haath mein aaya'],
  'exp': ['Spent on work', 'काम का खर्च', 'ਕੰਮ ਦਾ ਖ਼ਰਚਾ', 'Kaam ka kharcha'],
  'ded': ['Cut by platform / boss', 'कंपनी / मालिक की कटौती', 'ਕੰਪਨੀ / ਮਾਲਕ ਦੀ ਕਟੌਤੀ', 'Company / malik ki katauti'],
  'unfair': ['This cut looks unfair', 'यह कटौती गलत लगती है', 'ਇਹ ਕਟੌਤੀ ਗ਼ਲਤ ਲੱਗਦੀ ਹੈ', 'Yeh katauti galat lagti hai'],
  'contest': ['Contest {x} deduction', '{x} कटौती पर शिकायत करें', "{x} ਕਟੌਤੀ 'ਤੇ ਸ਼ਿਕਾਇਤ ਕਰੋ", '{x} katauti pe shikayat karo'],
  'contestSub': ['Opens Complaint with the details filled in', 'शिकायत पेज पर सब भर जाएगा', "ਸ਼ਿਕਾਇਤ ਪੰਨੇ 'ਤੇ ਸਭ ਭਰਿਆ ਜਾਵੇਗਾ", 'Shikayat page pe sab bhar jayega'],
  'schemes': ['Check welfare schemes for me', 'मेरे लिए सरकारी योजनाएँ देखें', 'ਮੇਰੇ ਲਈ ਸਰਕਾਰੀ ਸਕੀਮਾਂ ਵੇਖੋ', 'Mere liye sarkari yojana dekho'],
  'schemesSub': ['Uses about {x} a month', 'महीने की कमाई लगभग {x}', 'ਮਹੀਨੇ ਦੀ ਕਮਾਈ ਲਗਭਗ {x}', 'Mahine ki kamai lagbhag {x}'],
  'week': ['Last 7 days', 'पिछले 7 दिन', 'ਪਿਛਲੇ 7 ਦਿਨ', 'Pichhle 7 din'],
  'weekEmpty': ['Days you calculate are saved here.', 'जिन दिनों का हिसाब लगाएँगे, वे यहाँ दिखेंगे।', 'ਜਿਨ੍ਹਾਂ ਦਿਨਾਂ ਦਾ ਹਿਸਾਬ ਲਾਓਗੇ, ਉਹ ਇੱਥੇ ਦਿਖਣਗੇ।', 'Jin dino ka hisaab lagaoge, woh yahan dikhenge.'],
  'fromNote': ['From your note', 'आपके नोट से', 'ਤੁਹਾਡੇ ਨੋਟ ਤੋਂ', 'Aapke note se'],
  'cashLine': ['Cash', 'नकद', 'ਨਕਦ', 'Cash'],
  'smsLine': ['From SMS', 'SMS से', 'SMS ਤੋਂ', 'SMS se'],
  'takehome': ['Take-home', 'असली कमाई', 'ਅਸਲ ਕਮਾਈ', 'Asli kamai'],

  // Cash
  'cashT': ['Cash in hand', 'हाथ में नकद', 'ਹੱਥ ਵਿੱਚ ਨਕਦ', 'Haath mein cash'],
  'cashSub': ['Money you got or spent in cash today', 'आज नकद में मिले या खर्च हुए पैसे', 'ਅੱਜ ਨਕਦ ਵਿੱਚ ਮਿਲੇ ਜਾਂ ਖ਼ਰਚੇ ਪੈਸੇ', 'Aaj cash mein mile ya kharch hue paise'],
  'got': ['I got', 'मुझे मिले', 'ਮੈਨੂੰ ਮਿਲੇ', 'Mujhe mile'],
  'spent': ['I spent', 'मैंने खर्च किए', 'ਮੈਂ ਖ਼ਰਚੇ', 'Maine kharch kiye'],
  'amount': ['Amount in ₹', 'रकम ₹ में', 'ਰਕਮ ₹ ਵਿੱਚ', 'Rakam ₹ mein'],
  'add': ['Add', 'जोड़ें', 'ਜੋੜੋ', 'Jodo'],
  'codNote': ['Cash collected for orders (COD) goes back to the platform. Do not add it here.', 'ऑर्डर के लिए लिया नकद (COD) कंपनी को वापस जाता है। उसे यहाँ न जोड़ें।', 'ਆਰਡਰ ਲਈ ਲਿਆ ਨਕਦ (COD) ਕੰਪਨੀ ਨੂੰ ਵਾਪਸ ਜਾਂਦਾ ਹੈ। ਉਸਨੂੰ ਇੱਥੇ ਨਾ ਜੋੜੋ।', 'Order ke liye liya cash (COD) company ko wapas jaata hai. Use yahan mat jodo.'],
  'remove': ['Remove', 'हटाएँ', 'ਹਟਾਓ', 'Hatao'],

  // SMS
  'smsT': ['Payments from your SMS', 'आपके SMS से भुगतान', 'ਤੁਹਾਡੇ SMS ਤੋਂ ਭੁਗਤਾਨ', 'Aapke SMS se payment'],
  'smsWeb': ['Paste a bank or UPI SMS. Saathi reads the amount and checks it against your day. In the Android app this happens automatically.', 'बैंक या UPI का SMS चिपकाएँ। साथी रकम पढ़कर आपके दिन से मिलाएगा। Android ऐप में यह अपने आप होता है।', 'ਬੈਂਕ ਜਾਂ UPI ਦਾ SMS ਪੇਸਟ ਕਰੋ। ਸਾਥੀ ਰਕਮ ਪੜ੍ਹ ਕੇ ਤੁਹਾਡੇ ਦਿਨ ਨਾਲ ਮਿਲਾਏਗਾ। Android ਐਪ ਵਿੱਚ ਇਹ ਆਪਣੇ ਆਪ ਹੁੰਦਾ ਹੈ।', 'Bank ya UPI SMS paste karo. Saathi amount padh ke aapke din se milayega. Android app mein yeh apne aap hota hai.'],
  'smsRead': ['Read this SMS', 'यह SMS पढ़ें', 'ਇਹ SMS ਪੜ੍ਹੋ', 'Yeh SMS padho'],
  'smsSample': ['Try sample SMS', 'नमूना SMS आज़माएँ', 'ਨਮੂਨਾ SMS ਅਜ਼ਮਾਓ', 'Sample SMS try karo'],
  'smsNone': ['No amount found in this message. Paste the full bank SMS.', 'इस मैसेज में कोई रकम नहीं मिली। पूरा बैंक SMS चिपकाएँ।', 'ਇਸ ਮੈਸੇਜ ਵਿੱਚ ਕੋਈ ਰਕਮ ਨਹੀਂ ਮਿਲੀ। ਪੂਰਾ ਬੈਂਕ SMS ਪੇਸਟ ਕਰੋ।', 'Is message mein koi amount nahi mila. Poora bank SMS paste karo.'],
  'smsPrivacy': ['SMS text is read on this device only.', 'SMS सिर्फ़ इसी डिवाइस पर पढ़ा जाता है।', 'SMS ਸਿਰਫ਼ ਇਸੇ ਡਿਵਾਈਸ \'ਤੇ ਪੜ੍ਹਿਆ ਜਾਂਦਾ ਹੈ।', 'SMS sirf isi device pe padha jaata hai.'],
  'dup': ['Already in your note', 'नोट में पहले से है', 'ਨੋਟ ਵਿੱਚ ਪਹਿਲਾਂ ਹੀ ਹੈ', 'Note mein pehle se hai'],
  'ignore': ['Ignore', 'छोड़ें', 'ਛੱਡੋ', 'Chhodo'],
  'added': ['Added', 'जोड़ दिया', 'ਜੋੜ ਦਿੱਤਾ', 'Jod diya'],
  'ignored': ['Ignored', 'छोड़ दिया', 'ਛੱਡ ਦਿੱਤਾ', 'Chhod diya'],
  'disputeIt': ['Dispute {x}', '{x} पर शिकायत करें', "{x} 'ਤੇ ਸ਼ਿਕਾਇਤ ਕਰੋ", '{x} pe shikayat karo'],
  'payout': ['Payout. Not added to today.', 'भुगतान। आज में नहीं जोड़ा।', 'ਭੁਗਤਾਨ। ਅੱਜ ਵਿੱਚ ਨਹੀਂ ਜੋੜਿਆ।', 'Payout. Aaj mein nahi joda.'],
  'personal': ['Looks personal, not work', 'निजी खर्च लगता है, काम का नहीं', 'ਨਿੱਜੀ ਖ਼ਰਚਾ ਲੱਗਦਾ ਹੈ, ਕੰਮ ਦਾ ਨਹੀਂ', 'Personal kharcha lagta hai, kaam ka nahi'],

  // Complaint
  'whatHappened': ['What happened?', 'क्या हुआ?', 'ਕੀ ਹੋਇਆ?', 'Kya hua?'],
  'sendTo': ['Send it to', 'किसे भेजें', 'ਕਿਸਨੂੰ ਭੇਜਣਾ', 'Kisko bhejna hai'],
  'draft': ['Write my complaint', 'मेरी शिकायत लिखिए', 'ਮੇਰੀ ਸ਼ਿਕਾਇਤ ਲਿਖੋ', 'Meri shikayat likho'],
  'simple': ['In simple words', 'आसान भाषा में', 'ਸੌਖੀ ਭਾਸ਼ਾ ਵਿੱਚ', 'Simple shabdon mein'],
  'formal': ['Ready-to-send complaint', 'भेजने के लिए तैयार शिकायत', 'ਭੇਜਣ ਲਈ ਤਿਆਰ ਸ਼ਿਕਾਇਤ', 'Bhejne ke liye taiyaar shikayat'],
  'copy': ['Copy', 'कॉपी', 'ਕਾਪੀ', 'Copy'],
  'copied': ['Copied. Paste it in the app chat or email.', 'कॉपी हो गया। ऐप चैट या ईमेल में चिपकाएँ।', 'ਕਾਪੀ ਹੋ ਗਿਆ। ਐਪ ਚੈਟ ਜਾਂ ਈਮੇਲ ਵਿੱਚ ਪੇਸਟ ਕਰੋ।', 'Copy ho gaya. App chat ya email mein paste karo.'],
  'recPlatform': ['Platform support', 'कंपनी सपोर्ट', 'ਕੰਪਨੀ ਸਪੋਰਟ', 'Platform support'],
  'recContractor': ['Contractor', 'ठेकेदार', 'ਠੇਕੇਦਾਰ', 'Thekedaar'],
  'recLabour': ['Labour officer', 'श्रम अधिकारी', 'ਲੇਬਰ ਅਫ਼ਸਰ', 'Labour officer'],
  'recCourt': ['Traffic court', 'ट्रैफ़िक कोर्ट', 'ਟ੍ਰੈਫ਼ਿਕ ਕੋਰਟ', 'Traffic court'],
  'proofT': ['Proof', 'सबूत', 'ਸਬੂਤ', 'Saboot'],
  'proofSub': ['A photo or screenshot makes your complaint much stronger.', 'फ़ोटो या स्क्रीनशॉट से आपकी शिकायत मज़बूत होती है।', 'ਫ਼ੋਟੋ ਜਾਂ ਸਕ੍ਰੀਨਸ਼ਾਟ ਨਾਲ ਤੁਹਾਡੀ ਸ਼ਿਕਾਇਤ ਮਜ਼ਬੂਤ ਹੁੰਦੀ ਹੈ।', 'Photo ya screenshot se shikayat mazboot hoti hai.'],
  'scan': ['Take a photo', 'फ़ोटो लें', 'ਫ਼ੋਟੋ ਲਓ', 'Photo lo'],
  'upload': ['Upload screenshot', 'स्क्रीनशॉट डालें', 'ਸਕ੍ਰੀਨਸ਼ਾਟ ਪਾਓ', 'Screenshot daalo'],
  'proofSample': ['No screenshot? Try a sample', 'स्क्रीनशॉट नहीं? नमूना आज़माएँ', 'ਸਕ੍ਰੀਨਸ਼ਾਟ ਨਹੀਂ? ਨਮੂਨਾ ਅਜ਼ਮਾਓ', 'Screenshot nahi? Sample try karo'],
  'readT': ['Saathi read this from your picture', 'साथी ने आपकी फ़ोटो से यह पढ़ा', 'ਸਾਥੀ ਨੇ ਤੁਹਾਡੀ ਫ਼ੋਟੋ ਤੋਂ ਇਹ ਪੜ੍ਹਿਆ', 'Saathi ne aapki photo se yeh padha'],
  'proofFail': ["Saathi could not read this picture right now. It is still attached. Add the key details in the box above.", 'साथी अभी यह फ़ोटो नहीं पढ़ पाया। फ़ोटो जुड़ी हुई है। ज़रूरी बातें ऊपर लिख दें।', 'ਸਾਥੀ ਹੁਣੇ ਇਹ ਫ਼ੋਟੋ ਨਹੀਂ ਪੜ੍ਹ ਸਕਿਆ। ਫ਼ੋਟੋ ਜੁੜੀ ਹੋਈ ਹੈ। ਜ਼ਰੂਰੀ ਗੱਲਾਂ ਉੱਪਰ ਲਿਖ ਦਿਓ।', 'Saathi abhi yeh photo nahi padh paaya. Photo attached hai. Zaroori baatein upar likh do.'],
  'useFacts': ['Add these details to my complaint', 'ये बातें मेरी शिकायत में जोड़ें', 'ਇਹ ਗੱਲਾਂ ਮੇਰੀ ਸ਼ਿਕਾਇਤ ਵਿੱਚ ਜੋੜੋ', 'Yeh baatein meri shikayat mein jodo'],
  'factsAdded': ['Added to your complaint', 'शिकायत में जोड़ दिया', 'ਸ਼ਿਕਾਇਤ ਵਿੱਚ ਜੋੜ ਦਿੱਤਾ', 'Shikayat mein jod diya'],
  'reading': ['Reading the picture…', 'फ़ोटो पढ़ी जा रही है…', 'ਫ਼ੋਟੋ ਪੜ੍ਹੀ ਜਾ ਰਹੀ ਹੈ…', 'Photo padhi ja rahi hai…'],

  // Schemes
  'monthly': ['Monthly take-home', 'महीने की कमाई', 'ਮਹੀਨੇ ਦੀ ਕਮਾਈ', 'Mahine ki kamai'],
  'eligible': ['You qualify', 'आप पात्र हैं', 'ਤੁਸੀਂ ਯੋਗ ਹੋ', 'Aap eligible ho'],
  'check': ['Check details', 'जाँच करें', 'ਜਾਂਚ ਕਰੋ', 'Check karo'],
  'notElig': ['Not for you now', 'अभी लागू नहीं', 'ਹਾਲੇ ਲਾਗੂ ਨਹੀਂ', 'Abhi lagoo nahi'],
  'rights': ['Your rights', 'आपके अधिकार', 'ਤੁਹਾਡੇ ਹੱਕ', 'Aapke haq'],
  'docHelp': ['Get document help', 'कागज़ों में मदद लें', 'ਕਾਗਜ਼ਾਂ ਵਿੱਚ ਮਦਦ ਲਓ', 'Kagaz mein madad lo'],
  'firstStep': ['What to do first', 'पहले क्या करें', 'ਪਹਿਲਾਂ ਕੀ ਕਰੀਏ', 'Pehle kya karein'],
  'schemeNote': ['Scheme rules checked October 2026. Confirm on the official portal before applying.', 'योजना के नियम अक्टूबर 2026 के हैं। आवेदन से पहले सरकारी पोर्टल पर पक्का करें।', 'ਸਕੀਮ ਦੇ ਨਿਯਮ ਅਕਤੂਬਰ 2026 ਦੇ ਹਨ। ਅਰਜ਼ੀ ਤੋਂ ਪਹਿਲਾਂ ਸਰਕਾਰੀ ਪੋਰਟਲ \'ਤੇ ਪੱਕਾ ਕਰੋ।', 'Scheme ke niyam October 2026 ke hain. Apply karne se pehle official portal pe confirm karo.'],
  'perDay': ['{x} a day × 26 work days', '{x} रोज़ × 26 काम के दिन', '{x} ਰੋਜ਼ × 26 ਕੰਮ ਦੇ ਦਿਨ', '{x} roz × 26 kaam ke din'],

  // Papers
  'notice': ['The notice you got', 'आपको मिला नोटिस', 'ਤੁਹਾਨੂੰ ਮਿਲਿਆ ਨੋਟਿਸ', 'Aapko mila notice'],
  'explain': ['Explain this notice', 'नोटिस समझाइए', 'ਨੋਟਿਸ ਸਮਝਾਓ', 'Notice samjhao'],
  'scanNotice': ['Photo of the paper', 'कागज़ की फ़ोटो', 'ਕਾਗਜ਼ ਦੀ ਫ਼ੋਟੋ', 'Kagaz ki photo'],
  'words': ['Hard words, made simple', 'कठिन शब्दों का मतलब', 'ਔਖੇ ਸ਼ਬਦਾਂ ਦਾ ਮਤਲਬ', 'Mushkil shabdon ka matlab'],
  'steps': ['Do these 3 things', 'ये 3 काम करें', 'ਇਹ 3 ਕੰਮ ਕਰੋ', 'Yeh 3 kaam karo'],
  'draftReply': ['Draft a reply to this notice', 'इस नोटिस का जवाब लिखें', 'ਇਸ ਨੋਟਿਸ ਦਾ ਜਵਾਬ ਲਿਖੋ', 'Is notice ka jawab likho'],
  'draftReplySub': ['Opens Complaint with the notice summary', 'शिकायत पेज पर नोटिस का सार भर जाएगा', "ਸ਼ਿਕਾਇਤ ਪੰਨੇ 'ਤੇ ਨੋਟਿਸ ਦਾ ਸਾਰ ਭਰਿਆ ਜਾਵੇਗਾ", 'Shikayat page pe notice ka saar bhar jayega'],
  'deadline': ['Reply within', 'जवाब की आखिरी मोहलत', 'ਜਵਾਬ ਦੀ ਆਖ਼ਰੀ ਮਿਆਦ', 'Jawab ki aakhri mohlat'],

  // Safety
  'hazardQ': ['Is it unsafe to work right now?', 'क्या अभी काम करना खतरनाक है?', 'ਕੀ ਹੁਣ ਕੰਮ ਕਰਨਾ ਖ਼ਤਰਨਾਕ ਹੈ?', 'Kya abhi kaam karna khatarnak hai?'],
  'before': ['Before you start', 'काम शुरू करने से पहले', 'ਕੰਮ ਸ਼ੁਰੂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ', 'Kaam shuru karne se pehle'],
  'idRules': ['Pause without losing your ID', 'रुकें, पर ID न खोएँ', 'ਰੁਕੋ, ਪਰ ID ਨਾ ਗੁਆਓ', 'Ruko, par ID mat khoo'],
  'report': ['Report this unsafe condition', 'इस खतरे की शिकायत करें', 'ਇਸ ਖ਼ਤਰੇ ਦੀ ਸ਼ਿਕਾਇਤ ਕਰੋ', 'Is khatre ki shikayat karo'],
  'reportSub': ['Opens Complaint, addressed to the right person', 'सही व्यक्ति के नाम शिकायत खुलेगी', 'ਸਹੀ ਵਿਅਕਤੀ ਦੇ ਨਾਂ ਸ਼ਿਕਾਇਤ ਖੁੱਲ੍ਹੇਗੀ', 'Sahi insaan ke naam shikayat khulegi'],
  'sos': ['Emergency numbers', 'आपातकालीन नंबर', 'ਐਮਰਜੈਂਸੀ ਨੰਬਰ', 'Emergency numbers'],
  'done': ['{a} of {b} done', '{b} में से {a} पूरे', '{b} ਵਿੱਚੋਂ {a} ਪੂਰੇ', '{b} mein se {a} ho gaye'],

  // Status
  'live': ['Saathi AI', 'साथी AI', 'ਸਾਥੀ AI', 'Saathi AI'],
  'off': ['Offline mode', 'ऑफ़लाइन मोड', 'ਆਫ਼ਲਾਈਨ ਮੋਡ', 'Offline mode'],
  'thinking': ['Saathi is working on it…', 'साथी काम कर रहा है…', 'ਸਾਥੀ ਕੰਮ ਕਰ ਰਿਹਾ ਹੈ…', 'Saathi kaam kar raha hai…'],
  'retry': ['Network slow. Trying again ({n}/3)', 'नेटवर्क धीमा है। फिर कोशिश ({n}/3)', 'ਨੈੱਟਵਰਕ ਹੌਲੀ ਹੈ। ਫਿਰ ਕੋਸ਼ਿਸ਼ ({n}/3)', 'Network slow hai. Phir try ({n}/3)'],
  'filled': ['Filled in {tab} for you', '{tab} में भर दिया गया', '{tab} ਵਿੱਚ ਭਰ ਦਿੱਤਾ', '{tab} mein bhar diya'],

  // Sign-up
  'step': ['Step {a} of {b}', 'चरण {a} / {b}', 'ਕਦਮ {a} / {b}', 'Step {a} / {b}'],
  'obWelcome': ['Your partner for every shift', 'हर शिफ़्ट में आपका साथी', 'ਹਰ ਸ਼ਿਫ਼ਟ ਵਿੱਚ ਤੁਹਾਡਾ ਸਾਥੀ', 'Har shift mein aapka saathi'],
  'obWelcomeSub': ['Track your pay, fight unfair cuts, find government help. In your language.', 'कमाई का हिसाब, गलत कटौती पर शिकायत, सरकारी मदद। आपकी भाषा में।', "ਕਮਾਈ ਦਾ ਹਿਸਾਬ, ਗ਼ਲਤ ਕਟੌਤੀ 'ਤੇ ਸ਼ਿਕਾਇਤ, ਸਰਕਾਰੀ ਮਦਦ। ਤੁਹਾਡੀ ਭਾਸ਼ਾ ਵਿੱਚ।", 'Kamai ka hisaab, galat katauti pe shikayat, sarkari madad. Aapki bhasha mein.'],
  'obLang': ['Choose your language', 'अपनी भाषा चुनें', 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ', 'Apni bhasha chuno'],
  'obPhone': ['Your mobile number', 'आपका मोबाइल नंबर', 'ਤੁਹਾਡਾ ਮੋਬਾਈਲ ਨੰਬਰ', 'Aapka mobile number'],
  'obSend': ['Send OTP', 'OTP भेजें', 'OTP ਭੇਜੋ', 'OTP bhejo'],
  'obPrivacy': ['Your number is only used to log in. Your earnings stay on this device.', 'नंबर सिर्फ़ लॉगिन के लिए है। आपकी कमाई का हिसाब इसी डिवाइस में रहता है।', 'ਨੰਬਰ ਸਿਰਫ਼ ਲੌਗਇਨ ਲਈ ਹੈ। ਤੁਹਾਡੀ ਕਮਾਈ ਦਾ ਹਿਸਾਬ ਇਸੇ ਡਿਵਾਈਸ ਵਿੱਚ ਰਹਿੰਦਾ ਹੈ।', 'Number sirf login ke liye hai. Aapki kamai ka hisaab isi device mein rehta hai.'],
  'obOtpT': ['Enter the code', 'कोड डालें', 'ਕੋਡ ਪਾਓ', 'Code daalo'],
  'obOtp': ['We sent a 6-digit code to', 'हमने 6 अंकों का कोड भेजा है', 'ਅਸੀਂ 6 ਅੰਕਾਂ ਦਾ ਕੋਡ ਭੇਜਿਆ ਹੈ', 'Humne 6-digit code bheja hai'],
  'obDemo': ['Demo build: use code {c}', 'डेमो: कोड {c} डालें', 'ਡੈਮੋ: ਕੋਡ {c} ਪਾਓ', 'Demo: code {c} daalo'],
  'obVerify': ['Verify and continue', 'जाँचें और आगे बढ़ें', 'ਜਾਂਚੋ ਅਤੇ ਅੱਗੇ ਵਧੋ', 'Check karke aage badho'],
  'obWrongOtp': ['That code is not right. Check and try again.', 'कोड सही नहीं है। जाँचकर फिर डालें।', 'ਕੋਡ ਸਹੀ ਨਹੀਂ ਹੈ। ਜਾਂਚ ਕੇ ਫਿਰ ਪਾਓ।', 'Code sahi nahi hai. Check karke phir daalo.'],
  'obWork': ['What work do you do?', 'आप क्या काम करते हैं?', 'ਤੁਸੀਂ ਕੀ ਕੰਮ ਕਰਦੇ ਹੋ?', 'Aap kya kaam karte ho?'],
  'obWorkSub': ['Saathi sets up your tools for this work. You can change it later.', 'साथी आपके काम के हिसाब से सब तैयार करेगा। बाद में बदल सकते हैं।', 'ਸਾਥੀ ਤੁਹਾਡੇ ਕੰਮ ਮੁਤਾਬਕ ਸਭ ਤਿਆਰ ਕਰੇਗਾ। ਬਾਅਦ ਵਿੱਚ ਬਦਲ ਸਕਦੇ ਹੋ।', 'Saathi aapke kaam ke hisaab se sab set karega. Baad mein badal sakte ho.'],
  'obNext': ['Continue', 'आगे बढ़ें', 'ਅੱਗੇ ਵਧੋ', 'Aage badho'],
  'obAbout': ['A little about you', 'अपने बारे में थोड़ा बताइए', 'ਆਪਣੇ ਬਾਰੇ ਥੋੜ੍ਹਾ ਦੱਸੋ', 'Apne baare mein thoda batao'],
  'obWhy': ['Age and state decide which government schemes you can get.', 'उम्र और राज्य से तय होता है कि कौन-सी सरकारी योजनाएँ मिलेंगी।', 'ਉਮਰ ਅਤੇ ਰਾਜ ਤੋਂ ਤੈਅ ਹੁੰਦਾ ਹੈ ਕਿ ਕਿਹੜੀਆਂ ਸਰਕਾਰੀ ਸਕੀਮਾਂ ਮਿਲਣਗੀਆਂ।', 'Umar aur state se pata chalta hai kaunsi sarkari yojana milegi.'],
  'obName': ['Your name', 'आपका नाम', 'ਤੁਹਾਡਾ ਨਾਂ', 'Aapka naam'],
  'obAge': ['Age', 'उम्र', 'ਉਮਰ', 'Umar'],
  'obState': ['State', 'राज्य', 'ਰਾਜ', 'State'],
  'obStart': ['Start using Saathi', 'साथी शुरू करें', 'ਸਾਥੀ ਸ਼ੁਰੂ ਕਰੋ', 'Saathi shuru karo'],
  'back': ['Back', 'पीछे', 'ਪਿੱਛੇ', 'Peeche'],
  'errPhone': ['Enter a 10-digit mobile number', '10 अंकों का मोबाइल नंबर डालें', '10 ਅੰਕਾਂ ਦਾ ਮੋਬਾਈਲ ਨੰਬਰ ਪਾਓ', '10-digit mobile number daalo'],
  'errName': ['Enter your name and an age between 14 and 80', 'अपना नाम और 14 से 80 के बीच उम्र डालें', 'ਆਪਣਾ ਨਾਂ ਅਤੇ 14 ਤੋਂ 80 ਵਿਚਕਾਰ ਉਮਰ ਪਾਓ', 'Apna naam aur 14 se 80 ke beech umar daalo'],

  // Profile
  'profile': ['My profile', 'मेरी प्रोफ़ाइल', 'ਮੇਰੀ ਪ੍ਰੋਫ਼ਾਈਲ', 'Meri profile'],
  'changeWork': ['Change my work', 'मेरा काम बदलें', 'ਮੇਰਾ ਕੰਮ ਬਦਲੋ', 'Mera kaam badlo'],
  'logout': ['Log out', 'लॉग आउट', 'ਲੌਗ ਆਊਟ', 'Log out'],
  'apiKey': ['Gemini API key', 'Gemini API key', 'Gemini API key', 'Gemini API key'],
  'apiKeySub': ['Saved only in this browser. Without a key, Saathi uses its built-in answers.', 'सिर्फ़ इसी ब्राउज़र में सेव होती है। बिना key के साथी अपने बने-बनाए जवाब देता है।', 'ਸਿਰਫ਼ ਇਸੇ ਬ੍ਰਾਊਜ਼ਰ ਵਿੱਚ ਸੇਵ ਹੁੰਦੀ ਹੈ। ਬਿਨਾਂ key ਦੇ ਸਾਥੀ ਆਪਣੇ ਬਣੇ-ਬਣਾਏ ਜਵਾਬ ਦਿੰਦਾ ਹੈ।', 'Sirf isi browser mein save hoti hai. Bina key ke Saathi apne built-in jawab deta hai.'],
  'simulate': ['Simulate network failure', 'नेटवर्क फ़ेल होने का टेस्ट', 'ਨੈੱਟਵਰਕ ਫ਼ੇਲ੍ਹ ਹੋਣ ਦਾ ਟੈਸਟ', 'Network fail ka test'],
  'save': ['Save', 'सेव करें', 'ਸੇਵ ਕਰੋ', 'Save karo'],
};
