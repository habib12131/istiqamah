import os, re, shutil, subprocess, sys

# ---- ১. অতিরিক্ত প্যাকেজ (ইন্টারনেট থেকে কুরআন, অডিও, ফন্ট)
subprocess.run(["flutter", "pub", "add", "http", "just_audio", "google_fonts"], check=True)

# ---- ২. AndroidManifest
p = "android/app/src/main/AndroidManifest.xml"
s = open(p, encoding="utf-8").read()
if "xmlns:tools" not in s:
    s = s.replace("<manifest ", '<manifest xmlns:tools="http://schemas.android.com/tools" ', 1)
perms = """
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" tools:ignore="ProtectedPermissions"/>
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <queries>
        <intent>
            <action android:name="android.intent.action.MAIN"/>
            <category android:name="android.intent.category.LAUNCHER"/>
        </intent>
    </queries>
"""
s = s.replace("<application", perms + "    <application", 1)
svc = """
        <service android:name=".BlockerService" android:exported="false" android:foregroundServiceType="specialUse">
            <property android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE" android:value="prayer_gate_app_blocker"/>
        </service>
        <receiver android:name=".BootReceiver" android:exported="true">
            <intent-filter><action android:name="android.intent.action.BOOT_COMPLETED"/></intent-filter>
        </receiver>
        <receiver android:name=".AzanReceiver" android:exported="false"/>
    """
s = s.replace("</application>", svc + "</application>", 1)
s = re.sub(r'android:label="[^"]*"', 'android:label="ইস্তিকামাহ"', s, count=1)
open(p, "w", encoding="utf-8").write(s)

# ---- ৩. লোগো: অ্যাপ আইকন + অ্যাপের ভেতরের ছবি
logo = "../logo.png"
if os.path.exists(logo):
    try:
        from PIL import Image
    except ImportError:
        subprocess.run([sys.executable, "-m", "pip", "install", "--break-system-packages", "pillow"], check=True)
        from PIL import Image
    im = Image.open(logo).convert("RGBA")
    for d, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        folder = "android/app/src/main/res/mipmap-" + d
        os.makedirs(folder, exist_ok=True)
        im.resize((px, px), Image.LANCZOS).save(folder + "/ic_launcher.png")
    os.makedirs("assets", exist_ok=True)
    im.resize((512, 512), Image.LANCZOS).save("assets/logo.png")
    t = open("pubspec.yaml", encoding="utf-8").read()
    t = re.sub(r"(?m)^flutter:[ \t]*$", "flutter:\n  assets:\n    - assets/logo.png", t, count=1)
    open("pubspec.yaml", "w", encoding="utf-8").write(t)

# ---- ৪. আযানের অডিও (azan.mp3 রিপোজিটরিতে থাকলে অ্যাপে ঢোকে)
if os.path.exists("../azan.mp3"):
    os.makedirs("android/app/src/main/res/raw", exist_ok=True)
    shutil.copy("../azan.mp3", "android/app/src/main/res/raw/azan.mp3")
