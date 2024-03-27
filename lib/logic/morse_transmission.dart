import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter/material.dart';
import 'package:flash_talk/variables/shared_variables.dart';
import 'dart:async';

abstract class MorseTransmitter {
  ValueNotifier<bool> get isTransmitting;

  Future<void> transmit(String morseCode, int interval, BuildContext context);

  Future<void> _pause(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  void _showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void dispose();
}

class MorseBeeping extends MorseTransmitter {
  ValueNotifier<bool> isBeeping = ValueNotifier<bool>(false);

  @override
  ValueNotifier<bool> get isTransmitting => isBeeping;

  @override
  Future<void> transmit(
      String morseCode,
      int interval,
      BuildContext context) async {
    if (isBeeping.value) {
      isBeeping.value = false;
      return;
    }

    isBeeping.value = true;

    morseCode = morseCode
        .replaceAll('▬', '-')
        .replaceAll('—', '-')
        .replaceAll('―', '-')
        .replaceAll('_', '-')
        .replaceAll('●', '.')
        .replaceAll('•', '.')
        .replaceAll('       ', ' / ');

    for (String morseChar in morseCode.split("")) {
      if (!isBeeping.value) {
        break;
      }
      switch (morseChar) {
        case '.':
          await _startBeep(interval, context);
          await _pause(interval);
          continue;
        case '-':
          await _startBeep(3 * interval, context);
          await _pause(interval);
          continue;
        case ' ':
          await _pause(2 * interval);
          continue;
        case '/':
          await _pause(2 * interval);
          continue;
        default:
          continue;
      }
    }
    if (isBeeping.value) {
      isBeeping.value = false;
    }
  }

  Future<void> _startBeep(int milliseconds, BuildContext context) async {
    try {
      SoundGenerator.play();
    } on Exception catch (e) {
      _showMessage("Невозможно включить динамик.", context);
    } finally {
      await Future.delayed(Duration(milliseconds: milliseconds));
      SoundGenerator.stop();
    }
  }

  @override
  void dispose() {
    isBeeping.dispose();
  }

}

class MorseFlashing extends MorseTransmitter {
  ValueNotifier<bool> isFlashing = ValueNotifier<bool>(false);

  @override
  ValueNotifier<bool> get isTransmitting => isFlashing;

  @override
  Future<void> transmit(
      String morseCode, int interval, BuildContext context) async {
    if (isFlashing.value) {
      isFlashing.value = false;
      return;
    }

    isFlashing.value = true;

    try {
      bool isTorchAvailable = await TorchLight.isTorchAvailable();
      if (!isTorchAvailable) {
        _showMessage('Фонарик отсутствует.', context);
        return;
      }

      morseCode = morseCode
          .replaceAll('▬', '-')
          .replaceAll('—', '-')
          .replaceAll('―', '-')
          .replaceAll('_', '-')
          .replaceAll('●', '.')
          .replaceAll('•', '.')
          .replaceAll('       ', ' / ');

      for (String morseChar in morseCode.split("")) {
        if (!isFlashing.value) {
          break;
        }

        switch (morseChar) {
          case '.':
            await _startFlash(interval);
            await _pause(interval);
            continue;
          case '-':
            await _startFlash(3 * interval);
            await _pause(interval);
            continue;
          case ' ':
            await _pause(2 * interval);
            continue;
          case '/':
            await _pause(2 * interval);
            continue;
          default:
            continue;
        }
      }
    } catch (e) {
      _showMessage(
          'Не удалось проверить, есть ли на устройстве фонарик.', context);
    }
    if (isFlashing.value) {
      isFlashing.value = false;
    }
  }

  Future<void> _startFlash(int milliseconds) async {
    await TorchLight.enableTorch();
    await Future.delayed(Duration(milliseconds: milliseconds));
    await TorchLight.disableTorch();
  }
  @override
  void dispose() {
    isFlashing.dispose();
  }
}

