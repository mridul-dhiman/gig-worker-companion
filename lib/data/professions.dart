import '../l10n/strings.dart';
import '../models/models.dart';

enum Recipient { platform, contractor, labour, court }

/// Everything Saathi sets up for one kind of work. The sample values
/// (name, log, notice) pre-fill the app so it is useful from the first screen.
class Profession {
  const Profession({
    required this.id,
    required this.titles,
    required this.role,
    required this.sampleName,
    required this.sampleAge,
    required this.sampleState,
    required this.partnerId,
    required this.defaultLog,
    required this.sample,
    required this.defaultIssue,
    required this.recipient,
    required this.defaultDoc,
    required this.doc,
    required this.safetyChecklist,
    required this.hazards,
    required this.idRules,
    required this.sos,
    required this.cashIn,
    required this.cashOut,
    required this.sampleSms,
    required this.sampleProof,
    required this.rights,
  });

  final String id;

  /// [title, subtitle] per language, indexed by [AppLang.index].
  final List<(String, String)> titles;
  final String role;
  final String sampleName;
  final int sampleAge;
  final String sampleState;
  final String partnerId;
  final String defaultLog;

  /// The result for [defaultLog], used by the offline engine.
  final EarnResult sample;
  final String defaultIssue;
  final Recipient recipient;
  final String defaultDoc;
  final DocResult doc;
  final List<String> safetyChecklist;
  final List<Hazard> hazards;
  final List<String> idRules;
  final List<(String, String)> sos;
  final List<String> cashIn;
  final List<String> cashOut;
  final List<String> sampleSms;
  final ProofResult sampleProof;
  final List<(String, String)> rights;

  String title(AppLang l) => titles[l.index].$1;
  String subtitle(AppLang l) => titles[l.index].$2;
}

const states = [
  'Delhi', 'Punjab', 'Haryana', 'Rajasthan', 'Karnataka', 'Maharashtra',
  'Uttar Pradesh', 'Bihar', 'Telangana', 'West Bengal', 'Other',
];

const _socialSecurity = (
  'Code on Social Security, 2020',
  'The law now counts gig and platform workers. The government can run welfare schemes for you.'
);

const professions = <String, Profession>{
  'delivery': Profession(
    id: 'delivery',
    titles: [
      ('Delivery partner', 'Food, grocery or parcels, on bike or cycle'),
      ('डिलीवरी पार्टनर', 'खाना, राशन या पार्सल, बाइक या साइकिल से'),
      ('ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ', 'ਖਾਣਾ, ਰਾਸ਼ਨ ਜਾਂ ਪਾਰਸਲ, ਬਾਈਕ ਜਾਂ ਸਾਈਕਲ ਨਾਲ'),
      ('Delivery partner', 'Khana, ration ya parcel, bike ya cycle se'),
    ],
    role: 'Delivery Partner (Quick-Commerce & Food)',
    sampleName: 'Rajesh Kumar',
    sampleAge: 29,
    sampleState: 'Delhi',
    partnerId: 'DL-9921',
    defaultLog:
        'Completed 18 deliveries today, earned ₹1,150 total. Spent ₹240 on petrol. Platform deducted ₹180 penalty saying "late order delivery" even though restaurant delayed the food by 35 mins.',
    sample: EarnResult(
      gross: 1150,
      expense: 240,
      deduction: 180,
      deductionWhy:
          'The restaurant held the food for 35 minutes. You reached the pickup on time, so the delay was not yours.',
    ),
    defaultIssue:
        'Unfair ₹180 penalty deducted for restaurant preparation delay (Order #49281) despite arriving at pickup location on time.',
    recipient: Recipient.platform,
    defaultDoc:
        'NOTICE OF PENALTY DEDUCTION: Partner ID #DL-9921. An amount of INR 180.00 has been debited from your weekly settlement under Clause 4.2 (SLA Breach - Delayed Handover). Dispute window closes in 48 hours.',
    doc: DocResult(
      type: 'Penalty notice',
      summary:
          'The platform took ₹180 out of your weekly pay. They say you handed over an order late. You have 48 hours to tell them this is wrong.',
      terms: [
        ('SLA Breach', 'You missed a time promise'),
        ('Clause 4.2', 'The rule number in your partner contract'),
        ('Weekly settlement', 'Your weekly payout'),
        ('Debited', 'Taken out of your money'),
      ],
      steps: [
        'Take a screenshot of the app showing you reached the restaurant on time.',
        'Open Help → Dispute a penalty in the app, before the 48 hours end.',
        'Paste the complaint Saathi writes for you and save the ticket number.',
      ],
      deadline: '48 hours',
    ),
    safetyChecklist: [
      'Inspect brake pads, tyre pressure, and reflective rain gear before evening peak hours.',
      'Never speed to beat arbitrary 10-minute timers; log restaurant or traffic delays in-app immediately.',
      'Take a 10-minute hydration and shade break every 2 hours during high heat or heavy rain alerts.',
    ],
    hazards: [
      Hazard(id: 'heat', label: 'Heatwave above 44°C', whatToDo: [
        'Stop riding between 12 and 4 pm if there is a red alert.',
        'Drink water every 30 minutes, even if not thirsty.',
      ], fix: 'heat breaks are allowed without losing incentives'),
      Hazard(id: 'rain', label: 'Waterlogged roads', whatToDo: [
        'Do not ride through water deeper than your ankle.',
        'Park on high ground and wait for the water to go down.',
      ], fix: 'orders are paused in flooded zones'),
      Hazard(id: 'aqi', label: 'Air quality severe', whatToDo: [
        'Wear an N95 mask on every trip.',
        'Take shorter shifts and rest indoors between orders.',
      ], fix: 'masks are provided and shifts can be shortened'),
    ],
    idRules: [
      'Go "Offline – safety" in the app. Do not reject orders one by one, because rejections lower your rating.',
      'Take a screenshot of the IMD weather alert. The time must be visible.',
      'Send support one line: "Paused for my safety due to red alert." Save the ticket number.',
    ],
    sos: [('112', 'Emergency'), ('108', 'Ambulance'), ('1073', 'Road accident')],
    cashIn: ['Cash tip', 'Cash bonus', 'Other'],
    cashOut: ['Petrol', 'Repair', 'Food', 'Other'],
    sampleSms: [
      'Rs.60.00 received in A/c XX4410 from SURESH M via UPI Ref 428193650021. -HDFC Bank',
      'INR 4,820.00 credited to A/c XX4410. Partner payout wk 41. Adj: -180.00 (SLA). -SBI',
      'Rs 240.00 debited from A/c XX4410 to HP PETROL PUMP KAROL BAGH via UPI. -HDFC Bank',
    ],
    sampleProof: ProofResult(
      fileName: 'sample_order_49281.jpg',
      kind: 'Sample app screenshot',
      facts: [
        ('Order', '#49281'),
        ('You reached the restaurant', '1:12 PM'),
        ('Food was handed over', '1:47 PM, 35 min later'),
        ('Penalty charged', '₹180, "late handover"'),
      ],
      sentence:
          'My app screenshot shows I reached the restaurant at 1:12 PM and the food was handed over only at 1:47 PM, 35 minutes later.',
    ),
    rights: [
      _socialSecurity,
      ('Ask in writing', 'You can ask the platform for the reason and the proof behind any penalty.'),
    ],
  ),
  'driver': Profession(
    id: 'driver',
    titles: [
      ('Cab or auto driver', 'Ride apps, airport trips, city rides'),
      ('कैब या ऑटो ड्राइवर', 'राइड ऐप, एयरपोर्ट ट्रिप, शहर की सवारी'),
      ('ਕੈਬ ਜਾਂ ਆਟੋ ਡਰਾਈਵਰ', 'ਰਾਈਡ ਐਪ, ਏਅਰਪੋਰਟ ਟ੍ਰਿਪ, ਸ਼ਹਿਰ ਦੀਆਂ ਸਵਾਰੀਆਂ'),
      ('Cab ya auto driver', 'Ride app, airport trip, city ki sawari'),
    ],
    role: 'App-Based Cab & Auto Driver',
    sampleName: 'Gurpreet Singh',
    sampleAge: 41,
    sampleState: 'Punjab',
    partnerId: 'PB-08-CT-4402',
    defaultLog:
        'Drove 11 hours today, total fares ₹2,400. CNG fuel cost ₹650, MCD toll ₹120 was not added to customer bill by the app, and platform took commission.',
    sample: EarnResult(
      gross: 2400,
      expense: 650,
      deduction: 120,
      deductionWhy:
          "You paid the ₹120 toll yourself and uploaded the Fastag receipt. The app should have added it to the rider's bill.",
    ),
    defaultIssue:
        'Unreimbursed MCD commercial toll charge of ₹120 on airport trip #TR-8832 despite uploading valid Fastag receipt.',
    recipient: Recipient.platform,
    defaultDoc:
        'E-CHALLAN / PERMIT NOTICE: Vehicle PB-08-CT-4402 flagged for commercial pickup outside designated zone. Fine: INR 2,000 under MV Act. Option to contest before Virtual Traffic Court within 15 days.',
    doc: DocResult(
      type: 'Traffic e-challan',
      summary:
          'Your car got a ₹2,000 fine for picking up a rider outside the allowed area. You can fight it online in a Virtual Court. You have 15 days.',
      terms: [
        ('MV Act', 'Motor Vehicles Act, the main road law'),
        ('Virtual Traffic Court', 'An online court. You do not have to go in person.'),
        ('Designated zone', 'The area where pickups are allowed'),
        ('Commercial pickup', 'Picking up a paying rider'),
      ],
      steps: [
        'Open the official e-challan site and check the fine using your vehicle number.',
        'Download the trip log from the app. It shows where the rider set the pickup pin.',
        'Choose "Contest" in the Virtual Court before the 15 days end, and upload the trip log.',
      ],
      deadline: '15 days',
    ),
    safetyChecklist: [
      'Verify emergency SOS button and dashcam/audio recording permissions before starting night shifts.',
      'Do not accept offline cash detours in isolated zones; keep live trip sharing active.',
      'Stretch lower back and legs for 5 minutes after every 3 hours of continuous city driving.',
    ],
    hazards: [
      Hazard(id: 'flood', label: 'Flooded underpass', whatToDo: [
        'Do not drive into water above the middle of the tyre.',
        'Turn around and tell the rider the route is unsafe.',
      ], fix: 'trips through flooded routes can be cancelled without penalty'),
      Hazard(id: 'fog', label: 'Dense fog at night', whatToDo: [
        'Keep speed under 40 km/h and use fog lamps.',
        'Stop at a lit dhaba or petrol pump if you cannot see 50 m ahead.',
      ], fix: 'fog cancellations do not count against my acceptance rate'),
      Hazard(id: 'iso', label: 'Isolated pickup at night', whatToDo: [
        'Keep live trip sharing on with family.',
        'Do not leave the app route for a cash detour.',
      ], fix: 'drivers can decline unsafe night pickups without penalty'),
    ],
    idRules: [
      'Cancel with the reason "Safety concern". It does not count against your acceptance rate the way a plain cancel does.',
      'Turn on audio recording in the app before you decline.',
      'Message support with the trip ID and one line about the danger. Save the reply.',
    ],
    sos: [('112', 'Emergency'), ('1033', 'Highway help'), ('108', 'Ambulance')],
    cashIn: ['Cash fare', 'Cash tip', 'Other'],
    cashOut: ['CNG / fuel', 'Parking', 'Food', 'Other'],
    sampleSms: [
      'Rs.150.00 credited to A/c XX2207 from AMIT KUMAR via UPI. Ref 330918277410. -ICICI Bank',
      'INR 1,640.00 credited to A/c XX2207. Driver earnings 16-Oct. Toll reimbursed: 0.00. -ICICI Bank',
      'Rs 650.00 debited from A/c XX2207 at CNG STATION MOHALI via UPI. -PNB',
    ],
    sampleProof: ProofResult(
      fileName: 'sample_trip_TR8832.jpg',
      kind: 'Sample app screenshot',
      facts: [
        ('Trip', '#TR-8832'),
        ('Toll you paid', '₹120 by Fastag, 3:40 PM'),
        ('Toll added to rider bill', '₹0'),
        ('Receipt uploaded', 'Yes, same day'),
      ],
      sentence:
          'My trip screenshot shows I paid a ₹120 toll by Fastag at 3:40 PM on trip #TR-8832, and ₹0 was added to the rider bill.',
    ),
    rights: [
      _socialSecurity,
      ('MV Act, contest a challan', 'You can say "this fine is wrong" in the Virtual Court before paying.'),
    ],
  ),
  'daily_wage': Profession(
    id: 'daily_wage',
    titles: [
      ('Construction or daily-wage work', 'Site work, loading, paid by the day'),
      ('निर्माण या दिहाड़ी काम', 'साइट का काम, लोडिंग, रोज़ की मज़दूरी'),
      ('ਉਸਾਰੀ ਜਾਂ ਦਿਹਾੜੀ ਦਾ ਕੰਮ', 'ਸਾਈਟ ਦਾ ਕੰਮ, ਲੋਡਿੰਗ, ਰੋਜ਼ ਦੀ ਮਜ਼ਦੂਰੀ'),
      ('Construction ya dihadi kaam', 'Site ka kaam, loading, roz ki mazdoori'),
    ],
    role: 'Daily-Wage Construction & Domestic Worker',
    sampleName: 'Sunita Devi',
    sampleAge: 34,
    sampleState: 'Haryana',
    partnerId: 'Site: Sector 42',
    defaultLog:
        'Worked 9 hours at Sector 42 site. Promised daily wage was ₹700. Contractor paid ₹500 cash, spent ₹50 on bus fare, and contractor held back ₹200 without giving overtime.',
    sample: EarnResult(
      gross: 700,
      expense: 50,
      deduction: 200,
      deductionWhy:
          'You were promised ₹700 and worked 9 hours. Holding back pay with no written reason is not allowed, and the extra hour should be paid as overtime.',
    ),
    defaultIssue: 'Contractor withheld ₹200 from promised ₹700 daily wage for 9-hour shift at Sector 42 site.',
    recipient: Recipient.contractor,
    defaultDoc:
        'E-SHRAM & BOCW WELFARE BOARD NOTICE: Applicant registration pending due to incomplete Aadhaar-seeded bank passbook and 90-day work certificate from contractor/union.',
    doc: DocResult(
      type: 'Registration on hold',
      summary:
          'Your e-Shram and construction board registration is stuck. They need two things: a bank account linked to Aadhaar, and a paper that says you worked 90 days.',
      terms: [
        ('Aadhaar-seeded', 'Bank account linked to your Aadhaar number'),
        ('BOCW Welfare Board', 'The government board for construction workers'),
        ('90-day work certificate', 'A letter from your contractor or union saying you worked at least 90 days this year'),
      ],
      steps: [
        'Go to your bank with Aadhaar and passbook. Ask them to link Aadhaar to the account.',
        'Ask your contractor or union for a 90-day work certificate, signed and stamped.',
        'Take both to a CSC centre or the board office and upload them.',
      ],
    ),
    safetyChecklist: [
      'Demand mandatory hard hat, non-slip footwear, and safety harness before working on scaffolding.',
      'Ensure clean drinking water and shaded rest area availability on site as mandated by labour law.',
      'Save the local Labour Helpline (155214) and Emergency Ambulance (108/112) on speed dial.',
    ],
    hazards: [
      Hazard(id: 'harness', label: 'No harness at height', whatToDo: [
        'Do not climb scaffolding without a harness.',
        'Tell the supervisor in front of another worker.',
      ], fix: 'a harness is provided to every worker on scaffolding'),
      Hazard(id: 'water', label: 'No drinking water on site', whatToDo: [
        'Carry 2 litres from home.',
        'Note the date and time water was missing.',
      ], fix: 'clean drinking water and shade are provided on site'),
      Hazard(id: 'heat', label: 'Heatwave above 44°C', whatToDo: [
        'Rest in shade between 12 and 3 pm.',
        'Wet a cloth and keep it on your head and neck.',
      ], fix: 'work hours are shifted away from peak heat'),
    ],
    idRules: [
      'Tell the supervisor you are stopping for safety, in front of a co-worker who can confirm it.',
      'Take a photo of the unsafe spot. Make sure the time is visible.',
      'Call the labour helpline 155214 and note the complaint number.',
    ],
    sos: [('112', 'Emergency'), ('155214', 'Labour help'), ('181', 'Women help')],
    cashIn: ['Cash wage', 'Extra work', 'Other'],
    cashOut: ['Bus / auto', 'Tools', 'Food', 'Other'],
    sampleSms: [
      'Rs.1,500.00 credited to A/c XX1183 by NEFT from SHREE BUILDERS. Wages 14-16 Oct. -Bank of India',
      'Rs 300.00 sent from A/c XX1183 to RAMESH KIRANA STORE via UPI. -Bank of India',
      'Rs 50.00 debited from A/c XX1183 to HR ROADWAYS via UPI. -Bank of India',
    ],
    sampleProof: ProofResult(
      fileName: 'sample_wage_slip.jpg',
      kind: 'Sample photo of wage slip',
      facts: [
        ('Site', 'Shree Builders, Sector 42'),
        ('Hours written', '9'),
        ('Daily rate written', '₹700'),
        ('Amount paid', '₹500, which is ₹200 short'),
      ],
      sentence: "The contractor's own wage slip shows a daily rate of ₹700 for 9 hours, but only ₹500 was paid.",
    ),
    rights: [
      ('Code on Wages, 2019',
          'You must get the full wage you were promised, on time. Holding back pay without a written reason is not allowed.'),
      ('Overtime', 'Work beyond the fixed hours is paid at twice the normal rate.'),
    ],
  ),
};

/// Rule-based scheme matching. Kept deterministic on purpose: scheme facts
/// should come from a dated catalogue, not from the model.
List<Scheme> matchSchemes(Profile p, int monthly) {
  final list = <Scheme>[
    Scheme(
      name: 'e-Shram card',
      status: p.age >= 16 && p.age <= 59 ? SchemeStatus.eligible : SchemeStatus.notEligible,
      why: 'For unorganised and platform workers aged 16–59. You are ${p.age}.',
      benefit: 'A worker ID (UAN) that unlocks other schemes, plus ₹2 lakh accident insurance.',
      kyc: const ['Aadhaar card', 'Mobile number linked to Aadhaar', 'Bank account (IFSC and account number)'],
    ),
  ];
  final pmOk = p.age >= 18 && p.age <= 40 && monthly <= 15000;
  list.add(Scheme(
    name: 'PM Shram Yogi Maan-dhan (pension)',
    status: pmOk ? SchemeStatus.eligible : SchemeStatus.notEligible,
    why: pmOk
        ? 'Age 18–40 and income up to ₹15,000 a month. You fit both.'
        : p.age > 40
            ? 'Only for people who join by age 40. You are ${p.age}.'
            : 'Only for income up to ₹15,000 a month. Yours is about ${inr(monthly)}.',
    benefit: '₹3,000 pension every month after age 60. You pay ₹55–200 a month and the government pays the same.',
    kyc: const ['Aadhaar card', 'Savings or Jan Dhan bank account with IFSC', 'Consent for monthly auto-debit'],
  ));
  if (p.professionId == 'daily_wage') {
    list.addAll(const [
      Scheme(
        name: 'Construction Workers Welfare Board (BOCW)',
        status: SchemeStatus.check,
        why: 'Needs proof of 90 days of construction work in the last year.',
        benefit: "Help with children's school fees, maternity, tools, and accident support.",
        kyc: ['Aadhaar card', 'Aadhaar-linked bank passbook', '90-day work certificate from contractor or union', 'Passport photo'],
      ),
      Scheme(
        name: 'Ayushman Bharat (PM-JAY)',
        status: SchemeStatus.check,
        why: "Depends on your family's ration card or SECC listing. Check at any CSC centre.",
        benefit: 'Free hospital treatment up to ₹5 lakh per family each year.',
        kyc: ['Aadhaar card', 'Ration card'],
      ),
    ]);
  } else {
    final st = p.state == 'Other' ? 'State' : p.state;
    final hasLaw = const ['Rajasthan', 'Karnataka'].contains(p.state);
    list.addAll([
      const Scheme(
        name: 'Ayushman Bharat for platform workers',
        status: SchemeStatus.eligible,
        why: 'Platform workers registered on e-Shram are being brought under PM-JAY.',
        benefit: 'Free hospital treatment up to ₹5 lakh per family each year.',
        kyc: ['e-Shram card', 'Aadhaar card', 'Proof of platform work (app profile screenshot)'],
      ),
      Scheme(
        name: '$st gig worker welfare board',
        status: SchemeStatus.check,
        why: hasLaw
            ? '${p.state} has a gig-worker welfare law. Register with the board using your partner ID.'
            : 'Rajasthan and Karnataka have gig-worker laws. Check if ${p.state == 'Other' ? 'your state' : p.state} has opened registration.',
        benefit: 'Registration with a welfare fund and a grievance cell. Benefits differ by state.',
        kyc: const ['Aadhaar card', 'Platform partner ID', 'Bank account'],
      ),
    ]);
  }
  list.sort((a, b) => a.status.index.compareTo(b.status.index));
  return list;
}

String inr(num n) {
  final neg = n < 0;
  final s = n.abs().round().toString();
  // Indian grouping: last 3 digits, then pairs.
  String out;
  if (s.length <= 3) {
    out = s;
  } else {
    final head = s.substring(0, s.length - 3);
    final tail = s.substring(s.length - 3);
    final parts = <String>[];
    for (var i = head.length; i > 0; i -= 2) {
      parts.insert(0, head.substring(i - 2 < 0 ? 0 : i - 2, i));
    }
    out = '${parts.join(',')},$tail';
  }
  return '${neg ? '−' : ''}₹$out';
}
