import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:cn26app/main.dart';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose(int textureId) async {}

  @override
  Future<int?> create(DataSource dataSource) async => 1;

  @override
  Future<void> setLooping(int textureId, bool looping) async {}

  @override
  Future<void> play(int textureId) async {}

  @override
  Future<void> pause(int textureId) async {}

  @override
  Future<void> setVolume(int textureId, double volume) async {}

  @override
  Future<void> seekTo(int textureId, Duration position) async {}

  @override
  Future<Duration> getPosition(int textureId) async => Duration.zero;

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return StreamController<VideoEvent>().stream;
  }

  @override
  Widget buildView(int textureId) => const SizedBox();
}

void main() {
  setUp(() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  testWidgets('Aperture FYP smoke test with video player', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ApertureApp());

    // Verify brand header, first frame index label, and category tab are rendered.
    expect(find.text('APERTURE'), findsOneWidget);
    expect(find.text('VIDEO 01'), findsOneWidget);
    expect(find.text('For You'), findsOneWidget);
  });
}
