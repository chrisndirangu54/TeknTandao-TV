import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Authenticated endpoint client for shared room actions.
/// Backend base URLs must come from a trusted deployment configuration.
class PartyService {
  final Uri base;
  final Future<String?> Function() idToken;
  PartyService(this.base,this.idToken);
  Future<Map<String,dynamic>> post(String functionName,Map<String,dynamic> data) async {
    final token=await idToken();
    if(token==null||token.isEmpty)throw StateError('Sign in required');
    if(base.scheme!='https')throw StateError('Secure HTTPS required');
    final response=await http.post(base.resolve('/$functionName'),headers:{
      'Authorization':'Bearer $token','Content-Type':'application/json',
    },body:jsonEncode(data));
    if(response.statusCode<200||response.statusCode>=300){
      throw StateError('Room request failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String,dynamic>;
  }
}

class WatchPartyScreen extends StatefulWidget {
  final PartyService? service;
  const WatchPartyScreen({super.key,this.service});
  @override State<WatchPartyScreen> createState()=>_WatchPartyScreenState();
}

class _WatchPartyScreenState extends State<WatchPartyScreen> {
  String kind='movie',visibility='private';
  bool busy=false;
  final title=TextEditingController(),mediaId=TextEditingController();
  String? roomId,inviteCode,error;
  Future<void> create() async {
    if(widget.service==null){setState(()=>error='Configure Firebase identity and watch party endpoints first.');return;}
    setState((){busy=true;error=null;});
    try{
      final room=await widget.service!.post('createWatchParty',{
        'kind':kind,'visibility':visibility,'title':title.text.trim(),'mediaId':mediaId.text.trim(),
      });
      if(mounted)setState((){
        roomId=room['roomId'] as String?;inviteCode=room['inviteToken'] as String?;
      });
    }catch(e){if(mounted)setState(()=>error='Unable to create party. Check sign-in, catalog rights and configuration.');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  @override void dispose(){title.dispose();mediaId.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Watch together')),
    body:ListView(padding:const EdgeInsets.all(28),children:[
      Text('Virtual watch parties',style:Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height:10),
      const Text('Watch a movie, tune to TV, or listen to a podcast with friends. '
        'Each participant must have their own media access.'),
      const SizedBox(height:22),
      SegmentedButton<String>(
        segments:const [
          ButtonSegment(value:'movie',label:Text('Movies'),icon:Icon(Icons.movie)),
          ButtonSegment(value:'tv',label:Text('TV'),icon:Icon(Icons.live_tv)),
          ButtonSegment(value:'podcast',label:Text('Podcasts'),icon:Icon(Icons.mic)),
        ],
        selected:{kind},onSelectionChanged:(values)=>setState(()=>kind=values.first)),
      const SizedBox(height:16),
      SegmentedButton<String>(
        segments:const [
          ButtonSegment(value:'private',label:Text('Private invite'),icon:Icon(Icons.lock_outline)),
          ButtonSegment(value:'public',label:Text('Public'),icon:Icon(Icons.public)),
        ],selected:{visibility},onSelectionChanged:(values)=>setState(()=>visibility=values.first)),
      const SizedBox(height:20),
      TextField(controller:title,decoration:const InputDecoration(
        labelText:'Party title',border:OutlineInputBorder())),
      const SizedBox(height:12),
      TextField(controller:mediaId,decoration:const InputDecoration(
        labelText:'Authorized media ID',helperText:'Must exist in the rights-verified catalogue',
        border:OutlineInputBorder())),
      const SizedBox(height:14),
      FilledButton.icon(onPressed:busy?null:create,icon:const Icon(Icons.groups),
        label:Text(busy?'Creating…':'Create watch party')),
      if(error!=null)Padding(padding:const EdgeInsets.all(12),child:Text(error!)),
      if(roomId!=null)Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
        crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Party created',style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
          SelectableText('Room ID: $roomId'),
          if(inviteCode!=null)SelectableText('Private invitation token (share securely): $inviteCode'),
          const Text('The live room, synchronized player, voice notes and video calls '
            'need their authenticated session clients before use.'),
        ]))),
      const SizedBox(height:26),
      Text('Room features',style:Theme.of(context).textTheme.titleLarge),
      const ListTile(leading:Icon(Icons.sync),title:Text('Synchronized playback'),
        subtitle:Text('Host play, pause and seek commands are supported by the room API')),
      const ListTile(leading:Icon(Icons.comment),title:Text('Live comments'),
        subtitle:Text('Authenticated chat messages use the room API')),
      const ListTile(leading:Icon(Icons.graphic_eq),title:Text('Voice notes'),
        subtitle:Text('Requires secure audio upload, consent and retention controls')),
      const ListTile(leading:Icon(Icons.video_call),title:Text('Video calls'),
        subtitle:Text('Requires an authenticated WebRTC/SFU provider, signalling and TURN')),
      const Text('Public rooms require reporting, moderation and abuse-rate controls before launch.',
        style:TextStyle(color:Colors.white70)),
    ]));
}
