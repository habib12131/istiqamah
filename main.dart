import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NoorApp());

class NoorApp extends StatelessWidget {
  const NoorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ইস্তিকামাহ',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF0E5A55), useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF3FB5A8), brightness: Brightness.dark, useMaterial3: true),
        home: const GatePage(),
      );
}

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
  bool usage = false, overlay = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
    _t = Timer.periodic(const Duration(seconds: 20), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _t?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) _perms();
  }

  Future<void> _init() async {
    final p = await SharedPreferences.getInstance();
    confirmedAt = p.getInt('confirmed') ?? 0;
    await _loadTimes();
    await _perms();
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
    return i != null && times[i].millisecondsSinceEpoch > confirmedAt;
  }

  Future<void> _confirm() async {
    confirmedAt = DateTime.now().millisecondsSinceEpoch;
    (await SharedPreferences.getInstance()).setInt('confirmed', confirmedAt);
    await _ch.invokeMethod('confirm', confirmedAt);
    setState(() {});
  }

  String _fmt(DateTime t) =>
      '${(t.hour % 12 == 0 ? 12 : t.hour % 12)}:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'PM' : 'AM'}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final i = lastIdx;
    final name = i == null ? '' : names[i % 5];
    final lk = locked;
    return Scaffold(
      appBar: AppBar(title: const Text('ইস্তিকামাহ – নামাজ গেট')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: lk ? cs.errorContainer : cs.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lk ? '$name নামাজ বাকি!' : 'আলহামদুলিল্লাহ, সব আদায় হয়েছে',
                  style: Theme.of(context).textTheme.headlineSmall),
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
            subtitle: const Text('ব্লক করা অ্যাপ থেকে ইস্তিকামাহ অ্যাপে ফিরিয়ে আনতে'),
            onTap: () => _ch.invokeMethod('openOverlay'),
          ),
        ],
        const SizedBox(height: 8),
        Text('আজকের ওয়াক্ত', style: Theme.of(context).textTheme.titleMedium),
        if (times.length == 15)
          for (var k = 0; k < 5; k++)
            ListTile(dense: true, title: Text(names[k]), trailing: Text(_fmt(times[5 + k]))),
      ]),
    );
  }
}
