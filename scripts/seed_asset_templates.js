'use strict';

const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

// ── Helper: slug ID from English name ────────────────────────────────────
function toId(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_|_$/g, '');
}

// ══════════════════════════════════════════════════════════════════════════
// ASSET DEFINITIONS
// ══════════════════════════════════════════════════════════════════════════

const SACRED = [
  {
    nameEn: 'Sidrat al-Muntaha',
    nameBn: 'সিদরাতুল মুনতাহা',
    nameAr: 'سِدْرَة الْمُنْتَهَىٰ',
    nameUr: 'سدرۃ المنتہیٰ',
    ncPrice: 25000,
    referenceEn: 'Quran 53:14',
    referenceTextAr: 'عِندَ سِدْرَةِ الْمُنتَهَىٰ',
  },
  {
    nameEn: 'Qasr al-Jannah',
    nameBn: 'কসর আল-জান্নাহ',
    nameAr: 'قَصْر الْجَنَّة',
    nameUr: 'قصر الجنّہ',
    ncPrice: 22000,
    referenceEn: 'Hadith (Sahih Bukhari)',
    referenceTextAr: 'إِنَّ فِي الْجَنَّةِ لَقَصْرًا',
  },
  {
    nameEn: 'Grand Mosque of Light',
    nameBn: 'আলোর মহা মসজিদ',
    nameAr: 'مَسْجِد النُّور الْكَبِير',
    nameUr: 'مسجدِ نورِ کبیر',
    ncPrice: 20000,
    referenceEn: 'Original',
    referenceTextAr: 'بِسْمِ اللَّهِ النُّورِ',
  },
  {
    nameEn: 'The Pearl Dome',
    nameBn: 'মুক্তার গম্বুজ',
    nameAr: 'قُبَّة اللُّؤْلُؤ',
    nameUr: 'موتی کا گنبد',
    ncPrice: 18000,
    referenceEn: 'Original',
    referenceTextAr: 'لُؤْلُؤٌ وَمَرْجَان',
  },
  {
    nameEn: 'Kawthar River',
    nameBn: 'কাউসার নদী',
    nameAr: 'نَهْر الْكَوْثَر',
    nameUr: 'نہرِ کوثر',
    ncPrice: 18000,
    referenceEn: 'Quran 108:1',
    referenceTextAr: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
  },
  {
    nameEn: 'River of Milk',
    nameBn: 'দুধের নদী',
    nameAr: 'نَهْر مِن لَّبَن',
    nameUr: 'دودھ کی نہر',
    ncPrice: 14000,
    referenceEn: 'Quran 47:15',
    referenceTextAr: 'أَنْهَارٌ مِّن لَّبَنٍ لَّمْ يَتَغَيَّرْ طَعْمُهُ',
  },
  {
    nameEn: 'River of Honey',
    nameBn: 'মধুর নদী',
    nameAr: 'نَهْر مِنْ عَسَل',
    nameUr: 'شہد کی نہر',
    ncPrice: 14000,
    referenceEn: 'Quran 47:15',
    referenceTextAr: 'وَأَنْهَارٌ مِّنْ عَسَلٍ مُّصَفًّى',
  },
  {
    nameEn: 'River of Pure Water',
    nameBn: 'বিশুদ্ধ পানির নদী',
    nameAr: 'نَهْر مِن مَّاءٍ غَيْرِ آسِن',
    nameUr: 'صاف پانی کی نہر',
    ncPrice: 12000,
    referenceEn: 'Quran 47:15',
    referenceTextAr: 'أَنْهَارٌ مِّن مَّاءٍ غَيْرِ آسِنٍ',
  },
  {
    nameEn: 'The Rainbow Arch',
    nameBn: 'রংধনু তোরণ',
    nameAr: 'قَوْس قُزَح النُّور',
    nameUr: 'قوسِ قزح',
    ncPrice: 15000,
    referenceEn: 'Original',
    referenceTextAr: 'قَوْسُ النُّورِ',
  },
  {
    nameEn: 'Crystal Minaret',
    nameBn: 'স্ফটিক মিনার',
    nameAr: 'مِئْذَنَة الْبِلَّوْر',
    nameUr: 'بلور کا مینار',
    ncPrice: 14000,
    referenceEn: 'Original',
    referenceTextAr: 'مِئْذَنَةٌ مِن بِلَّوْرٍ',
  },
  {
    nameEn: 'The Great Waterfall',
    nameBn: 'মহা জলপ্রপাত',
    nameAr: 'الشَّلَّال الْعَظِيم',
    nameUr: 'عظیم آبشار',
    ncPrice: 13000,
    referenceEn: 'Original',
    referenceTextAr: 'شَلَّالُ الْجَنَّة',
  },
  {
    nameEn: 'The Eternal Spring',
    nameBn: 'চিরন্তন ঝর্ণা',
    nameAr: 'عَيْن الْخُلُود',
    nameUr: 'چشمۂ جاوید',
    ncPrice: 10000,
    referenceEn: 'Original',
    referenceTextAr: 'عَيْنٌ لَا تَنْضُب',
  },
];

const PREMIUM_TREES = [
  {
    nameEn: 'Date Palm',
    nameBn: 'খেজুর গাছ',
    nameAr: 'نَخْلَة',
    nameUr: 'کھجور کا درخت',
    ncPrice: 8000,
    category: 'trees',
    referenceEn: 'Quran 55:68',
    referenceTextAr: 'فِيهِمَا فَاكِهَةٌ وَنَخْلٌ وَرُمَّانٌ',
  },
  {
    nameEn: 'Pomegranate Tree',
    nameBn: 'ডালিম গাছ',
    nameAr: 'شَجَرَة الرُّمَّان',
    nameUr: 'انار کا درخت',
    ncPrice: 7000,
    category: 'trees',
    referenceEn: 'Quran 55:68',
    referenceTextAr: 'وَنَخْلٌ وَرُمَّانٌ',
  },
  {
    nameEn: 'Fig Tree',
    nameBn: 'ডুমুর গাছ',
    nameAr: 'شَجَرَة التِّين',
    nameUr: 'انجیر کا درخت',
    ncPrice: 6000,
    category: 'trees',
    referenceEn: 'Quran 95:1',
    referenceTextAr: 'وَالتِّينِ وَالزَّيْتُونِ',
  },
  {
    nameEn: 'Olive Tree',
    nameBn: 'জলপাই গাছ',
    nameAr: 'شَجَرَة الزَّيْتُون',
    nameUr: 'زیتون کا درخت',
    ncPrice: 6500,
    category: 'trees',
    referenceEn: 'Quran 24:35',
    referenceTextAr: 'شَجَرَةٍ مُّبَارَكَةٍ زَيْتُونَةٍ',
  },
  {
    nameEn: 'Grape Canopy',
    nameBn: 'আঙুর লতা',
    nameAr: 'عَرِيش الْعِنَب',
    nameUr: 'انگور کی چھتری',
    ncPrice: 7500,
    category: 'trees',
    referenceEn: 'Quran 56:29',
    referenceTextAr: 'وَطَلْحٍ مَّنضُودٍ',
  },
  {
    nameEn: 'Mango Grove',
    nameBn: 'আমের বাগান',
    nameAr: 'بُسْتَان الْمَانْجُو',
    nameUr: 'آم کا باغ',
    ncPrice: 5500,
    category: 'trees',
    referenceEn: 'Original',
    referenceTextAr: 'بُسْتَانُ الثِّمَار',
  },
  {
    nameEn: 'The Ancient Banyan',
    nameBn: 'প্রাচীন বটগাছ',
    nameAr: 'شَجَرَة التِّين الْمُعَمَّرة',
    nameUr: 'قدیم برگد',
    ncPrice: 9000,
    category: 'trees',
    referenceEn: 'Original',
    referenceTextAr: 'الشَّجَرَةُ الْعَتِيقَة',
  },
  {
    nameEn: 'Celestial Cherry Blossom',
    nameBn: 'স্বর্গীয় চেরি ফুল',
    nameAr: 'زَهْر الْكَرَز السَّمَاوِي',
    nameUr: 'آسمانی چیری بلاسم',
    ncPrice: 8500,
    category: 'trees',
    referenceEn: 'Original',
    referenceTextAr: 'زَهْرَةٌ سَمَاوِيَّة',
  },
];

const PREMIUM_FRUITS = [
  {
    nameEn: 'Floating Fruit Clusters',
    nameBn: 'ভাসমান ফলের গুচ্ছ',
    nameAr: 'عَنَاقِيد الْفَوَاكِه الْمُعَلَّقَة',
    nameUr: 'تیرتے پھلوں کے گچھے',
    ncPrice: 5500,
    category: 'fruits',
    referenceEn: 'Quran 56:29',
    referenceTextAr: 'وَفَاكِهَةٍ كَثِيرَةٍ',
  },
  {
    nameEn: 'Strawberry Meadow',
    nameBn: 'স্ট্রবেরি মাঠ',
    nameAr: 'مَرْج الْفَرَاوِلَة',
    nameUr: 'اسٹرابیری کا میدان',
    ncPrice: 5000,
    category: 'fruits',
    referenceEn: 'Original',
    referenceTextAr: 'مَرْجُ الثِّمَار',
  },
  {
    nameEn: 'Citrus Garden',
    nameBn: 'সাইট্রাস বাগান',
    nameAr: 'حَدِيقَة الْحَمْضِيَّات',
    nameUr: 'لیموں کا باغ',
    ncPrice: 5500,
    category: 'fruits',
    referenceEn: 'Original',
    referenceTextAr: 'حَدِيقَةٌ نَضِرَة',
  },
  {
    nameEn: 'Paradise Melon Patch',
    nameBn: 'জান্নাতি তরমুজ ক্ষেত',
    nameAr: 'حَقْل بِطِّيخ الْجَنَّة',
    nameUr: 'جنت کی خربوزے کی کیاری',
    ncPrice: 5000,
    category: 'fruits',
    referenceEn: 'Original',
    referenceTextAr: 'فَوَاكِهُ الْجَنَّة',
  },
];

const PREMIUM_CREATURES = [
  {
    nameEn: 'White Peacock',
    nameBn: 'সাদা ময়ূর',
    nameAr: 'طَاوُوس أَبْيَض',
    nameUr: 'سفید مور',
    ncPrice: 9000,
    category: 'creatures',
    referenceEn: 'Original',
    referenceTextAr: 'طَاوُوسُ الْجَنَّة',
  },
  {
    nameEn: 'White Horse of Jannah',
    nameBn: 'জান্নাতের সাদা ঘোড়া',
    nameAr: 'فَرَس الْجَنَّة الْأَبْيَض',
    nameUr: 'جنت کا سفید گھوڑا',
    ncPrice: 8500,
    category: 'creatures',
    referenceEn: 'Original',
    referenceTextAr: 'فَرَسُ النُّور',
  },
  {
    nameEn: 'Butterflies of Light',
    nameBn: 'আলোর প্রজাপতি',
    nameAr: 'فَرَاشَات النُّور',
    nameUr: 'نور کی تتلیاں',
    ncPrice: 6000,
    category: 'creatures',
    referenceEn: 'Original',
    referenceTextAr: 'فَرَاشَاتٌ مُضِيئَة',
  },
  {
    nameEn: 'Blessed Honeybees',
    nameBn: 'বরকতময় মৌমাছি',
    nameAr: 'نَحْل مُبَارَك',
    nameUr: 'مبارک شہد کی مکھیاں',
    ncPrice: 5500,
    category: 'creatures',
    referenceEn: 'Original',
    referenceTextAr: 'وَأَوْحَىٰ رَبُّكَ إِلَى النَّحْلِ',
  },
];

const PREMIUM_WATER = [
  {
    nameEn: 'Medium Waterfall',
    nameBn: 'মাঝারি জলপ্রপাত',
    nameAr: 'شَلَّال مُتَوَسِّط',
    nameUr: 'درمیانی آبشار',
    ncPrice: 7000,
    category: 'water',
    referenceEn: 'Original',
    referenceTextAr: 'شَلَّالٌ جَارٍ',
  },
  {
    nameEn: 'Lotus Lake',
    nameBn: 'পদ্ম হ্রদ',
    nameAr: 'بُحَيْرَة اللُّوتَس',
    nameUr: 'کنول کی جھیل',
    ncPrice: 8000,
    category: 'water',
    referenceEn: 'Original',
    referenceTextAr: 'بُحَيْرَةٌ هَادِئَة',
  },
  {
    nameEn: 'River Bend',
    nameBn: 'নদীর বাঁক',
    nameAr: 'مُنْعَطَف النَّهْر',
    nameUr: 'ندی کا موڑ',
    ncPrice: 7500,
    category: 'water',
    referenceEn: 'Original',
    referenceTextAr: 'مَجْرَى النَّهْر',
  },
  {
    nameEn: 'Koi Pond',
    nameBn: 'কই পুকুর',
    nameAr: 'بِرْكَة الْأَسْمَاك',
    nameUr: 'کوئی مچھلی کا تالاب',
    ncPrice: 6000,
    category: 'water',
    referenceEn: 'Original',
    referenceTextAr: 'بِرْكَةٌ صَافِيَة',
  },
];

const STANDARD = [
  { nameEn: 'Crystal Fountain',   nameBn: 'স্ফটিক ফোয়ারা',    nameAr: 'نَافُورَة الْبِلَّوْر',    nameUr: 'بلوری فوارہ',       ncPrice: 2500, category: 'structures' },
  { nameEn: 'Golden Arch',        nameBn: 'সোনালি তোরণ',       nameAr: 'قَوْس ذَهَبِي',           nameUr: 'سنہری محراب',       ncPrice: 3500, category: 'structures' },
  { nameEn: 'Prayer Stone',       nameBn: 'নামাজের পাথর',      nameAr: 'حَجَر الصَّلَاة',          nameUr: 'نماز کا پتھر',      ncPrice: 2000, category: 'structures' },
  { nameEn: 'Still Pond',         nameBn: 'স্থির পুকুর',        nameAr: 'بِرْكَة سَاكِنَة',         nameUr: 'ساکن تالاب',        ncPrice: 2500, category: 'water' },
  { nameEn: 'Jasmine Archway',    nameBn: 'জুঁই ফুলের তোরণ',    nameAr: 'قَوْس الْيَاسَمِين',       nameUr: 'چمیلی کا محراب',    ncPrice: 3000, category: 'flowers' },
  { nameEn: 'Small Mosque',       nameBn: 'ছোট মসজিদ',         nameAr: 'مَسْجِد صَغِير',           nameUr: 'چھوٹی مسجد',       ncPrice: 4000, category: 'structures' },
  { nameEn: 'Noor Lanterns',      nameBn: 'নূরের লণ্ঠন',        nameAr: 'فَوَانِيس النُّور',        nameUr: 'نور کی لالٹینیں',   ncPrice: 2000, category: 'structures' },
  { nameEn: 'Rose Garden',        nameBn: 'গোলাপ বাগান',        nameAr: 'حَدِيقَة الْوَرْد',        nameUr: 'گلاب کا باغ',       ncPrice: 2500, category: 'flowers' },
  { nameEn: 'Lily Field',         nameBn: 'লিলি মাঠ',           nameAr: 'حَقْل الزَّنْبَق',         nameUr: 'للی کا میدان',      ncPrice: 2500, category: 'flowers' },
  { nameEn: 'Olive Sapling',      nameBn: 'জলপাই চারা',         nameAr: 'شَتْلَة زَيْتُون',         nameUr: 'زیتون کا پودا',     ncPrice: 2000, category: 'plants' },
  { nameEn: 'Willow Tree',        nameBn: 'উইলো গাছ',           nameAr: 'شَجَرَة الصَّفْصَاف',      nameUr: 'بید کا درخت',       ncPrice: 3500, category: 'plants' },
  { nameEn: 'Bamboo Grove',       nameBn: 'বাঁশ ঝাড়',           nameAr: 'غَابَة الْخَيْزُرَان',     nameUr: 'بانس کا جھنڈ',     ncPrice: 3000, category: 'plants' },
  { nameEn: 'Herb Garden',        nameBn: 'ভেষজ বাগান',         nameAr: 'حَدِيقَة الْأَعْشَاب',     nameUr: 'جڑی بوٹیوں کا باغ', ncPrice: 2000, category: 'plants' },
  { nameEn: 'Mushroom Circle',    nameBn: 'মাশরুম বৃত্ত',        nameAr: 'دَائِرَة الْفُطْر',        nameUr: 'کھمبیوں کا دائرہ', ncPrice: 2000, category: 'plants' },
];

const COMMON = [
  { nameEn: 'White Roses',        nameBn: 'সাদা গোলাপ',         nameAr: 'وُرُود بَيْضَاء',          nameUr: 'سفید گلاب',         ncPrice: 1000, category: 'flowers' },
  { nameEn: 'Jasmine Clusters',   nameBn: 'জুঁই গুচ্ছ',          nameAr: 'عَنَاقِيد الْيَاسَمِين',   nameUr: 'چمیلی کے گچھے',    ncPrice: 1200, category: 'flowers' },
  { nameEn: 'Golden Lilies',      nameBn: 'সোনালি লিলি',        nameAr: 'زَنَابِق ذَهَبِيَّة',      nameUr: 'سنہری للی',         ncPrice: 1000, category: 'flowers' },
  { nameEn: 'Lavender Field',     nameBn: 'ল্যাভেন্ডার মাঠ',     nameAr: 'حَقْل الْخُزَامَى',        nameUr: 'لیونڈر کا میدان',   ncPrice: 1000, category: 'flowers' },
  { nameEn: 'Meadow Grass Patch', nameBn: 'তৃণভূমি',             nameAr: 'رُقْعَة عُشْب',            nameUr: 'گھاس کا ٹکڑا',     ncPrice: 1000, category: 'plants' },
  { nameEn: 'Lotus Bloom',        nameBn: 'পদ্ম ফুল',            nameAr: 'زَهْرَة اللُّوتَس',        nameUr: 'کنول کا پھول',      ncPrice: 1500, category: 'flowers' },
  { nameEn: 'Noor Lantern Single', nameBn: 'একক নূর লণ্ঠন',     nameAr: 'فَانُوس النُّور',          nameUr: 'نور کی لالٹین',     ncPrice: 1500, category: 'plants' },
  { nameEn: 'Moss Carpet',        nameBn: 'শৈবাল গালিচা',       nameAr: 'سَجَّادَة الطُّحْلُب',     nameUr: 'کائی کا قالین',     ncPrice: 1000, category: 'plants' },
  { nameEn: 'Wildflower Scatter', nameBn: 'বুনো ফুলের ছড়া',     nameAr: 'زُهُور بَرِّيَّة مُنْتَشِرَة', nameUr: 'جنگلی پھولوں کی بکھری', ncPrice: 1000, category: 'flowers' },
];

const WATER_OCEAN = [
  {
    nameEn: 'Paradise Ocean',
    nameBn: 'জান্নাতের মহাসাগর',
    nameAr: 'مُحِيط الْجَنَّة',
    nameUr: 'جنت کا سمندر',
    ncPrice: 20000,
    referenceEn: 'Original',
    referenceTextAr: 'بَحْرُ الْخُلُود',
  },
  {
    nameEn: 'Ocean Waterfall',
    nameBn: 'সমুদ্র জলপ্রপাত',
    nameAr: 'شَلَّال الْمُحِيط',
    nameUr: 'سمندری آبشار',
    ncPrice: 15000,
    referenceEn: 'Original',
    referenceTextAr: 'شَلَّالُ الْبَحْر',
  },
  {
    nameEn: 'Crystal Cave',
    nameBn: 'স্ফটিক গুহা',
    nameAr: 'كَهْف الْبِلَّوْر',
    nameUr: 'بلوری غار',
    ncPrice: 10000,
    referenceEn: 'Original',
    referenceTextAr: 'كَهْفٌ مِن بِلَّوْر',
  },
  {
    nameEn: 'Underwater Mosque Ruins',
    nameBn: 'পানির নিচে মসজিদের ধ্বংসাবশেষ',
    nameAr: 'آثَار مَسْجِد تَحْتَ الْمَاء',
    nameUr: 'زیرآب مسجد کے کھنڈرات',
    ncPrice: 12000,
    referenceEn: 'Original',
    referenceTextAr: 'مَسْجِدٌ غَارِق',
  },
  {
    nameEn: 'Pearl Beds',
    nameBn: 'মুক্তার বিছানা',
    nameAr: 'أَسِرَّة اللُّؤْلُؤ',
    nameUr: 'موتیوں کے بستر',
    ncPrice: 8000,
    referenceEn: 'Original',
    referenceTextAr: 'لُؤْلُؤٌ مَنثُور',
  },
  {
    nameEn: 'Whale of Light',
    nameBn: 'আলোর তিমি',
    nameAr: 'حُوت النُّور',
    nameUr: 'نور کی وہیل',
    ncPrice: 9000,
    referenceEn: 'Quran 37:142 (Yunus)',
    referenceTextAr: 'فَالْتَقَمَهُ الْحُوتُ',
  },
  {
    nameEn: 'Glowing Coral Garden',
    nameBn: 'জ্বলন্ত প্রবাল বাগান',
    nameAr: 'حَدِيقَة الْمَرْجَان الْمُضِيئَة',
    nameUr: 'چمکتا مرجان باغ',
    ncPrice: 6000,
    referenceEn: 'Original',
    referenceTextAr: 'مَرْجَانٌ مُنِير',
  },
  {
    nameEn: 'Luminescent Fish Schools',
    nameBn: 'জ্যোতির্ময় মাছের ঝাঁক',
    nameAr: 'أَسْرَاب السَّمَك الْمُضِيئَة',
    nameUr: 'چمکدار مچھلیوں کے غول',
    ncPrice: 5000,
    referenceEn: 'Original',
    referenceTextAr: 'سَمَكٌ مُنِير',
  },
  {
    nameEn: 'Treasure Chest of Noor',
    nameBn: 'নূরের ধনসিন্দুক',
    nameAr: 'صُنْدُوق كَنْز النُّور',
    nameUr: 'نور کا خزانہ',
    ncPrice: 5000,
    referenceEn: 'Original',
    referenceTextAr: 'كَنْزُ النُّور',
  },
  {
    nameEn: 'Jellyfish Bloom',
    nameBn: 'জেলিফিশ প্রস্ফুটন',
    nameAr: 'إِزْهَار قِنْدِيل الْبَحْر',
    nameUr: 'جیلی فش بلوم',
    ncPrice: 4000,
    referenceEn: 'Original',
    referenceTextAr: 'قَنَادِيلُ الْبَحْر',
  },
  {
    nameEn: 'Glowing Tidal Pools',
    nameBn: 'জ্বলন্ত জোয়ারের পুকুর',
    nameAr: 'بِرَك الْمَدّ الْمُضِيئَة',
    nameUr: 'چمکتے جوار کے تالاب',
    ncPrice: 3000,
    referenceEn: 'Original',
    referenceTextAr: 'بِرَكُ النُّور',
  },
  {
    nameEn: 'Sandy Paradise Shore',
    nameBn: 'বালুকাময় জান্নাতি তীর',
    nameAr: 'شَاطِئ الْجَنَّة الرَّمْلِي',
    nameUr: 'ریتیلا جنت کا ساحل',
    ncPrice: 2500,
    referenceEn: 'Original',
    referenceTextAr: 'شَاطِئُ الْجَنَّة',
  },
];

// ── Hayat Products (separate collection) ─────────────────────────────────
const HAYAT_PRODUCTS = [
  {
    id: 'hayat_drop',
    name: 'Hayat Drop',
    nameAr: 'قَطْرَة الْحَيَاة',
    nameBn: 'হায়াত ড্রপ',
    nameUr: 'حیات ڈراپ',
    ncPrice: 2500,
    usdPrice: 0.50,
    type: 'single_restore',
  },
  {
    id: 'hayat_bloom',
    name: 'Hayat Bloom',
    nameAr: 'إِزْهَار الْحَيَاة',
    nameBn: 'হায়াত ব্লুম',
    nameUr: 'حیات بلوم',
    ncPrice: 8000,
    usdPrice: 1.50,
    type: 'full_restore',
  },
];

// ══════════════════════════════════════════════════════════════════════════
// BUILD FULL DOCUMENTS
// ══════════════════════════════════════════════════════════════════════════

function buildDoc(asset, tier, defaultCategory) {
  return {
    nameEn: asset.nameEn,
    nameBn: asset.nameBn,
    nameAr: asset.nameAr,
    nameUr: asset.nameUr,
    tier,
    ncPrice: asset.ncPrice,
    category: asset.category || defaultCategory,
    referenceEn: asset.referenceEn || 'Original',
    referenceTextAr: asset.referenceTextAr || '',
    isLevelGated: tier === 'water_ocean',
    requiredLevel: tier === 'water_ocean' ? 4 : 1,
    isAvailableInShop: true,
    preLovedCount: 0,
    imageUrl: '',
    isScholarReviewed: true,
    isAvailable: true,
  };
}

const allAssets = [
  ...SACRED.map(a => ({ id: toId(a.nameEn), ...buildDoc(a, 'sacred', 'sacred') })),
  ...PREMIUM_TREES.map(a => ({ id: toId(a.nameEn), ...buildDoc(a, 'premium', 'trees') })),
  ...PREMIUM_FRUITS.map(a => ({ id: toId(a.nameEn), ...buildDoc(a, 'premium', 'fruits') })),
  ...PREMIUM_CREATURES.map(a => ({ id: toId(a.nameEn), ...buildDoc(a, 'premium', 'creatures') })),
  ...PREMIUM_WATER.map(a => ({ id: toId(a.nameEn), ...buildDoc(a, 'premium', 'water') })),
  ...STANDARD.map(a => ({ id: toId(a.nameEn), ...buildDoc(a, 'standard', 'structures') })),
  ...COMMON.map(a => ({ id: toId(a.nameEn), ...buildDoc(a, 'common', 'flowers') })),
  ...WATER_OCEAN.map(a => ({ id: toId(a.nameEn), ...buildDoc(a, 'water_ocean', 'water_ocean') })),
];

// ══════════════════════════════════════════════════════════════════════════
// SEED FUNCTION
// ══════════════════════════════════════════════════════════════════════════

async function seed() {
  console.log(`\nSeeding ${allAssets.length} asset templates + ${HAYAT_PRODUCTS.length} Hayat products...\n`);

  // Firestore batch limit is 500 — split if needed
  const BATCH_LIMIT = 500;

  for (let i = 0; i < allAssets.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    const slice = allAssets.slice(i, i + BATCH_LIMIT);

    for (const asset of slice) {
      const { id, ...data } = asset;
      const ref = db.collection('assetTemplates').doc(id);
      batch.set(ref, data);
    }

    await batch.commit();
    console.log(`  Committed assetTemplates batch ${Math.floor(i / BATCH_LIMIT) + 1} (${slice.length} docs)`);
  }

  // Hayat products (separate collection)
  const hayatBatch = db.batch();
  for (const product of HAYAT_PRODUCTS) {
    const { id, ...data } = product;
    const ref = db.collection('hayatProducts').doc(id);
    hayatBatch.set(ref, data);
  }
  await hayatBatch.commit();
  console.log(`  Committed ${HAYAT_PRODUCTS.length} Hayat products`);

  console.log(`\nDone! ${allAssets.length} assets + ${HAYAT_PRODUCTS.length} Hayat products seeded.\n`);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
