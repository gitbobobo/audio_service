import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:smtc_windows/smtc_windows.dart';

import 'audio_service_platform_interface.dart';

class SMTCAudioService extends AudioServicePlatform {
  final smtc = SMTCWindows(
    enabled: false,
    metadata: const MusicMetadata(
      title: 'Title',
      album: 'Album',
      albumArtist: 'Album Artist',
      artist: 'Artist',
      thumbnail:
          'https://media.glamour.com/photos/5f4c44e20c71c58fc210d35f/master/w_2560%2Cc_limit/mgid_ao_image_mtv.jpg',
    ),
    timeline: const PlaybackTimeline(
      startTimeMs: 0,
      endTimeMs: 1000,
      positionMs: 0,
      minSeekTimeMs: 0,
      maxSeekTimeMs: 1000,
    ),
  );

  StreamSubscription<PressedButton>? _buttonPressSubscription;

  AudioHandlerCallbacks? _callbacks;

  @override
  Future<void> configure(ConfigureRequest request) async {
    _buttonPressSubscription ??= smtc.buttonPressStream.listen((event) {
      switch (event) {
        case PressedButton.next:
          _callbacks?.skipToNext(const SkipToNextRequest());
          break;
        case PressedButton.previous:
          _callbacks?.skipToPrevious(const SkipToPreviousRequest());
          break;
        case PressedButton.play:
          _callbacks?.play(const PlayRequest());
          break;
        case PressedButton.pause:
          _callbacks?.pause(const PauseRequest());
          break;
        default:
          break;
      }
    });
  }

  @override
  Future<void> setState(SetStateRequest request) async {
    final state = request.state;
    bool previousEnabled = false;
    bool nextEnabled = false;
    for (var control in state.controls) {
      switch (control.action) {
        case MediaActionMessage.skipToNext:
          nextEnabled = true;
          break;
        case MediaActionMessage.skipToPrevious:
          previousEnabled = true;
          break;
        default:
          break;
      }
    }
    await smtc.setIsNextEnabled(nextEnabled);
    await smtc.setIsPrevEnabled(previousEnabled);
    await smtc.setPlaybackStatus(
        state.playing ? PlaybackStatus.Playing : PlaybackStatus.Paused);
  }

  @override
  Future<void> setQueue(SetQueueRequest request) {
    return SynchronousFuture(null);
  }

  @override
  Future<void> setMediaItem(SetMediaItemRequest request) async {
    String? url = request.mediaItem.artUri?.toString();
    await smtc.updateMetadata(MusicMetadata(
      title: request.mediaItem.title,
      artist: request.mediaItem.artist,
      album: request.mediaItem.album,
      albumArtist: request.mediaItem.artist,
      thumbnail: url,
    ));
    if (!smtc.enabled) {
      await smtc.enableSmtc();
    }
  }

  @override
  Future<void> stopService(StopServiceRequest request) async {
    await smtc.disableSmtc();
  }

  @override
  Future<void> androidForceEnableMediaButtons(
      AndroidForceEnableMediaButtonsRequest request) {
    return SynchronousFuture(null);
  }

  @override
  Future<void> notifyChildrenChanged(NotifyChildrenChangedRequest request) {
    return SynchronousFuture(null);
  }

  @override
  Future<void> setAndroidPlaybackInfo(SetAndroidPlaybackInfoRequest request) {
    return SynchronousFuture(null);
  }

  @override
  void setHandlerCallbacks(AudioHandlerCallbacks callbacks) {
    _callbacks = callbacks;
  }
}
