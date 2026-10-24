import 'package:flutter/material.dart';
import '../watch_parties/watch_party_screen.dart';

/// This UI uses the same authenticated PartyService as watch parties.
/// BeatSync transitions require an external DSP worker and licensed audio feeds.
class AiDjListeningRoom extends StatefulWidget {
 final PartyService? service;
 const AiDjListeningRoom({super.key,this.service});
 @override State<AiDjListeningRoom> createState()=>_AiDjListeningRoomState();
}
class _AiDjListeningRoomState extends State<AiDjListeningRoom> {
 final room=TextEditingController(),track=TextEditingController();
 String message='';List<dynamic> queue=const [];
 bool loading=false;
 Future<void> action(String endpoint,Map<String,dynamic> payload)async{
  if(widget.service==null){setState(()=>message='Connect authenticated Firebase services to use the DJ room.');return;}
  setState(()=>loading=true);
  try{
   final result=await widget.service!.post(endpoint,payload);
   if(endpoint=='musicQueue')queue=result['queue'] as List<dynamic>? ?? [];
   message=endpoint=='proposeTrack'?'Track request accepted':endpoint=='voteTrack'?'Vote recorded':'Queue updated';
  }catch(_){message='Unable to complete action. Check membership, media rights and connection.';}
  if(mounted)setState(()=>loading=false);
 }
 @override void dispose(){room.dispose();track.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('TeknTandao AI DJ')),
  body:ListView(padding:const EdgeInsets.all(25),children:[
   Text('Listen together. Shape the set.',style:Theme.of(context).textTheme.headlineMedium),
   const SizedBox(height:8),
   const Text('Vote for the next track in your room. The DJ uses the BeatSync signal model '
      'for beat-aware transitions and visual effects when the analysis worker is connected.'),
   const SizedBox(height:20),
   TextField(controller:room,decoration:const InputDecoration(labelText:'Music party room ID')),
   const SizedBox(height:12),
   TextField(controller:track,decoration:const InputDecoration(labelText:'Licensed track ID')),
   const SizedBox(height:12),
   Wrap(spacing:12,runSpacing:8,children:[
    FilledButton.icon(onPressed:loading?null:()=>action('proposeTrack',{'roomId':room.text.trim(),'trackId':track.text.trim()}),
      icon:const Icon(Icons.queue_music),label:const Text('Request song')),
    OutlinedButton.icon(onPressed:loading?null:()=>action('voteTrack',{'roomId':room.text.trim(),'trackId':track.text.trim()}),
      icon:const Icon(Icons.how_to_vote),label:const Text('Vote')),
    OutlinedButton.icon(onPressed:loading?null:()=>action('musicQueue',{'roomId':room.text.trim()}),
      icon:const Icon(Icons.refresh),label:const Text('Refresh queue')),
   ]),
   if(message.isNotEmpty)Padding(padding:const EdgeInsets.symmetric(vertical:14),child:Text(message)),
   Text('Community queue',style:Theme.of(context).textTheme.titleLarge),
   for(final item in queue)Card(child:ListTile(
    leading:const Icon(Icons.music_note),
    title:Text((item as Map)['trackId'].toString()),
    subtitle:Text('${item['votes']} votes · ${item['score']} points'),
    trailing:IconButton(tooltip:'Vote for track',icon:const Icon(Icons.thumb_up),
      onPressed:()=>action('voteTrack',{'roomId':room.text.trim(),'trackId':item['trackId']})),
   )),
   const SizedBox(height:18),
   const Text('Scoring is for queue ordering only. Tips do not buy votes. '
      'Music generation, beat matching, microphone calls and synced licensed playback '
      'require live integrations.',style:TextStyle(color:Colors.white70)),
  ]),
 );
}
