import 'dart:async';
import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
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

// ============================================================ থিম ও সাধারণ উইজেট

const kBg = Color(0xFF062B25);
const kCard = Color(0xFF0D4034);
const kCard2 = Color(0xFF145A46);
const kGold = Color(0xFFE8C56A);
const kCream = Color(0xFFFBF3DC);
const kMuted = Color(0xFFB7CFC6);

String bn(Object x) =>
    x.toString().replaceAllMapped(RegExp(r'\d'), (m) => '০১২৩৪৫৬৭৮৯'[int.parse(m[0]!)]);

TextStyle arStyle(double size) =>
    GoogleFonts.notoNaskhArabic(fontSize: size, height: 2.0, color: kCream);

ThemeData buildTheme() {
  const cs = ColorScheme.dark(
    primary: kGold,
    onPrimary: Color(0xFF3B2A00),
    secondary: kGold,
    onSecondary: Color(0xFF3B2A00),
    surface: kBg,
    onSurface: kCream,
    error: Color(0xFFFF8A7A),
    onSurfaceVariant: kMuted,
    primaryContainer: kCard2,
    onPrimaryContainer: kCream,
    errorContainer: Color(0xFF6B1F1A),
    onErrorContainer: Color(0xFFFFE1DC),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: kBg,
    textTheme: GoogleFonts.hindSiliguriTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: kCream, displayColor: kCream),
    appBarTheme: const AppBarTheme(
        backgroundColor: kBg, foregroundColor: kCream, elevation: 0, centerTitle: true),
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: kCard, indicatorColor: kGold.withOpacity(0.25)),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets pad;
  final Color? color;
  const Panel({super.key, required this.child, this.pad = const EdgeInsets.all(16), this.color});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: pad,
        decoration: BoxDecoration(
          color: color ?? kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGold.withOpacity(0.22)),
        ),
        child: child,
      );
}

const MethodChannel kCh = MethodChannel('noor/blocker');

void main() => runApp(const IstiqamahApp());

class IstiqamahApp extends StatelessWidget {
  const IstiqamahApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp(title: 'ইস্তিকামাহ', theme: buildTheme(), home: const HomeShell());
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

// ============================================================ গেট

class GatePage extends StatefulWidget {
  const GatePage({super.key});
  @override
  State<GatePage> createState() => _GatePageState();
}

class _GatePageState extends State<GatePage> with WidgetsBindingObserver {
  static const names = ['ফজর', 'যোহর', 'আসর', 'মাগরিব', 'এশা'];

  List<DateTime> times = []; // গতকাল থেকে ৬ দিন পর পর্যন্ত, প্রতিদিন ৫টি
  int confirmedAt = 0;
  bool force = false;
  Map<String, bool> ok = {'usage': false, 'overlay': false, 'exact': true, 'battery': true};
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
      final m = await kCh.invokeMethod<Map>('getState');
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
    for (final d in [-1, 0, 1, 2, 3, 4, 5, 6]) {
      final date = DateTime.now().add(Duration(days: d));
      final pt = PrayerTimes(Coordinates(lat, lng), DateComponents.from(date), params);
      list.addAll([pt.fajr, pt.dhuhr, pt.asr, pt.maghrib, pt.isha].map((e) => e.toLocal()));
    }
    times = list;
    await kCh.invokeMethod('schedule', list.map((e) => e.millisecondsSinceEpoch).toList());
    if (mounted) setState(() {});
  }

  Future<void> _perms() async {
    try {
      final m = await kCh.invokeMethod<Map>('status');
      if (m != null) {
        ok = {
          'usage': m['usage'] == true,
          'overlay': m['overlay'] == true,
          'exact': m['exact'] == true,
          'battery': m['battery'] == true,
        };
      }
      if (ok['usage']! && ok['overlay']!) await kCh.invokeMethod('start');
    } catch (_) {}
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

  int? get nextIdx {
    final n = DateTime.now();
    for (var i = 0; i < times.length; i++) {
      if (times[i].isAfter(n)) return i;
    }
    return null;
  }

  bool get locked {
    final i = lastIdx;
    return force || (i != null && times[i].millisecondsSinceEpoch > confirmedAt);
  }

  Future<void> _confirm() async {
    await kCh.invokeMethod('confirm', DateTime.now().millisecondsSinceEpoch);
    await _sync();
  }

  Future<void> _testLock() async {
    await kCh.invokeMethod('testLock');
    await _sync();
  }

  String _fmt(DateTime t) =>
      '${bn(t.hour % 12 == 0 ? 12 : t.hour % 12)}:${bn(t.minute.toString().padLeft(2, '0'))} ${t.hour >= 12 ? 'PM' : 'AM'}';

  Widget _permTile(String key, String title, String sub, String method) {
    final done = ok[key] == true;
    return ListTile(
      leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? kGold : kMuted),
      title: Text(title),
      subtitle: Text(sub),
      onTap: done ? null : () => kCh.invokeMethod(method),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i = lastIdx;
    final ni = nextIdx;
    final lk = locked;
    final title = !lk
        ? 'আলহামদুলিল্লাহ, সব আদায় হয়েছে'
        : (force && i == null ? 'গেট লক আছে (পরীক্ষা)' : '${names[(i ?? 0) % 5]} নামাজ বাকি!');
    String next = '';
    if (ni != null) {
      final d = times[ni].difference(DateTime.now());
      next = 'পরবর্তী: ${names[ni % 5]} · ${bn(d.inHours)} ঘণ্টা ${bn(d.inMinutes % 60)} মিনিট বাকি';
    }
    final allPerm = ok.values.every((v) => v);
    return Scaffold(
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 40, 16, 16), children: [
        // আর্চ আকৃতির হিরো
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: lk
                  ? const [Color(0xFF8A2F26), Color(0xFF45140F)]
                  : const [Color(0xFF1E8A66), Color(0xFF0D4034)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(150),
              topRight: Radius.circular(150),
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
            border: Border.all(color: kGold.withOpacity(0.7), width: 2),
            boxShadow: [BoxShadow(color: kGold.withOpacity(0.18), blurRadius: 30)],
          ),
          child: Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/logo.png',
                  width: 86,
                  height: 86,
                  errorBuilder: (c, e, s) => const Icon(Icons.mosque, size: 70, color: kGold)),
            ),
            const SizedBox(height: 12),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
                lk
                    ? 'নামাজ পড়ে কনফার্ম না করা পর্যন্ত সোশ্যাল মিডিয়া বন্ধ'
                    : 'এখন সব অ্যাপ খোলা',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kMuted)),
            if (next.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(next, style: const TextStyle(color: kGold, fontWeight: FontWeight.w600)),
            ],
            if (lk) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: _confirm, child: const Text('আলহামদুলিল্লাহ, নামাজ পড়েছি')),
            ],
          ]),
        ),
        Panel(
          pad: EdgeInsets.zero,
          child: Column(children: [
            if (allPerm)
              const ListTile(
                leading: Icon(Icons.verified_user, color: kGold),
                title: Text('গেট চালু আছে'),
                subtitle: Text('অ্যাপ বন্ধ থাকলেও ব্যাকগ্রাউন্ডে পাহারা দেয়'),
              )
            else ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('গেট ২৪ ঘণ্টা চালু রাখতে এই অনুমতিগুলো দিন',
                        style: TextStyle(fontWeight: FontWeight.w700))),
              ),
              _permTile('usage', 'Usage Access', 'কোন অ্যাপ খোলা আছে তা বুঝতে', 'openUsage'),
              _permTile('overlay', 'অন্য অ্যাপের উপরে দেখানো', 'ব্লক অ্যাপের উপরে নামাজের স্ক্রিন', 'openOverlay'),
              _permTile('exact', 'সঠিক সময়ে অ্যালার্ম', 'আযান ঠিক ওয়াক্তে বাজাতে', 'openExact'),
              _permTile('battery', 'ব্যাটারি সীমাবদ্ধতা বন্ধ', 'ফোন যেন গেট বন্ধ না করে দেয়', 'openBattery'),
            ],
          ]),
        ),
        Panel(
          pad: EdgeInsets.zero,
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.block, color: kGold),
              title: const Text('কোন কোন অ্যাপ বন্ধ থাকবে'),
              subtitle: const Text('ফেসবুক, ইউটিউব, টিকটক সহ সব সোশ্যাল মিডিয়া আগে থেকেই বাছা'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const BlockedAppsPage())),
            ),
            ListTile(
              leading: const Icon(Icons.science, color: kGold),
              title: const Text('গেট পরীক্ষা করুন'),
              subtitle: const Text('এখনই লক করে ফেসবুক খুলে দেখুন'),
              onTap: _testLock,
            ),
          ]),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
          child: Text('আজকের ওয়াক্ত', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        if (times.length >= 10)
          Panel(
            pad: EdgeInsets.zero,
            child: Column(children: [
              for (var k = 0; k < 5; k++)
                ListTile(
                  dense: true,
                  title: Text(names[k]),
                  trailing: Text(_fmt(times[5 + k]),
                      style: const TextStyle(color: kGold, fontWeight: FontWeight.w600)),
                ),
            ]),
          ),
      ]),
    );
  }
}

// ============================================================ ব্লক তালিকা

class BlockedAppsPage extends StatefulWidget {
  const BlockedAppsPage({super.key});
  @override
  State<BlockedAppsPage> createState() => _BlockedAppsPageState();
}

class _BlockedAppsPageState extends State<BlockedAppsPage> {
  List<Map<String, String>> apps = [];
  Set<String> blocked = {};
  String q = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final a = await kCh.invokeMethod<List>('getApps') ?? [];
      final b = await kCh.invokeMethod<List>('getBlocked') ?? [];
      apps = a.map((e) => Map<String, String>.from(e as Map)).toList();
      blocked = b.map((e) => e.toString()).toSet();
      apps.sort((x, y) =>
          (blocked.contains(y['pkg']) ? 1 : 0) - (blocked.contains(x['pkg']) ? 1 : 0));
    } catch (_) {}
    loading = false;
    if (mounted) setState(() {});
  }

  Future<void> _toggle(String pkg, bool on) async {
    if (on) {
      blocked.add(pkg);
    } else {
      blocked.remove(pkg);
    }
    setState(() {});
    await kCh.invokeMethod('setBlocked', blocked.toList());
  }

  @override
  Widget build(BuildContext context) {
    final shown = apps
        .where((a) => (a['name'] ?? '').toLowerCase().contains(q.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('বন্ধ থাকবে যে অ্যাপগুলো')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (v) => setState(() => q = v),
                  decoration: InputDecoration(
                    hintText: 'অ্যাপ খুঁজুন',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: kCard,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('${bn(blocked.length)}টি অ্যাপ বাছা আছে। টিক দিলে নামাজ কনফার্মের আগে বন্ধ থাকবে।',
                    style: const TextStyle(color: kMuted)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: shown.length,
                  itemBuilder: (c, i) {
                    final a = shown[i];
                    final pkg = a['pkg'] ?? '';
                    return CheckboxListTile(
                      value: blocked.contains(pkg),
                      onChanged: (v) => _toggle(pkg, v == true),
                      title: Text(a['name'] ?? pkg),
                      subtitle: Text(pkg, style: const TextStyle(fontSize: 11, color: kMuted)),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}

// ============================================================ কুরআন (পূর্ণ, অডিওসহ)

Future<dynamic> getJson(String url) async {
  final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
  if (r.statusCode != 200) throw Exception('http ${r.statusCode}');
  return jsonDecode(utf8.decode(r.bodyBytes));
}

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});
  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  List<dynamic>? surahs;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final c = p.getString('surah_list');
    if (c != null) {
      surahs = jsonDecode(c) as List;
      if (mounted) setState(() {});
    }
    try {
      final j = await getJson('https://api.alquran.cloud/v1/surah');
      surahs = j['data'] as List;
      await p.setString('surah_list', jsonEncode(surahs));
      err = null;
    } catch (_) {
      if (surahs == null) err = 'সূরার তালিকা আনতে ইন্টারনেট লাগবে। ইন্টারনেট চালু করে আবার চাপুন।';
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = surahs;
    return Scaffold(
      appBar: AppBar(title: const Text('আল-কুরআনুল কারীম')),
      body: s == null
          ? Center(
              child: err == null
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(err!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: _load, child: const Text('আবার চেষ্টা করুন')),
                      ]),
                    ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: s.length,
              itemBuilder: (c, i) {
                final x = s[i];
                final n = (x['number'] as num).toInt();
                return Panel(
                  pad: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: kGold,
                        foregroundColor: const Color(0xFF3B2A00),
                        child: Text(bn(n), style: const TextStyle(fontWeight: FontWeight.bold))),
                    title: Text(x['name'].toString(),
                        textDirection: TextDirection.rtl, style: arStyle(22).copyWith(height: 1.6)),
                    subtitle: Text('${x['englishName']} · ${bn(x['numberOfAyahs'])} আয়াত'),
                    trailing: const Icon(Icons.play_circle_outline, color: kGold),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SurahPage(n: n, title: x['name'].toString()))),
                  ),
                );
              },
            ),
    );
  }
}

class SurahPage extends StatefulWidget {
  final int n;
  final String title;
  const SurahPage({super.key, required this.n, required this.title});
  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  List<String> ar = [];
  List<String> bnT = [];
  String? err;
  bool loading = true;
  double fs = 30;
  final player = AudioPlayer();
  bool loaded = false;
  String? aerr;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<List<String>> _arabic(int n) async {
    try {
      // ইন্দো-পাক স্ক্রিপ্ট (বাংলাদেশের হাফেজদের পরিচিত লেখা)
      final j = await getJson('https://api.quran.com/api/v4/quran/verses/indopak?chapter_number=$n');
      final v = (j['verses'] as List).map((e) => e['text_indopak'].toString()).toList();
      if (v.isNotEmpty) return v;
    } catch (_) {}
    final j = await getJson('https://api.alquran.cloud/v1/surah/$n/quran-uthmani');
    return (j['data']['ayahs'] as List).map((e) => e['text'].toString()).toList();
  }

  Future<List<String>> _bangla(int n) async {
    final j = await getJson('https://api.alquran.cloud/v1/surah/$n/bn.bengali');
    return (j['data']['ayahs'] as List).map((e) => e['text'].toString()).toList();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final key = 'q_${widget.n}';
    final c = p.getString(key);
    try {
      if (c != null) {
        final m = jsonDecode(c) as Map;
        ar = (m['ar'] as List).map((e) => e.toString()).toList();
        bnT = (m['bn'] as List).map((e) => e.toString()).toList();
      } else {
        ar = await _arabic(widget.n);
        try {
          bnT = await _bangla(widget.n);
        } catch (_) {
          bnT = [];
        }
        await p.setString(key, jsonEncode({'ar': ar, 'bn': bnT}));
      }
    } catch (_) {
      err = 'সূরা আনতে ইন্টারনেট লাগবে। একবার খুললে পরে অফলাইনেও পড়া যাবে।';
    }
    loading = false;
    if (mounted) setState(() {});
  }

  Future<void> _toggle() async {
    try {
      if (!loaded) {
        final n = widget.n;
        try {
          await player.setUrl('https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$n.mp3');
        } catch (_) {
          await player.setUrl('https://server8.mp3quran.net/afs/${n.toString().padLeft(3, '0')}.mp3');
        }
        loaded = true;
      }
      if (player.playing) {
        await player.pause();
      } else {
        player.play();
      }
      setState(() => aerr = null);
    } catch (_) {
      setState(() => aerr = 'অডিও চালু করা যায়নি। ইন্টারনেট দেখে আবার চাপুন।');
    }
  }

  Widget _bar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
          color: kCard, border: Border(top: BorderSide(color: kGold.withOpacity(0.3)))),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (aerr != null) Text(aerr!, style: const TextStyle(color: Color(0xFFFF8A7A))),
          Row(children: [
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (c, s) {
                final playing = s.data?.playing ?? false;
                return IconButton.filled(
                  onPressed: _toggle,
                  iconSize: 32,
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                );
              },
            ),
            Expanded(
              child: StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (c, s) {
                  final pos = (s.data ?? Duration.zero).inMilliseconds.toDouble();
                  final dur = (player.duration ?? Duration.zero).inMilliseconds.toDouble();
                  final max = dur > 0 ? dur : 1.0;
                  return Slider(
                    value: pos > max ? max : pos,
                    max: max,
                    onChanged: (v) => player.seek(Duration(milliseconds: v.round())),
                  );
                },
              ),
            ),
            const Text('মিশারী আলাফাসি', style: TextStyle(fontSize: 11, color: kMuted)),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: arStyle(22).copyWith(height: 1.4)), actions: [
        IconButton(
            onPressed: () => setState(() => fs = fs > 22 ? fs - 4 : fs),
            icon: const Icon(Icons.text_decrease)),
        IconButton(
            onPressed: () => setState(() => fs = fs < 48 ? fs + 4 : fs),
            icon: const Icon(Icons.text_increase)),
      ]),
      bottomNavigationBar: _bar(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : err != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(err!, textAlign: TextAlign.center)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: ar.length,
                  itemBuilder: (c, i) => Panel(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text('${ar[i]} ﴿${bn(i + 1)}﴾',
                          textDirection: TextDirection.rtl, style: arStyle(fs)),
                      if (i < bnT.length) ...[
                        const Divider(color: Color(0x33E8C56A)),
                        Text(bnT[i], style: const TextStyle(fontSize: 16, color: kMuted, height: 1.5)),
                      ],
                    ]),
                  ),
                ),
    );
  }
}

// ============================================================ দোয়া

class DuaPage extends StatelessWidget {
  const DuaPage({super.key});

  Widget _card(dynamic d) => Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(d[0] as String, textDirection: TextDirection.rtl, style: arStyle(24)),
          const SizedBox(height: 6),
          Text(d[1] as String, style: const TextStyle(fontWeight: FontWeight.w700, color: kGold)),
          const SizedBox(height: 4),
          Text(d[2] as String, style: const TextStyle(color: kMuted, height: 1.5)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    const tt = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    return Scaffold(
      appBar: AppBar(title: const Text('দোয়া ও জিকির')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('প্রতি ফরজ নামাজের পর', style: tt),
        const SizedBox(height: 8),
        for (final d in kAfter) _card(d),
        const Text('ফজিলতগুলো প্রকাশের আগে একজন আলেম দিয়ে যাচাই করিয়ে নিন।',
            style: TextStyle(color: kMuted)),
        const SizedBox(height: 16),
        const Text('অন্যান্য দোয়া', style: tt),
        const SizedBox(height: 8),
        for (final d in kDuas) _card(d),
      ]),
    );
  }
}

// ============================================================ তাসবিহ (৩ডি)

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  static const dhikrs = ['সুবহানাল্লাহ', 'আলহামদুলিল্লাহ', 'আল্লাহু আকবার', 'আস্তাগফিরুল্লাহ'];
  static const goals = [33, 99, 100];
  int n = 0, total = 0, zi = 0, gi = 0;
  bool down = false;
  SharedPreferences? p;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    p = await SharedPreferences.getInstance();
    if (!mounted) return;
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

  Future<void> _vibe(int ms) async {
    try {
      await kCh.invokeMethod('vibrate', ms);
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  void _tap() {
    setState(() {
      n++;
      total++;
      if (n > goals[gi]) n = 1;
    });
    _vibe(n == goals[gi] ? 450 : 40);
    _save();
  }

  Widget _bead(bool on) => Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.4, -0.5),
            colors: on
                ? const [Color(0xFFFFF0B8), kGold, Color(0xFF7A5A10)]
                : const [Color(0xFF3F6B5C), Color(0xFF1B4A3B), Color(0xFF0A2A22)],
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5, offset: const Offset(0, 3))],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final goal = goals[gi];
    final filled = (n * 11 / goal).ceil();
    return Scaffold(
      appBar: AppBar(title: const Text('তাসবিহ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            DropdownButton<int>(
              value: zi,
              dropdownColor: kCard,
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
              dropdownColor: kCard,
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
          const SizedBox(height: 12),
          Text(dhikrs[zi], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: kGold)),
          const Spacer(),
          GestureDetector(
            onTapDown: (_) => setState(() => down = true),
            onTapUp: (_) {
              setState(() => down = false);
              _tap();
            },
            onTapCancel: () => setState(() => down = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              transformAlignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(down ? 0.38 : 0.0),
              width: 250,
              height: 250,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.4, -0.5),
                  radius: 1.0,
                  colors: [Color(0xFFFFF4C8), kGold, Color(0xFF9A7414), Color(0xFF4A3506)],
                  stops: [0.0, 0.35, 0.78, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: down ? 10 : 34,
                      offset: Offset(0, down ? 6 : 24)),
                  BoxShadow(color: kGold.withOpacity(0.25), blurRadius: 44, spreadRadius: 2),
                ],
              ),
              child: Text(bn(n),
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF3B2A00),
                    shadows: [Shadow(color: Colors.white.withOpacity(0.55), offset: const Offset(0, 2))],
                  )),
            ),
          ),
          const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < 11; i++) _bead(i < filled),
          ]),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('মোট গণনা: ${bn(total)}', style: const TextStyle(color: kMuted)),
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

// ============================================================ রুটিন

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
      subtitle: Text(sub, style: const TextStyle(color: kMuted)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            onPressed: () => _set(k, (d[k] ?? 0) - step),
            icon: const Icon(Icons.remove_circle_outline)),
        Text(bn(d[k] ?? 0),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kGold)),
        IconButton(
            onPressed: () => _set(k, (d[k] ?? 0) + step),
            icon: const Icon(Icons.add_circle_outline)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    const tt = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    final s = score(d);
    return Scaffold(
      appBar: AppBar(title: const Text('আজকের রুটিন')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Panel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${bn((s * 12).round())}/১২ সম্পন্ন (${bn((s * 100).round())}%)', style: tt),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: s, minHeight: 10, backgroundColor: kCard2),
            ),
          ]),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(4, 4, 4, 8), child: Text('ইসলামিক জীবনের আমল', style: tt)),
        Panel(
          pad: EdgeInsets.zero,
          child: Column(children: [
            for (final k in checks)
              CheckboxListTile(
                value: (d[k[0]] ?? 0) > 0,
                onChanged: (v) => _set(k[0], v == true ? 1 : 0),
                title: Text(k[1]),
              ),
          ]),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(4, 4, 4, 8), child: Text('সুস্থ শরীর', style: tt)),
        Panel(
          pad: EdgeInsets.zero,
          child: Column(children: [
            _stepper('h', 'পানি পান', 'গ্লাস (লক্ষ্য ৮, প্রায় ২ লিটার)', 1),
            _stepper('w', 'হাঁটা', 'মিনিট (লক্ষ্য ৩০, প্রায় ৩ কিমি)', 5),
            _stepper('e', 'ব্যায়াম', 'মিনিট (লক্ষ্য ২০)', 5),
          ]),
        ),
        const Panel(
          child: Text(
              'আজকের ব্যায়াম: ৫ মিনিট ওয়ার্ম-আপ, ১০টি পুশ-আপ, ১৫টি স্কোয়াট, ৩০ সেকেন্ড প্ল্যাঙ্ক (৩ সেট), শেষে ৫ মিনিট স্ট্রেচিং। রাতে ৭ ঘণ্টা ঘুম।\n\nএগুলো সাধারণ পরামর্শ। অসুস্থ থাকলে ডাক্তারের পরামর্শ নিন।',
              style: TextStyle(color: kMuted, height: 1.5)),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(4, 4, 4, 8), child: Text('গত ৭ দিন', style: tt)),
        Panel(
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
                          color: i == 6 ? kGold : kCard2,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                    ),
                    const SizedBox(height: 4),
                    Text(days[DateTime.now().subtract(Duration(days: 6 - i)).weekday % 7],
                        style: const TextStyle(fontSize: 12, color: kMuted)),
                  ]),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}
