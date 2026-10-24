import 'package:flutter/material.dart';
import 'watch_party_screen.dart';

class WatchPartyRoomScreen extends StatefulWidget {
  final PartyService service;
  final String roomId;
  const WatchPartyRoomScreen({super.key,required this.service,required this.roomId});
  @override State<WatchPartyRoomScreen> createState()=>_WatchPartyRoomScreenState();
}
class _WatchPartyRoomScreenState extends State<WatchPartyRoomScreen> {
  final comment=TextEditingController();
  bool busy=false;
  String? error;
  Map<String,dynamic>? room;
  List<dynamic> messages=const [];
  Future<void> refresh()async {
    setState(()=>busy=true);
    try{
      final data=await widget.service.post('partySnapshot',{'roomId':widget.roomId});
      if(mounted)setState((){room=data['room'] as Map<String,dynamic>?;messages=data['messages'] as List<dynamic>? ?? [];error=null;});
    }catch(_){if(mounted)setState(()=>error='Could not refresh party. Check membership and connection.');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> send()async {
    if(comment.text.trim().isEmpty)return;
    try{
      await widget.service.post('partyComment',{'roomId':widget.roomId,'text':comment.text.trim()});
      comment.clear();await refresh();
    }catch(_){if(mounted)setState(()=>error='Comment could not be sent.');}
  }
  Future<void> command(String action)async{
    try{
      await widget.service.post('partyAction',{'roomId':widget.roomId,'action':action,
        'positionMs':(room?['playback'] as Map?)?['positionMs']??0});
      await refresh();
    }catch(_){if(mounted)setState(()=>error='Only the host can control synchronized playback.');}
  }
  @override void initState(){super.initState();refresh();}
  @override void dispose(){comment.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(room?['title'] as String? ?? 'Watch party'),
      actions:[IconButton(onPressed:busy?null:refresh,tooltip:'Refresh',icon:const Icon(Icons.refresh))]),
    body:Padding(padding:const EdgeInsets.all(20),child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('Room: ${widget.roomId}',style:const TextStyle(fontSize:14)),
        if(room!=null)Text('${room!['kind']} • ${room!['visibility']} • '
          '${(room!['members'] as List?)?.length ?? 0} participants',
          style:const TextStyle(fontSize:18)),
        const SizedBox(height:12),
        Row(children:[
          FilledButton.icon(onPressed:()=>command('play'),icon:const Icon(Icons.play_arrow),
            label:const Text('Play together')),
          const SizedBox(width:8),
          OutlinedButton.icon(onPressed:()=>command('pause'),icon:const Icon(Icons.pause),
            label:const Text('Pause together')),
        ]),
        const SizedBox(height:8),
        const Text('Playback is synchronized by commands. Each member must open their '
          'own licensed media stream. Automatic drift correction is not yet connected.',
          style:TextStyle(color:Colors.white70)),
        const Divider(),
        Text('Live comments',style:Theme.of(context).textTheme.titleLarge),
        if(error!=null)Text(error!),
        Expanded(child:ListView(children:[
          for(final item in messages)
            ListTile(title:Text((item as Map)['text'] as String? ?? ''),
              subtitle:Text('From ${item['authorId']}')),
        ])),
        Row(children:[
          Expanded(child:TextField(controller:comment,maxLength:500,
            decoration:const InputDecoration(labelText:'Write a comment'))),
          IconButton(onPressed:send,tooltip:'Send comment',icon:const Icon(Icons.send)),
        ]),
        const Text('Voice notes and video calls require configured secure media and SFU services.'),
      ]),
    )),
  );
}
