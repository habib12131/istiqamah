import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<dynamic> kAfter = [
 [
  "أَسْتَغْفِرُ اللَّهَ",
  "আস্তাগফিরুল্লাহ (৩ বার)",
  "সালামের পর ৩ বার ইস্তিগফার করা রাসূল ﷺ-এর নিয়মিত আমল। (সহিহ মুসলিম)"
 ],
 [
  "اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ",
  "আল্লাহুম্মা আনতাস সালামু ওয়া মিনকাস সালামু তাবারাকতা ইয়া যাল জালালি ওয়াল ইকরাম",
  "হে আল্লাহ, আপনিই শান্তিদাতা, আপনার কাছ থেকেই শান্তি। রাসূল ﷺ সালামের পর এটি পড়তেন। (সহিহ মুসলিম)"
 ],
 [
  "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
  "আয়াতুল কুরসি",
  "ফজিলত: প্রতি ফরজ নামাজের পর পড়লে জান্নাতে প্রবেশের পথে মৃত্যু ছাড়া আর কোনো বাধা থাকে না। (নাসায়ি)"
 ],
 [
  "سُبْحَانَ اللَّهِ ×৩৩   الْحَمْدُ لِلَّهِ ×৩৩   اللَّهُ أَكْبَرُ ×৩৪",
  "সুবহানাল্লাহ ৩৩, আলহামদুলিল্লাহ ৩৩, আল্লাহু আকবার ৩৪ বার",
  "ফজিলত: যে এটি পড়ে, তার গুনাহ সমুদ্রের ফেনার সমান হলেও মাফ করে দেওয়া হয়। (সহিহ মুসলিম)"
 ]
];

const List<dynamic> kDuas = [
 [
  "رَبِّ زِدْنِي عِلْمًا",
  "রাব্বি জিদনি ইলমা",
  "হে আমার রব, আমার জ্ঞান বাড়িয়ে দিন।"
 ],
 [
  "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
  "রাব্বানা আতিনা ফিদ্দুনিয়া হাসানাতাঁও ওয়া ফিল আখিরাতি হাসানাতাঁও ওয়া ক্বিনা আযাবান্নার",
  "হে আমাদের রব, দুনিয়া ও আখিরাতে কল্যাণ দিন এবং জাহান্নামের আযাব থেকে রক্ষা করুন।"
 ],
 [
  "بِسْمِ اللَّهِ",
  "বিসমিল্লাহ",
  "আল্লাহর নামে (খাওয়া বা কাজ শুরুর সময়)।"
 ],
 [
  "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
  "সুবহানাল্লাহি ওয়া বিহামদিহি",
  "আল্লাহ পবিত্র, সব প্রশংসা তাঁরই।"
 ],
 [
  "أَسْتَغْفِرُ اللَّهَ",
  "আস্তাগফিরুল্লাহ",
  "আমি আল্লাহর কাছে ক্ষমা চাই।"
 ],
 [
  "لَا إِلَٰهَ إِلَّا اللَّهُ",
  "লা ইলাহা ইল্লাল্লাহ",
  "আল্লাহ ছাড়া কোনো ইলাহ নেই।"
 ]
];

const List<dynamic> kSurahs = [
 [
  "আল-ফাতিহা",
  7,
  [
   "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
   "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
   "الرَّحْمَٰنِ الرَّحِيمِ",
   "مَالِكِ يَوْمِ الدِّينِ",
   "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
   "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
   "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ"
  ]
 ],
 [
  "আল-ইখলাস",
  4,
  [
   "قُلْ هُوَ اللَّهُ أَحَدٌ",
   "اللَّهُ الصَّمَدُ",
   "لَمْ يَلِدْ وَلَمْ يُولَدْ",
   "وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ"
  ]
 ]
];

String bn(Object x) =>
    x.toString().replaceAllMapped(RegExp(r'\d'), (m) => '০১২৩৪৫৬৭৮৯'[int.parse(m[0]!)]);

void main() => runApp(const IstiqamahApp());

class IstiqamahApp extends StatelessWidget {
  const IstiqamahApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ইস্তিকামাহ',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF0E5A55), useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF3FB5A8), brightness: Brightness.dark, useMaterial3: true),
        home: const HomeShell(),
      );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: tab, children: const [
        GatePage(),
        QuranPage(),
        DuaPage(),
        TasbihPage(),
        RoutinePage(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.lock_clock), label: 'গেট'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'কুরআন'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'দোয়া'),
          NavigationDestination(icon: Icon(Icons.touch_app), label: 'তাসবিহ'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'রুটিন'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- গেট

class GatePage extends StatefulWidget {
  const GatePage({super.key});
  @override
  State<GatePage> createState() => _GatePageState();
}

class _GatePageState extends State<GatePage> with WidgetsBindingObserver {
  static const _ch = MethodChannel('noor/blocker');
  static const names = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা'];

  List<DateTime> times = []; // গতকাল + আজ + আগামীকাল, প্রতিদিন ৫টি
  int confirmedAt = 0;
  bool force = false;
  bool usage = false, overlay = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
    _t = Timer.periodic(const Duration(seconds: 15), (_) => _sync());
  }

  @override
  void dispose() {
    _t?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      _perms();
      _sync();
    }
  }

  Future<void> _init() async {
    await _sync();
    await _loadTimes();
    await _perms();
  }

  Future<void> _sync() async {
    try {
      final m = await _ch.invokeMethod<Map>('getState');
      if (m != null) {
        confirmedAt = (m['confirmed'] as num).toInt();
        force = m['force'] == true;
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _loadTimes() async {
    // ডিফল্ট: রিয়াদ। লোকেশন পেলে সেটা ব্যবহার হবে।
    var lat = 24.7136, lng = 46.6753;
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)));
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {}
    // কারাচি পদ্ধতি + হানাফি আসর (বাংলাদেশে প্রচলিত)। দরকারমতো বদলান।
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    final list = <DateTime>[];
    for (final d in [-1, 0, 1]) {
      final date = DateTime.now().add(Duration(days: d));
      final pt = PrayerTimes(Coordinates(lat, lng), DateComponents.from(date), params);
      list.addAll([pt.fajr, pt.dhuhr, pt.asr, pt.maghrib, pt.isha].map((e) => e.toLocal()));
    }
    times = list;
    await _ch.invokeMethod('schedule', list.map((e) => e.millisecondsSinceEpoch).toList());
    if (mounted) setState(() {});
  }

  Future<void> _perms() async {
    final m = await _ch.invokeMethod<Map>('status');
    usage = m?['usage'] == true;
    overlay = m?['overlay'] == true;
    if (usage && overlay) await _ch.invokeMethod('start');
    if (mounted) setState(() {});
  }

  int? get lastIdx {
    final n = DateTime.now();
    int? r;
    for (var i = 0; i < times.length; i++) {
      if (!times[i].isAfter(n)) r = i;
    }
    return r;
  }

  bool get locked {
    final i = lastIdx;
    return force || (i != null && times[i].millisecondsSinceEpoch > confirmedAt);
  }

  Future<void> _confirm() async {
    await _ch.invokeMethod('confirm', DateTime.now().millisecondsSinceEpoch);
    await _sync();
  }

  Future<void> _testLock() async {
    await _ch.invokeMethod('testLock');
    await _sync();
  }

  String _fmt(DateTime t) =>
      '${(t.hour % 12 == 0 ? 12 : t.hour % 12)}:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final i = lastIdx;
    final lk = locked;
    final title = !lk
        ? 'আলহামদুলিল্লাহ, সব আদায় হয়েছে'
        : (force && i == null ? 'গেট লক আছে (পরীক্ষা)' : '${names[(i ?? 0) % 5]} নামাজ বাকি!');
    return Scaffold(
      appBar: AppBar(title: const Text('ইস্তিকামাহ – নামাজ গেট')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: lk ? cs.errorContainer : cs.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(lk
                  ? 'নামাজ পড়ে কনফার্ম না করা পর্যন্ত Facebook, TikTok, YouTube বন্ধ থাকবে।'
                  : 'এখন সব অ্যাপ খোলা। পরের ওয়াক্তে আবার গেট চালু হবে।'),
              if (lk) ...[
                const SizedBox(height: 14),
                FilledButton(onPressed: _confirm, child: const Text('আলহামদুলিল্লাহ, নামাজ পড়েছি')),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 8),
        if (!usage || !overlay) ...[
          Text('গেট চালু করতে ২টি অনুমতি দিন', style: Theme.of(context).textTheme.titleMedium),
          ListTile(
            leading: Icon(usage ? Icons.check_circle : Icons.circle_outlined),
            title: const Text('Usage Access'),
            subtitle: const Text('কোন অ্যাপ খোলা আছে তা বুঝতে'),
            onTap: () => _ch.invokeMethod('openUsage'),
          ),
          ListTile(
            leading: Icon(overlay ? Icons.check_circle : Icons.circle_outlined),
            title: const Text('অন্য অ্যাপের উপরে দেখানো'),
            subtitle: const Text('ব্লক করা অ্যাপের উপরে নামাজের স্ক্রিন দেখাতে'),
            onTap: () => _ch.invokeMethod('openOverlay'),
          ),
        ] else ...[
          const ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('গেট চালু আছে'),
            subtitle: Text('ব্যাকগ্রাউন্ডে পাহারা দিচ্ছে'),
          ),
          OutlinedButton(
              onPressed: _testLock, child: const Text('গেট পরীক্ষা করুন (এখনই লক করুন)')),
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('চাপার পর Facebook বা YouTube খুলে দেখুন। নামাজ কনফার্ম করলে লক খুলবে।'),
          ),
        ],
        const SizedBox(height: 12),
        Text('আজকের ওয়াক্ত', style: Theme.of(context).textTheme.titleMedium),
        if (times.length == 15)
          for (var k = 0; k < 5; k++)
            ListTile(dense: true, title: Text(names[k]), trailing: Text(_fmt(times[5 + k]))),
      ]),
    );
  }
}

// ---------------------------------------------------------------- কুরআন

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});
  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  double fs = 28;

  Widget _surah(BuildContext c, dynamic s) {
    final ay = s[2] as List;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('${s[0]} (${bn(s[1])} আয়াত)', style: Theme.of(c).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < ay.length; i++)
            Text('${ay[i]} ﴿${bn(i + 1)}﴾',
                textDirection: TextDirection.rtl, style: TextStyle(fontSize: fs, height: 2)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('কুরআন'), actions: [
        IconButton(
            onPressed: () => setState(() => fs = fs > 20 ? fs - 4 : fs),
            icon: const Icon(Icons.text_decrease)),
        IconButton(
            onPressed: () => setState(() => fs = fs < 44 ? fs + 4 : fs),
            icon: const Icon(Icons.text_increase)),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final s in kSurahs) _surah(context, s),
        const Text('এখন ২টি সূরা আছে। ১১৪ সূরা, বাংলা অনুবাদ ও অডিও পরের ধাপে যুক্ত হবে।'),
      ]),
    );
  }
}

// ---------------------------------------------------------------- দোয়া

class DuaPage extends StatelessWidget {
  const DuaPage({super.key});

  Widget _card(BuildContext c, dynamic d) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(d[0] as String,
                textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 24, height: 2)),
            const SizedBox(height: 6),
            Text(d[1] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(d[2] as String, style: TextStyle(color: Theme.of(c).colorScheme.onSurfaceVariant)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('দোয়া ও জিকির')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('প্রতি ফরজ নামাজের পর', style: tt),
        const SizedBox(height: 8),
        for (final d in kAfter) _card(context, d),
        const Text('ফজিলতগুলো প্রকাশের আগে একজন আলেম দিয়ে যাচাই করিয়ে নিন।'),
        const SizedBox(height: 16),
        Text('অন্যান্য দোয়া', style: tt),
        const SizedBox(height: 8),
        for (final d in kDuas) _card(context, d),
      ]),
    );
  }
}

// ---------------------------------------------------------------- তাসবিহ

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  static const dhikrs = ['সুবহানাল্লাহ', 'আলহামদুলিল্লাহ', 'আল্লাহু আকবার', 'আস্তাগফিরুল্লাহ'];
  static const goals = [33, 99, 100];
  int n = 0, total = 0, zi = 0, gi = 0;
  SharedPreferences? p;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    p = await SharedPreferences.getInstance();
    setState(() {
      total = p!.getInt('tt') ?? 0;
      n = p!.getInt('tn') ?? 0;
      zi = p!.getInt('tz') ?? 0;
      gi = p!.getInt('tg') ?? 0;
    });
  }

  void _save() {
    p?.setInt('tt', total);
    p?.setInt('tn', n);
    p?.setInt('tz', zi);
    p?.setInt('tg', gi);
  }

  void _tap() {
    setState(() {
      n++;
      total++;
      if (n > goals[gi]) n = 1;
    });
    HapticFeedback.lightImpact();
    _save();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('তাসবিহ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            DropdownButton<int>(
              value: zi,
              items: [for (var i = 0; i < dhikrs.length; i++) DropdownMenuItem(value: i, child: Text(dhikrs[i]))],
              onChanged: (v) {
                setState(() {
                  zi = v ?? 0;
                  n = 0;
                });
                _save();
              },
            ),
            DropdownButton<int>(
              value: gi,
              items: [for (var i = 0; i < goals.length; i++) DropdownMenuItem(value: i, child: Text('লক্ষ্য ${bn(goals[i])}'))],
              onChanged: (v) {
                setState(() {
                  gi = v ?? 0;
                  n = 0;
                });
                _save();
              },
            ),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: _tap,
            child: Container(
              width: 230,
              height: 230,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
              child: Text(bn(n),
                  style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: cs.onPrimary)),
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(value: n / goals[gi]),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('মোট গণনা: ${bn(total)}'),
            OutlinedButton(
                onPressed: () {
                  setState(() => n = 0);
                  _save();
                },
                child: const Text('রিসেট')),
          ]),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------- রুটিন

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});
  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  static const checks = [
    ['p0', 'ফজর নামাজ'],
    ['p1', 'যোহর নামাজ'],
    ['p2', 'আসর নামাজ'],
    ['p3', 'মাগরিব নামাজ'],
    ['p4', 'এশা নামাজ'],
    ['q', 'কুরআন তিলাওয়াত'],
    ['z', 'সকাল-সন্ধ্যার জিকির'],
    ['d', 'দুহা বা ইশরাকের ২ রাকাত'],
    ['s', 'ঘুমের আগে আয়াতুল কুরসি ও ৩ কুল'],
  ];
  static const days = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি'];

  Map<String, int> d = {};
  List<double> week = List<double>.filled(7, 0);
  SharedPreferences? p;

  static String keyFor(int off) {
    final n = DateTime.now().subtract(Duration(days: off));
    return 'rt_${n.year}-${n.month}-${n.day}';
  }

  static double score(Map<String, int> m) {
    var c = 0;
    for (final k in checks) {
      if ((m[k[0]] ?? 0) > 0) c++;
    }
    if ((m['h'] ?? 0) >= 8) c++;
    if ((m['w'] ?? 0) >= 30) c++;
    if ((m['e'] ?? 0) >= 20) c++;
    return c / 12;
  }

  Map<String, int> _dec(String? s) {
    if (s == null) return {};
    try {
      return (jsonDecode(s) as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _calcWeek() {
    week = [for (var o = 6; o >= 0; o--) score(_dec(p?.getString(keyFor(o))))];
  }

  Future<void> _load() async {
    p = await SharedPreferences.getInstance();
    d = _dec(p!.getString(keyFor(0)));
    _calcWeek();
    if (mounted) setState(() {});
  }

  void _set(String k, int v) {
    d[k] = v < 0 ? 0 : v;
    p?.setString(keyFor(0), jsonEncode(d));
    _calcWeek();
    setState(() {});
  }

  Widget _stepper(String k, String title, String sub, int step) {
    return ListTile(
      title: Text(title),
      subtitle: Text(sub),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(onPressed: () => _set(k, (d[k] ?? 0) - step), icon: const Icon(Icons.remove_circle_outline)),
        Text(bn(d[k] ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        IconButton(onPressed: () => _set(k, (d[k] ?? 0) + step), icon: const Icon(Icons.add_circle_outline)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme.titleMedium;
    final s = score(d);
    return Scaffold(
      appBar: AppBar(title: const Text('আজকের রুটিন')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${bn((s * 12).round())}/১২ সম্পন্ন (${bn((s * 100).round())}%)', style: tt),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: s),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text('ইসলামিক জীবনের আমল', style: tt),
        Card(
          child: Column(children: [
            for (final k in checks)
              CheckboxListTile(
                value: (d[k[0]] ?? 0) > 0,
                onChanged: (v) => _set(k[0], v == true ? 1 : 0),
                title: Text(k[1]),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        Text('সুস্থ শরীর', style: tt),
        Card(
          child: Column(children: [
            _stepper('h', 'পানি পান', 'গ্লাস (লক্ষ্য ৮, প্রায় ২ লিটার)', 1),
            _stepper('w', 'হাঁটা', 'মিনিট (লক্ষ্য ৩০, প্রায় ৩ কিমি)', 5),
            _stepper('e', 'ব্যায়াম', 'মিনিট (লক্ষ্য ২০)', 5),
          ]),
        ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
                'আজকের ব্যায়াম: ৫ মিনিট ওয়ার্ম-আপ, ১০টি পুশ-আপ, ১৫টি স্কোয়াট, ৩০ সেকেন্ড প্ল্যাঙ্ক (৩ সেট), শেষে ৫ মিনিট স্ট্রেচিং। রাতে ৭ ঘণ্টা ঘুম।\n\nএগুলো সাধারণ পরামর্শ। অসুস্থ থাকলে ডাক্তারের পরামর্শ নিন।'),
          ),
        ),
        const SizedBox(height: 8),
        Text('গত ৭ দিন', style: tt),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 110,
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        height: week[i] * 70 + 4,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                            color: i == 6 ? cs.tertiary : cs.primary,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                      ),
                      const SizedBox(height: 4),
                      Text(days[DateTime.now().subtract(Duration(days: 6 - i)).weekday % 7],
                          style: const TextStyle(fontSize: 12)),
                    ]),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
