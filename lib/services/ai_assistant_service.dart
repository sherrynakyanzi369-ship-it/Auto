class AiAssistantService {
  AiAssistantService._();

  static final AiAssistantService instance = AiAssistantService._();

  static const String disclaimer =
      'AutoAssist AI gives preliminary guidance only. It is a support tool and does not replace professional mechanical diagnosis. Please seek qualified help where physical inspection is needed.';

  String greet(String driverName) =>
      'Hello $driverName, I am your AutoAssist vehicle assistant. Describe the problem you are experiencing (for example: "engine won\'t start", "flat tyre", "brakes squealing") and I will give you some initial guidance.';

  String respond(String input, String driverName) {
    final text = input.toLowerCase();
    final output = StringBuffer();

    if (text.contains('battery') ||
        text.contains("won't start") ||
        text.contains("wont start") ||
        text.contains('dim light') ||
        text.contains('click')) {
      output.writeln('This sounds like a battery or starting-system problem. A few quick checks:');
      output.writeln('• Try a jump start using a donor car or jumper pack.');
      output.writeln('• Check that the battery terminals are clean and tightly connected.');
      output.writeln('• Dashboard lights dimming when you turn the key often point to a weak battery.');
      output.writeln('• If it still fails after a jump, the alternator may not be charging properly.');
      output.writeln('A nearby auto-electrician or battery centre can test and replace the battery.');
    } else if (text.contains('tyre') || text.contains('tire') || text.contains('puncture')) {
      output.writeln('You may be dealing with a flat or punctured tyre. Recommended steps:');
      output.writeln('• Find a safe, flat and well-lit area to stop away from traffic.');
      output.writeln('• Switch on your hazard lights and park with the handbrake engaged.');
      output.writeln('• Inspect the tyre; if you can safely fit the spare wheel, do so.');
      output.writeln('• If you cannot or do not feel safe fitting a spare, request a nearby tyre mechanic.');
      output.writeln('Do not drive on a flat tyre as it can damage the wheel and vehicle.');
    } else if (text.contains('overheat') || text.contains('temperature') || text.contains('coolant') || text.contains('steam')) {
      output.writeln('The vehicle appears to be overheating. Act carefully:');
      output.writeln('• Pull over safely and switch off the engine.');
      output.writeln('• Do NOT open the radiator cap while the engine is hot - it can release scalding liquid.');
      output.writeln('• Wait for the engine to cool before checking the coolant level.');
      output.writeln('• Check for visible leaks, a loose fan belt, or a blocked radiator.');
      output.writeln('If the gauge rises quickly again, the cooling system needs professional attention.');
    } else if (text.contains('brake') || text.contains('squeal') || text.contains('pedal')) {
      output.writeln('Brakes are safety-critical. Here is what to consider:');
      output.writeln('• Squealing or grinding usually means worn brake pads - have them checked soon.');
      output.writeln('• A soft or sinking pedal can indicate low brake fluid or air in the system.');
      output.writeln('• A pulling or vibrating pedal may point to a warped disc.');
      output.writeln('• Reduce speed and increase following distance, and arrange inspection immediately.');
    } else if (text.contains('oil') || text.contains('engine light') || text.contains('check engine')) {
      output.writeln('An engine warning or oil-related concern needs careful attention:');
      output.writeln('• If a red oil pressure light turns on, stop the engine promptly to avoid serious damage.');
      output.writeln('• Check the oil level once the vehicle is on level ground and cool.');
      output.writeln('• A lamp glow or low-oil warning is different from a flashing one; flashing needs immediate attention.');
      output.writeln('• A qualified mechanic can run a diagnostic scan to read the trouble codes.');
    } else if (text.contains('transmission') || text.contains('gearbox') || text.contains('gear') || text.contains('slipping')) {
      output.writeln('This suggests a transmission or gearbox concern:');
      output.writeln('• Note when it happens: cold start, uphill, or after long driving.');
      output.writeln('• Check transmission fluid level and colour if you can do so safely.');
      output.writeln('• Avoid forcing gears or hard acceleration to prevent further damage.');
      output.writeln('• A transmission specialist will need to inspect the vehicle to determine the cause.');
    } else if (text.contains('fuel') || text.contains('petrol') || text.contains('diesel') || text.contains('smell')) {
      output.writeln('A fuel-related issue is possible. Consider the following:');
      output.writeln('• Confirm the fuel gauge and that the tank actually has fuel.');
      output.writeln('• A strong fuel smell may indicate a leak - avoid open flames and ventilate the vehicle.');
      output.writeln('• Hard starting or stalling can point to a clogged filter, pump, or injector issue.');
      output.writeln('• Have the fuel system inspected by a mechanic rather than attempting open repairs.');
    } else if (text.contains('grinding') || text.contains('knock') || text.contains('noise') || text.contains('rattle')) {
      output.writeln('Unusual noises can come from many sources. To help narrow it down:');
      output.writeln('• Is it constant or only when braking, turning, or accelerating?');
      output.writeln('• Does it change with speed or with the engine revs?');
      output.writeln('• A metallic grinding or knocking usually requires immediate inspection.');
      output.writeln('It is safer to have a mechanic listen to the vehicle while it runs.');
    } else if (text.contains('light') || text.contains('headlight') || text.contains('indicator')) {
      output.writeln('Lighting problems are commonly simple fixes:');
      output.writeln('• Check whether it is the bulb itself by testing indicators and high beam.');
      output.writeln('• A cracked fuse or corroded socket can also cause failures - try replacing the fuse.');
      output.writeln('• If one light works and the other does not, the bulb is the likely culprit.');
    } else if (text.contains('lock') || text.contains('key') || text.contains('stuck')) {
      output.writeln('If you are locked out or the key is stuck:');
      output.writeln('• Check all doors before assuming you are locked out.');
      output.writeln('• A frozen or worn key may need gentle wiggling, but avoid breaking it in the lock.');
      output.writeln('• Contact a mechanic or locksmith; a mobile mechanic can reach you and help.');
    } else {
      output.writeln('Thank you for describing your problem. To give useful initial guidance, please tell me a little more, for example:');
      output.writeln('• What happened and when (while driving, starting, or parked)?');
      output.writeln('• Any warning lights you noticed on the dashboard?');
      output.writeln('• Any unusual sound, smell, or fluid leak?');
      output.writeln('For an emergency, use the Emergency Assistance feature to request help immediately.');
    }

    output.writeln();
    output.write(disclaimer);
    return output.toString();
  }
}