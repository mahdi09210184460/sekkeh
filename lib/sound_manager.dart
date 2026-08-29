import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final AudioPlayer _player = AudioPlayer();

  // آدرس‌های نمونه برای صداها (در پروژه واقعی بهتر است از فایل‌های محلی در assets استفاده شود)
  static const String winSoundUrl = 'https://codeskulptor-demos.commondatastorage.googleapis.com/descent/gotitem.mp3';
  static const String loseSoundUrl = 'https://codeskulptor-demos.commondatastorage.googleapis.com/descent/Crumble%20Sound.mp3';
  static const String tapSoundUrl = 'https://codeskulptor-demos.commondatastorage.googleapis.com/pang/pop.mp3';

  static Future<void> playWin() async {
    await _player.stop();
    await _player.play(UrlSource(winSoundUrl));
  }

  static Future<void> playLose() async {
    await _player.stop();
    await _player.play(UrlSource(loseSoundUrl));
  }

  static Future<void> playTap() async {
    final tapPlayer = AudioPlayer(); // استفاده از پلیر جدید برای تپ‌های سریع
    await tapPlayer.play(UrlSource(tapSoundUrl));
  }
}
