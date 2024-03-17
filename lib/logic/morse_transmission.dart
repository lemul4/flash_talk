import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter/material.dart';
import 'package:flash_talk/variables/shared_variables.dart';
import 'package:flash_talk/pages/translation_page.dart';

typedef MorseTransmissionCallback = void Function(bool success);

class MorseTransmission {
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

  Future<void> morseFlashing(String morseCode, int interval,
      BuildContext context, MorseTransmissionCallback callback) async {
    try {
      bool isTorchAvailable = await TorchLight.isTorchAvailable();
      if (!isTorchAvailable) {
        _showMessage('Фонарик отсутствует.', context);
        callback(true);
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
        if (!SharedVariables.isMorseFlashing) {
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
      callback(true);
    } catch (e) {
      _showMessage(
          'Не удалось проверить, есть ли на устройстве фонарик.', context);
      callback(true);
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

  Future<void> morseBeeping(
      String morseCode,
      int interval,
      BuildContext context,
      double frequency,
      double balance,
      double volume,
      waveTypes waveType,
      MorseTransmissionCallback callback) async {

    morseCode = morseCode
        .replaceAll('▬', '-')
        .replaceAll('—', '-')
        .replaceAll('―', '-')
        .replaceAll('_', '-')
        .replaceAll('●', '.')
        .replaceAll('•', '.')
        .replaceAll('       ', ' / ');

    SoundGenerator.setFrequency(frequency);
    SoundGenerator.setWaveType(waveType);
    SoundGenerator.setBalance(balance);
    SoundGenerator.setVolume(volume);

    for (String morseChar in morseCode.split("")) {
      if (!SharedVariables.isMorseBeeping) {
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
        case _:
          continue;
      }
    }
    callback(true);
  }
}
