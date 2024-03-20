import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter/material.dart';
import 'package:flash_talk/variables/shared_variables.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class MorseTransmission {
  ValueNotifier<bool> isFlashing = ValueNotifier<bool>(false);
  ValueNotifier<bool> isBeeping = ValueNotifier<bool>(false);

  Future<void> morseBeeping(
      String morseCode,
      int interval,
      BuildContext context,
      double frequency,
      double balance,
      double volume,
      waveTypes waveType) async {
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
          await _beep(interval, context);
          await _pause(interval);
          continue;
        case '-':
          await _beep(3 * interval, context);
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

  Future<void> morseFlashing(
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
            await _flash(interval);
            await _pause(interval);
            continue;
          case '-':
            await _flash(3 * interval);
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

  Future<void> _beep(int milliseconds, BuildContext context) async {
    try {
      SoundGenerator.play();
    } on Exception catch (e) {
      _showMessage("Невозможно включить динамик.", context);
    } finally {
      await Future.delayed(Duration(milliseconds: milliseconds));
      SoundGenerator.stop();
    }
  }

  Future<void> _flash(int milliseconds) async {
    await TorchLight.enableTorch();
    await Future.delayed(Duration(milliseconds: milliseconds));
    await TorchLight.disableTorch();
  }

  Future<void> _pause(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  void _showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void dispose() {
    isBeeping.dispose();
    isFlashing.dispose();
  }
}
