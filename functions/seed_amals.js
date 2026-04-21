/**
 * Seed script for the Amal app — populates 20 sample Amals in Firestore.
 *
 * Usage:  node seed_amals.js
 *
 * Idempotent: if the `amals` collection already contains documents the script
 * prints a message and exits without writing anything.
 */

const admin = require("firebase-admin");

// Initialise with Application Default Credentials (works with
// `firebase login` locally or with GOOGLE_APPLICATION_CREDENTIALS).
admin.initializeApp();
const db = admin.firestore();
const { Timestamp } = admin.firestore;

const PLACEHOLDER_VIDEO =
  "https://storage.googleapis.com/amal-app-production.appspot.com/amals/placeholder.mp4";
const PLACEHOLDER_THUMB =
  "https://storage.googleapis.com/amal-app-production.appspot.com/amals/thumb_placeholder.jpg";

// ---------------------------------------------------------------------------
// 20 Amal documents — 5 video, 15 static — spread across 6 categories
// ---------------------------------------------------------------------------
const amals = [
  // ── PRAYER (4 amals: 1 video, 3 static) ──────────────────────────────
  {
    id: "amal_001",
    title_en: "Pray Fajr on Time",
    title_bn: "ফজর সময়মতো পড়ুন",
    title_ur: "فجر کی نماز وقت پر پڑھیں",
    title_ar: "صلاة الفجر في وقتها",
    description_en:
      "Wake up and perform Fajr salah at its earliest time. The Prophet ﷺ said the two rak'ahs of Fajr are better than the world and all it contains.",
    description_bn:
      "জেগে উঠুন এবং ফজরের সালাত তার প্রথম সময়ে আদায় করুন। রাসূলুল্লাহ ﷺ বলেছেন ফজরের দুই রাকাত দুনিয়া ও তার মধ্যে যা আছে তার চেয়ে উত্তম।",
    description_ur:
      "اٹھیں اور فجر کی نماز اس کے ابتدائی وقت میں ادا کریں۔ نبی ﷺ نے فرمایا فجر کی دو رکعتیں دنیا اور اس کی ہر چیز سے بہتر ہیں۔",
    description_ar:
      "استيقظ وصلِّ الفجر في أول وقتها. قال النبي ﷺ: ركعتا الفجر خير من الدنيا وما فيها.",
    category: "prayer",
    subcategory: "fard",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 150,
    completionType: "daily",
    difficulty: "medium",
    source: "Sahih Muslim 725",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_002",
    title_en: "Learn the Meaning of Al-Fatihah",
    title_bn: "সূরা ফাতিহার অর্থ শিখুন",
    title_ur: "سورۃ الفاتحہ کا مفہوم سیکھیں",
    title_ar: "تعلّم معاني سورة الفاتحة",
    description_en:
      "Watch this short lesson on the word-by-word meaning of Surah Al-Fatihah so you can reflect during every prayer.",
    description_bn:
      "সূরা আল-ফাতিহার শব্দে শব্দে অর্থ সম্পর্কে এই সংক্ষিপ্ত পাঠ দেখুন যাতে প্রতিটি নামাজে আপনি চিন্তা করতে পারেন।",
    description_ur:
      "سورۃ الفاتحہ کے لفظ بہ لفظ معنی پر یہ مختصر سبق دیکھیں تاکہ آپ ہر نماز میں تدبر کر سکیں۔",
    description_ar:
      "شاهد هذا الدرس القصير عن معاني سورة الفاتحة كلمةً كلمة لتتدبرها في كل صلاة.",
    category: "prayer",
    subcategory: "knowledge",
    contentType: "video",
    videoUrl: PLACEHOLDER_VIDEO,
    videoThumbnailUrl: PLACEHOLDER_THUMB,
    duaText_en:
      "In the Name of Allah, the Most Gracious, the Most Merciful. All praise is due to Allah, Lord of all the worlds.",
    duaText_ar:
      "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
    noorCoins: 200,
    completionType: "once",
    difficulty: "easy",
    source: "Quran 1:1-7",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_003",
    title_en: "Pray Two Rak'ahs of Duha",
    title_bn: "দুহার দুই রাকাত নামাজ পড়ুন",
    title_ur: "چاشت کی دو رکعتیں پڑھیں",
    title_ar: "صلاة ركعتين من الضحى",
    description_en:
      "Pray two voluntary rak'ahs after sunrise (Duha prayer). The Prophet ﷺ said: 'Every morning charity is due on every joint of yours.'",
    description_bn:
      "সূর্যোদয়ের পর দুই রাকাত নফল নামাজ (চাশতের নামাজ) পড়ুন। নবী ﷺ বলেছেন: 'প্রতিদিন সকালে তোমাদের প্রতিটি জোড়ার জন্য সদকা দেওয়া উচিত।'",
    description_ur:
      "طلوعِ آفتاب کے بعد دو نفل رکعتیں (صلاۃ الضحیٰ) پڑھیں۔ نبی ﷺ نے فرمایا: ہر صبح تمہارے ہر جوڑ پر صدقہ واجب ہے۔",
    description_ar:
      "صلِّ ركعتين نافلة بعد شروق الشمس (صلاة الضحى). قال النبي ﷺ: يُصبح على كل سُلامى من أحدكم صدقة.",
    category: "prayer",
    subcategory: "sunnah",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 100,
    completionType: "daily",
    difficulty: "easy",
    source: "Sahih Muslim 720",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_004",
    title_en: "Recite Ayat al-Kursi After Every Salah",
    title_bn: "প্রতিটি সালাতের পর আয়াতুল কুরসি পড়ুন",
    title_ur: "ہر نماز کے بعد آیۃ الکرسی پڑھیں",
    title_ar: "قراءة آية الكرسي بعد كل صلاة",
    description_en:
      "Recite Ayat al-Kursi (Quran 2:255) after each obligatory prayer. The Prophet ﷺ said nothing prevents a person who recites it after each prayer from entering Paradise except death.",
    description_bn:
      "প্রতিটি ফরজ নামাজের পর আয়াতুল কুরসী (কুরআন ২:২৫৫) পড়ুন। নবী ﷺ বলেছেন, যে ব্যক্তি প্রতিটি নামাজের পর এটি পাঠ করে মৃত্যু ছাড়া কিছুই তাকে জান্নাতে প্রবেশ করা থেকে বিরত রাখতে পারে না।",
    description_ur:
      "ہر فرض نماز کے بعد آیۃ الکرسی (قرآن ۲:۲۵۵) پڑھیں۔ نبی ﷺ نے فرمایا: جو شخص ہر نماز کے بعد اسے پڑھے اسے جنت میں داخل ہونے سے موت کے سوا کوئی چیز نہیں روکتی۔",
    description_ar:
      "اقرأ آية الكرسي (البقرة ٢٥٥) بعد كل صلاة مكتوبة. قال النبي ﷺ: من قرأها دُبُر كل صلاة لم يمنعه من دخول الجنة إلا الموت.",
    category: "prayer",
    subcategory: "dhikr",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en:
      "Allah! There is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep.",
    duaText_ar:
      "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ",
    noorCoins: 100,
    completionType: "daily",
    difficulty: "easy",
    source: "Sunan an-Nasa'i 9928",
    is_scholar_reviewed: true,
  },

  // ── FAMILY (4 amals: 1 video, 3 static) ──────────────────────────────
  {
    id: "amal_005",
    title_en: "Make Dua for Parents",
    title_bn: "পিতামাতার জন্য দোয়া করুন",
    title_ur: "والدین کے لیے دعا کریں",
    title_ar: "الدعاء للوالدين",
    description_en:
      "Make a sincere dua asking Allah to have mercy on your parents, as they raised you with love and sacrifice. This is a Quranic commandment.",
    description_bn:
      "আপনার পিতামাতার প্রতি আল্লাহর রহমত কামনা করে আন্তরিক দোয়া করুন, যেমন তারা ভালোবাসা ও ত্যাগের সাথে আপনাকে বড় করেছেন।",
    description_ur:
      "اللہ سے اپنے والدین پر رحم کی دعا کریں، جیسا کہ انہوں نے آپ کو محبت اور قربانی سے پالا۔ یہ قرآنی حکم ہے۔",
    description_ar:
      "ادعُ الله أن يرحم والديك كما ربّياك صغيرًا. هذا أمر قرآني.",
    category: "family",
    subcategory: "parents",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: "My Lord, have mercy upon them as they brought me up when I was small.",
    duaText_ar: "رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا",
    noorCoins: 100,
    completionType: "daily",
    difficulty: "easy",
    source: "Quran 17:24",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_006",
    title_en: "Teach Your Child a Short Surah",
    title_bn: "আপনার সন্তানকে একটি ছোট সূরা শেখান",
    title_ur: "اپنے بچے کو ایک چھوٹی سورت سکھائیں",
    title_ar: "علّم طفلك سورة قصيرة",
    description_en:
      "Sit with your child and teach them a short surah such as Al-Ikhlas, Al-Falaq, or An-Nas. The Prophet ﷺ said the best of you are those who learn the Quran and teach it.",
    description_bn:
      "আপনার সন্তানের সাথে বসুন এবং তাকে আল-ইখলাস, আল-ফালাক বা আন-নাসের মতো একটি ছোট সূরা শেখান।",
    description_ur:
      "اپنے بچے کے ساتھ بیٹھیں اور انہیں سورۃ الاخلاص، الفلق یا الناس جیسی چھوٹی سورت سکھائیں۔",
    description_ar:
      "اجلس مع طفلك وعلّمه سورة قصيرة كالإخلاص أو الفلق أو الناس. قال النبي ﷺ: خيركم من تعلّم القرآن وعلّمه.",
    category: "family",
    subcategory: "children",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 200,
    completionType: "daily",
    difficulty: "medium",
    source: "Sahih al-Bukhari 5027",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_007",
    title_en: "Rights of Spouses in Islam",
    title_bn: "ইসলামে স্বামী-স্ত্রীর অধিকার",
    title_ur: "اسلام میں میاں بیوی کے حقوق",
    title_ar: "حقوق الزوجين في الإسلام",
    description_en:
      "Watch this lesson on the mutual rights and responsibilities of spouses in Islam, based on the Quran and Sunnah.",
    description_bn:
      "কুরআন ও সুন্নাহর ভিত্তিতে ইসলামে স্বামী-স্ত্রীর পারস্পরিক অধিكار ও দায়িত্ব নিয়ে এই পাঠ দেখুন।",
    description_ur:
      "قرآن و سنت کی بنیاد پر اسلام میں میاں بیوی کے باہمی حقوق اور ذمہ داریوں پر یہ سبق دیکھیں۔",
    description_ar:
      "شاهد هذا الدرس عن الحقوق والواجبات المتبادلة بين الزوجين في الإسلام بناءً على القرآن والسنة.",
    category: "family",
    subcategory: "spouse",
    contentType: "video",
    videoUrl: PLACEHOLDER_VIDEO,
    videoThumbnailUrl: PLACEHOLDER_THUMB,
    duaText_en:
      "Our Lord, grant us from among our wives and offspring comfort to our eyes and make us a leader for the righteous.",
    duaText_ar:
      "رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا",
    noorCoins: 200,
    completionType: "once",
    difficulty: "easy",
    source: "Quran 25:74",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_008",
    title_en: "Visit or Call a Relative",
    title_bn: "আত্মীয়কে দেখতে যান বা ফোন করুন",
    title_ur: "کسی رشتہ دار سے ملیں یا فون کریں",
    title_ar: "زيارة أو الاتصال بأحد الأقارب",
    description_en:
      "Maintain family ties (silat al-rahim) by visiting or calling a relative today. The Prophet ﷺ said: 'Whoever would like his provision to be increased and his lifespan extended, let him maintain family ties.'",
    description_bn:
      "আজ একজন আত্মীয়কে দেখতে গিয়ে বা ফোন করে পারিবারিক বন্ধন (সিলাতুর রাহিম) বজায় রাখুন।",
    description_ur:
      "آج کسی رشتہ دار سے مل کر یا فون کر کے صلہ رحمی کریں۔ نبی ﷺ نے فرمایا: جو چاہے کہ اس کا رزق بڑھے اور عمر لمبی ہو وہ صلہ رحمی کرے۔",
    description_ar:
      "صِل رحمك اليوم بزيارة أحد أقاربك أو الاتصال به. قال النبي ﷺ: من أحب أن يُبسط له في رزقه ويُنسأ له في أثره فليصل رحمه.",
    category: "family",
    subcategory: "relatives",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 150,
    completionType: "daily",
    difficulty: "easy",
    source: "Sahih al-Bukhari 5986",
    is_scholar_reviewed: true,
  },

  // ── COMMUNITY (3 amals: 1 video, 2 static) ───────────────────────────
  {
    id: "amal_009",
    title_en: "Give Salam to a Stranger",
    title_bn: "অপরিচিতকে সালাম দিন",
    title_ur: "کسی اجنبی کو سلام کریں",
    title_ar: "إلقاء السلام على من لا تعرفه",
    description_en:
      "Spread peace by greeting a Muslim you do not know with 'Assalamu Alaikum'. The Prophet ﷺ said: 'You will not enter Paradise until you believe, and you will not believe until you love one another. Shall I show you something that, if you did, you would love one another? Spread peace amongst yourselves.'",
    description_bn:
      "আপনি চেনেন না এমন একজন মুসলমানকে 'আসসালামু আলাইকুম' বলে শান্তি ছড়িয়ে দিন।",
    description_ur:
      "کسی ایسے مسلمان کو 'السلام علیکم' کہہ کر سلامتی پھیلائیں جسے آپ نہیں جانتے۔",
    description_ar:
      "أفشِ السلام بأن تقول 'السلام عليكم' لمسلم لا تعرفه. قال النبي ﷺ: لا تدخلون الجنة حتى تؤمنوا ولا تؤمنوا حتى تحابّوا، أوَلا أدلّكم على شيء إذا فعلتموه تحاببتم؟ أفشوا السلام بينكم.",
    category: "community",
    subcategory: "social",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 50,
    completionType: "daily",
    difficulty: "easy",
    source: "Sahih Muslim 54",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_010",
    title_en: "Remove Harm from the Path",
    title_bn: "পথ থেকে কষ্টদায়ক জিনিস সরান",
    title_ur: "راستے سے تکلیف دہ چیز ہٹائیں",
    title_ar: "إماطة الأذى عن الطريق",
    description_en:
      "Remove an obstacle or piece of litter from a pathway. The Prophet ﷺ said: 'Removing harmful things from the road is an act of charity (sadaqah).'",
    description_bn:
      "পথ থেকে একটি বাধা বা আবর্জনা সরান। নবী ﷺ বলেছেন: 'রাস্তা থেকে কষ্টদায়ক জিনিস সরানো সদকা।'",
    description_ur:
      "راستے سے کوئی رکاوٹ یا کوڑا ہٹائیں۔ نبی ﷺ نے فرمایا: راستے سے تکلیف دہ چیز ہٹانا صدقہ ہے۔",
    description_ar:
      "أزل عائقًا أو أذىً من الطريق. قال النبي ﷺ: إماطة الأذى عن الطريق صدقة.",
    category: "community",
    subcategory: "service",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 50,
    completionType: "daily",
    difficulty: "easy",
    source: "Sahih al-Bukhari 2989",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_011",
    title_en: "Etiquettes of the Masjid",
    title_bn: "মসজিদের আদব",
    title_ur: "مسجد کے آداب",
    title_ar: "آداب المسجد",
    description_en:
      "Watch this lesson on the Sunnah etiquettes of entering and leaving the masjid, including the recommended duas.",
    description_bn:
      "মসজিদে প্রবেশ ও বের হওয়ার সুন্নাহ আদব সম্পর্কে এই পাঠ দেখুন, প্রস্তাবিত দোয়াসহ।",
    description_ur:
      "مسجد میں داخل ہونے اور نکلنے کے سنت آداب کے بارے میں یہ سبق دیکھیں، مسنون دعاؤں سمیت۔",
    description_ar:
      "شاهد هذا الدرس عن آداب دخول المسجد والخروج منه مع الأدعية المسنونة.",
    category: "community",
    subcategory: "masjid",
    contentType: "video",
    videoUrl: PLACEHOLDER_VIDEO,
    videoThumbnailUrl: PLACEHOLDER_THUMB,
    duaText_en:
      "O Allah, open for me the doors of Your mercy. (entering) / O Allah, I ask You of Your bounty. (leaving)",
    duaText_ar:
      "اللّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ (دخول) / اللّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ (خروج)",
    noorCoins: 150,
    completionType: "once",
    difficulty: "easy",
    source: "Sahih Muslim 713",
    is_scholar_reviewed: true,
  },

  // ── SELF (3 amals: 1 video, 2 static) ─────────────────────────────────
  {
    id: "amal_012",
    title_en: "Morning Adhkar",
    title_bn: "সকালের আযকার",
    title_ur: "صبح کے اذکار",
    title_ar: "أذكار الصباح",
    description_en:
      "Recite the morning remembrances (adhkar) after Fajr. These include Ayat al-Kursi, the three Quls, and other supplications from the Sunnah that protect and bless your day.",
    description_bn:
      "ফজরের পর সকালের যিকিরগুলো (আযকার) পাঠ করুন। এর মধ্যে আয়াতুল কুরসি, তিনটি কুল এবং সুন্নাহ থেকে অন্যান্য দোয়া রয়েছে।",
    description_ur:
      "فجر کے بعد صبح کے اذکار پڑھیں۔ ان میں آیۃ الکرسی، تین قل اور سنت سے دیگر دعائیں شامل ہیں۔",
    description_ar:
      "اقرأ أذكار الصباح بعد صلاة الفجر. تشمل آية الكرسي والمعوذات وأدعية مأثورة تحفظك وتبارك يومك.",
    category: "self",
    subcategory: "dhikr",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en:
      "We have reached the morning and at this very time the whole kingdom belongs to Allah. All praise is due to Allah. None has the right to be worshipped except Allah, alone, without partner.",
    duaText_ar:
      "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ",
    noorCoins: 100,
    completionType: "daily",
    difficulty: "easy",
    source: "Abu Dawud 5077",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_013",
    title_en: "Fast a Monday or Thursday",
    title_bn: "সোমবার বা বৃহস্পতিবার রোজা রাখুন",
    title_ur: "سوموار یا جمعرات کا روزہ رکھیں",
    title_ar: "صيام يوم الاثنين أو الخميس",
    description_en:
      "Fast a voluntary fast on Monday or Thursday following the Sunnah. The Prophet ﷺ said: 'Deeds are shown (to Allah) on Mondays and Thursdays, and I like my deeds to be shown while I am fasting.'",
    description_bn:
      "সুন্নাহ অনুসরণ করে সোমবার বা বৃহস্পতিবার নফল রোজা রাখুন।",
    description_ur:
      "سنت کی پیروی میں سوموار یا جمعرات کو نفلی روزہ رکھیں۔",
    description_ar:
      "صم نافلة يوم الاثنين أو الخميس اتباعًا للسنة. قال النبي ﷺ: تُعرض الأعمال يوم الاثنين والخميس فأحب أن يُعرض عملي وأنا صائم.",
    category: "self",
    subcategory: "fasting",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 300,
    completionType: "daily",
    difficulty: "hard",
    source: "Sunan at-Tirmidhi 747",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_014",
    title_en: "Istighfar — Seek Forgiveness 100 Times",
    title_bn: "ইস্তিগফার — ১০০ বার ক্ষমা প্রার্থনা করুন",
    title_ur: "استغفار — ۱۰۰ مرتبہ معافی مانگیں",
    title_ar: "الاستغفار مئة مرة",
    description_en:
      "Watch this reminder about the virtue of istighfar, then say 'Astaghfirullah' 100 times. The Prophet ﷺ said: 'By Allah, I seek forgiveness from Allah and turn to Him in repentance more than seventy times a day.'",
    description_bn:
      "ইস্তিগফারের ফজিলত সম্পর্কে এই অনুস্মারক দেখুন, তারপর ১০০ বার 'আস্তাগফিরুল্লাহ' বলুন।",
    description_ur:
      "استغفار کی فضیلت کے بارے میں یہ یاد دہانی دیکھیں، پھر ۱۰۰ مرتبہ 'أستغفر الله' کہیں۔",
    description_ar:
      "شاهد هذا التذكير عن فضل الاستغفار ثم قل 'أستغفر الله' مئة مرة. قال النبي ﷺ: والله إني لأستغفر الله وأتوب إليه في اليوم أكثر من سبعين مرة.",
    category: "self",
    subcategory: "dhikr",
    contentType: "video",
    videoUrl: PLACEHOLDER_VIDEO,
    videoThumbnailUrl: PLACEHOLDER_THUMB,
    duaText_en: "I seek forgiveness from Allah.",
    duaText_ar: "أَسْتَغْفِرُ اللَّهَ",
    noorCoins: 100,
    completionType: "daily",
    difficulty: "easy",
    source: "Sahih al-Bukhari 6307",
    is_scholar_reviewed: true,
  },

  // ── KNOWLEDGE (3 amals: 1 video, 2 static) ───────────────────────────
  {
    id: "amal_015",
    title_en: "Memorise a New Ayah",
    title_bn: "একটি নতুন আয়াত মুখস্থ করুন",
    title_ur: "ایک نئی آیت حفظ کریں",
    title_ar: "احفظ آية جديدة",
    description_en:
      "Memorise one new ayah of the Quran today. Consistent daily memorisation, even one ayah, leads to great reward and connection with Allah's words.",
    description_bn:
      "আজ কুরআনের একটি নতুন আয়াত মুখস্থ করুন। প্রতিদিন একটি আয়াত হলেও ধারাবাহিক মুখস্থ করা মহান পুরস্কার ও আল্লাহর বাণীর সাথে সংযোগ আনে।",
    description_ur:
      "آج قرآن کی ایک نئی آیت حفظ کریں۔ روزانہ ایک آیت بھی مسلسل حفظ کرنا عظیم اجر اور اللہ کے کلام سے تعلق لاتا ہے۔",
    description_ar:
      "احفظ آية جديدة من القرآن اليوم. المداومة على حفظ آية واحدة يوميًا تقود لأجر عظيم وصلة بكلام الله.",
    category: "knowledge",
    subcategory: "quran",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 200,
    completionType: "daily",
    difficulty: "medium",
    source: "Sahih Muslim 803",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_016",
    title_en: "Learn a Hadith and Share It",
    title_bn: "একটি হাদিস শিখুন এবং শেয়ার করুন",
    title_ur: "ایک حدیث سیکھیں اور سنائیں",
    title_ar: "تعلّم حديثًا وانشره",
    description_en:
      "Learn one authentic hadith today and share it with someone. The Prophet ﷺ said: 'Convey from me, even if it is one ayah.'",
    description_bn:
      "আজ একটি সহীহ হাদিস শিখুন এবং কাউকে শেয়ার করুন। নবী ﷺ বলেছেন: 'আমার পক্ষ থেকে পৌঁছে দাও, যদিও একটি আয়াত হয়।'",
    description_ur:
      "آج ایک صحیح حدیث سیکھیں اور کسی کو سنائیں۔ نبی ﷺ نے فرمایا: میری طرف سے پہنچاؤ چاہے ایک آیت ہی ہو۔",
    description_ar:
      "تعلّم حديثًا صحيحًا اليوم وشاركه مع غيرك. قال النبي ﷺ: بلّغوا عني ولو آية.",
    category: "knowledge",
    subcategory: "hadith",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 150,
    completionType: "daily",
    difficulty: "easy",
    source: "Sahih al-Bukhari 3461",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_017",
    title_en: "The Story of Prophet Yusuf (AS)",
    title_bn: "নবী ইউসুফ (আঃ)-এর কাহিনী",
    title_ur: "نبی یوسف علیہ السلام کا قصہ",
    title_ar: "قصة النبي يوسف عليه السلام",
    description_en:
      "Watch this lesson on the story of Prophet Yusuf (AS), described by Allah as 'the best of stories'. Reflect on the lessons of patience, trust in Allah, and forgiveness.",
    description_bn:
      "আল্লাহ যাকে 'সর্বোত্তম কাহিনী' বলেছেন সেই নবী ইউসুফ (আঃ)-এর কাহিনী নিয়ে এই পাঠ দেখুন।",
    description_ur:
      "نبی یوسف علیہ السلام کے قصے پر یہ سبق دیکھیں جسے اللہ نے 'بہترین قصہ' قرار دیا۔",
    description_ar:
      "شاهد هذا الدرس عن قصة النبي يوسف عليه السلام التي وصفها الله بأحسن القصص. تأمّل دروس الصبر والتوكل والعفو.",
    category: "knowledge",
    subcategory: "stories",
    contentType: "video",
    videoUrl: PLACEHOLDER_VIDEO,
    videoThumbnailUrl: PLACEHOLDER_THUMB,
    duaText_en:
      "We relate to you the best of stories in what We have revealed to you of this Quran.",
    duaText_ar:
      "نَحْنُ نَقُصُّ عَلَيْكَ أَحْسَنَ الْقَصَصِ بِمَا أَوْحَيْنَا إِلَيْكَ هَٰذَا الْقُرْآنَ",
    noorCoins: 200,
    completionType: "once",
    difficulty: "easy",
    source: "Quran 12:3",
    is_scholar_reviewed: true,
  },

  // ── CHARITY (3 amals: 0 video, 3 static) ──────────────────────────────
  {
    id: "amal_018",
    title_en: "Give Sadaqah Today",
    title_bn: "আজ সদকা দিন",
    title_ur: "آج صدقہ دیں",
    title_ar: "تصدّق اليوم",
    description_en:
      "Give any amount of charity today, even if small. The Prophet ﷺ said: 'Protect yourself from the Fire even with half a date (in charity).'",
    description_bn:
      "আজ যেকোনো পরিমাণ দান করুন, যদিও তা অল্প হয়। নবী ﷺ বলেছেন: 'অর্ধেক খেজুর দিয়ে হলেও জাহান্নামের আগুন থেকে বাঁচো।'",
    description_ur:
      "آج کچھ بھی صدقہ دیں، چاہے تھوڑا ہی ہو۔ نبی ﷺ نے فرمایا: آگ سے بچو چاہے آدھی کھجور ہی (صدقے میں) دے کر۔",
    description_ar:
      "تصدّق اليوم بأي مبلغ ولو قليلًا. قال النبي ﷺ: اتقوا النار ولو بشق تمرة.",
    category: "charity",
    subcategory: "monetary",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 200,
    completionType: "daily",
    difficulty: "easy",
    source: "Sahih al-Bukhari 1417",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_019",
    title_en: "Smile at Your Brother or Sister",
    title_bn: "আপনার ভাই বা বোনের দিকে হাসুন",
    title_ur: "اپنے بھائی یا بہن کو مسکرا کر دیکھیں",
    title_ar: "تبسّمك في وجه أخيك صدقة",
    description_en:
      "Smile at a fellow Muslim today. The Prophet ﷺ said: 'Your smiling in the face of your brother is an act of charity.'",
    description_bn:
      "আজ একজন সহমুসলিমের দিকে হাসুন। নবী ﷺ বলেছেন: 'তোমার ভাইয়ের মুখে হাসি দেওয়া সদকা।'",
    description_ur:
      "آج ایک مسلمان بھائی کو دیکھ کر مسکرائیں۔ نبی ﷺ نے فرمایا: تمہارا اپنے بھائی کے سامنے مسکرانا صدقہ ہے۔",
    description_ar:
      "ابتسم في وجه أخيك المسلم اليوم. قال النبي ﷺ: تبسّمك في وجه أخيك لك صدقة.",
    category: "charity",
    subcategory: "kindness",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 50,
    completionType: "daily",
    difficulty: "easy",
    source: "Sunan at-Tirmidhi 1956",
    is_scholar_reviewed: true,
  },
  {
    id: "amal_020",
    title_en: "Feed a Fasting Person",
    title_bn: "একজন রোজাদারকে ইফতার করান",
    title_ur: "کسی روزہ دار کو افطار کروائیں",
    title_ar: "تفطير صائم",
    description_en:
      "Provide iftar or a meal to someone who is fasting. The Prophet ﷺ said: 'Whoever gives food to a fasting person to break his fast will have a reward like his without decreasing the fasting person's reward at all.'",
    description_bn:
      "যে কেউ রোজা রাখছেন তাকে ইফতার বা খাবার দিন। নবী ﷺ বলেছেন: 'যে ব্যক্তি একজন রোজাদারকে ইফতার করায় তার জন্য রোজাদারের সমান সওয়াব আছে।'",
    description_ur:
      "کسی روزے دار کو افطار یا کھانا کھلائیں۔ نبی ﷺ نے فرمایا: جس نے کسی روزے دار کو افطار کروایا اسے بھی اتنا ہی اجر ملے گا بغیر روزے دار کے اجر میں کمی کے۔",
    description_ar:
      "أطعم صائمًا أو قدّم له إفطارًا. قال النبي ﷺ: من فطّر صائمًا كان له مثل أجره غير أنه لا ينقص من أجر الصائم شيئًا.",
    category: "charity",
    subcategory: "food",
    contentType: "static",
    videoUrl: null,
    videoThumbnailUrl: null,
    duaText_en: null,
    duaText_ar: null,
    noorCoins: 300,
    completionType: "daily",
    difficulty: "medium",
    source: "Sunan at-Tirmidhi 807",
    is_scholar_reviewed: true,
  },
];

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function seed() {
  const collection = db.collection("amals");

  // Idempotency check: skip if documents already exist
  const snapshot = await collection.limit(1).get();
  if (!snapshot.empty) {
    console.log(
      "⏭  amals collection already contains documents — skipping seed.",
    );
    process.exit(0);
  }

  const batch = db.batch();
  const now = Timestamp.now();

  for (const amal of amals) {
    const docRef = collection.doc(amal.id);
    batch.set(docRef, {
      ...amal,
      createdAt: now,
      isActive: true,
    });
  }

  await batch.commit();
  console.log(`✅  Seeded ${amals.length} amals successfully.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error("❌  Seeding failed:", err);
  process.exit(1);
});
