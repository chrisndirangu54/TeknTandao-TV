import 'package:flutter/material.dart';
import 'tv_library.dart';

class TvProfileSettings extends StatefulWidget {
  final TvLibrary library;
  const TvProfileSettings({super.key,required this.library});
  @override
  State<TvProfileSettings> createState()=>_TvProfileSettingsState();
}
class _TvProfileSettingsState extends State<TvProfileSettings> {
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Profiles and accessibility')),
    body:ListView(padding:const EdgeInsets.all(28),children:[
      Text('Viewing preferences',style:Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height:18),
      DropdownButtonFormField<String>(
        value:widget.library.activeProfile,
        decoration:const InputDecoration(labelText:'Local profile'),
        items:const ['Default','Guest'].map((name)=>DropdownMenuItem(
          value:name,child:Text(name))).toList(),
        onChanged:(v){if(v==null)return;setState(()=>widget.library.activeProfile=v);widget.library.save();},
      ),
      SwitchListTile(
        title:const Text('Child-oriented discovery filter'),
        subtitle:const Text('Hides non-educational channels in discovery. Not a secure parental lock.'),
        value:widget.library.kidsMode,
        onChanged:(v){setState(()=>widget.library.kidsMode=v);widget.library.save();},
      ),
      SwitchListTile(
        title:const Text('Optional viewing analytics'),
        subtitle:const Text('Disabled by default. No telemetry is uploaded in this build.'),
        value:widget.library.analyticsOptIn,
        onChanged:(v){setState(()=>widget.library.analyticsOptIn=v);widget.library.save();},
      ),
      const ListTile(
        leading:Icon(Icons.closed_caption),
        title:Text('Captions and audio languages'),
        subtitle:Text('Player metadata and licensed caption tracks must be configured by broadcasters.'),
      ),
      const ListTile(
        leading:Icon(Icons.mic_off),
        title:Text('Remote microphone search'),
        subtitle:Text('Not connected. Requires compatible remote, speech permission and search service.'),
      ),
      const ListTile(
        leading:Icon(Icons.shield_outlined),
        title:Text('Family security'),
        subtitle:Text('A real child account requires server-enforced profiles and PIN protection.'),
      ),
    ]),
  );
}
