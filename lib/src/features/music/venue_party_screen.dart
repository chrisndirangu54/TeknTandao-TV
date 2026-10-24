import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../watch_parties/watch_party_screen.dart';

/// Room discovery is coarse opt-in area search; true GPS distance and Bluetooth
/// output require separate permissioned native integrations.
class VenuePartyScreen extends StatefulWidget {
 final PartyService? service;
 const VenuePartyScreen({super.key,this.service});
 @override State<VenuePartyScreen> createState()=>_VenuePartyScreenState();
}
class _VenuePartyScreenState extends State<VenuePartyScreen>{
 final name=TextEditingController(),area=TextEditingController(),room=TextEditingController(),code=TextEditingController(),operator=TextEditingController(),messageText=TextEditingController();
 String type='club',admission='public',djMode='ai',feature='song_request',message='';
 bool discoverable=false,busy=false;
 List<dynamic> rooms=const [];
 Future<void> call(String endpoint,Map<String,dynamic> data)async{
  if(widget.service==null){setState(()=>message='Connect a verified sign-in and the deployed venue API first.');return;}
  setState(()=>busy=true);
  try{
   final result=await widget.service!.post(endpoint,data);
   if(!mounted)return;
   setState((){
    if(endpoint=='discoverVenueParties'){rooms=result['rooms'] as List<dynamic>? ?? [];message='${rooms.length} venues found';}
    else if(endpoint=='createVenueParty'){room.text=(result['roomId']??'').toString();code.text=(result['joinCode']??'').toString();message='Venue created. Keep your invitation code private.';}
    else message='Request submitted: ${result['status']??result['orderId']??result['operatorId']??'accepted'}';
   });
  }catch(_){if(mounted)setState(()=>message='Request failed. Check admission, account, pricing and room permissions.');}
  finally{if(mounted)setState(()=>busy=false);}
 }
 @override void dispose(){for(final t in [name,area,room,code,operator,messageText]){t.dispose();}super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Venue party mode')),
  body:ListView(padding:const EdgeInsets.all(22),children:[
   Text('Clubs • Parties • Matatus • Events',style:Theme.of(context).textTheme.headlineSmall),
   const Text('Join by room code, private invitation or opt-in venue discovery. '
    'Precise location and nearby Bluetooth scanning are not enabled.'),
   const SizedBox(height:14),
   TextField(controller:area,decoration:const InputDecoration(labelText:'Area, estate or venue zone (optional)')),
   FilledButton.icon(onPressed:busy?null:()=>call('discoverVenueParties',{'approxArea':area.text.trim()}),
     icon:const Icon(Icons.travel_explore),label:const Text('Find public parties in this area')),
   for(final item in rooms)
     ListTile(leading:const Icon(Icons.music_note),
       title:Text((item as Map)['name'].toString()),subtitle:Text('${item['type']} • ${item['djMode']} DJ'),
       onTap:()=>setState(()=>room.text=item['id'].toString())),
   const Divider(),
   Text('Create a venue party',style:Theme.of(context).textTheme.titleLarge),
   TextField(controller:name,decoration:const InputDecoration(labelText:'Party name')),
   DropdownButtonFormField<String>(value:type,items:const ['club','party','matatu','event','virtual'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),
     onChanged:(v)=>setState(()=>type=v??'club')),
   DropdownButtonFormField<String>(value:admission,items:const ['public','invite','approval','paid'].map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),
     onChanged:(v)=>setState(()=>admission=v??'public')),
   SegmentedButton<String>(segments:const [ButtonSegment(value:'ai',label:Text('AI DJ')),ButtonSegment(value:'live',label:Text('Live DJ'))],
    selected:{djMode},onSelectionChanged:(v)=>setState(()=>djMode=v.first)),
   SwitchListTile(value:discoverable,onChanged:(v)=>setState(()=>discoverable=v),
    title:const Text('Show room in local directory'),subtitle:const Text('Opt-in. Only approximate area is displayed.')),
   FilledButton(onPressed:busy?null:()=>call('createVenueParty',{'name':name.text,'type':type,'admission':admission,
     'djMode':djMode,'discoverable':discoverable,'approxArea':area.text.trim()}),
     child:const Text('Create venue')),
   const Divider(),
   TextField(controller:room,decoration:const InputDecoration(labelText:'Room ID (shareable via link / QR later)')),
   TextField(controller:code,decoration:const InputDecoration(labelText:'Private admission code')),
   if(room.text.isNotEmpty)...[
     const SizedBox(height:10),
     const Text('Scan to join this party'),
     Center(child:Container(color:Colors.white,padding:const EdgeInsets.all(14),
       child:QrImageView(data:'https://tekntandao.web.app/party?roomId=${Uri.encodeComponent(room.text.trim())}',
         size:170,backgroundColor:Colors.white))),
     SelectableText('https://tekntandao.web.app/party?roomId=${Uri.encodeComponent(room.text.trim())}'),
     const Text('The link contains only the room ID; private invite codes must be shared separately.'),
   ],
   OutlinedButton(onPressed:busy?null:()=>call('joinVenueParty',{'roomId':room.text.trim(),'joinCode':code.text.trim()}),
     child:const Text('Join room')),
   const Divider(),
   Text('Host audio output',style:Theme.of(context).textTheme.titleLarge),
   TextField(controller:operator,decoration:const InputDecoration(labelText:'Authorized stereo operator user ID')),
   OutlinedButton(onPressed:busy?null:()=>call('nominateOutput',{'roomId':room.text.trim(),'operatorId':operator.text.trim()}),
     child:const Text('Assign output device operator')),
   const Text('Bluetooth speaker, USB audio, AUX and Wi-Fi casting use the '
    'selected operator device’s system audio output. Automatic device handover is not active.'),
   const Divider(),
   Text('Paid party features',style:Theme.of(context).textTheme.titleLarge),
   DropdownButtonFormField<String>(value:feature,items:const ['song_request','priority_request','shoutout','dedication','admission','tip']
    .map((v)=>DropdownMenuItem(value:v,child:Text(v))).toList(),onChanged:(v)=>setState(()=>feature=v??'song_request')),
   TextField(controller:messageText,maxLength:180,decoration:const InputDecoration(labelText:'Request / dedication')),
   FilledButton.icon(onPressed:busy?null:()=>call('prepareVenuePurchase',{'roomId':room.text.trim(),'feature':feature,
     'message':messageText.text,'amountMinor':0,'idempotencyKey':'venue_${DateTime.now().microsecondsSinceEpoch}'}),
     icon:const Icon(Icons.payments_outlined),label:const Text('Prepare request (no charge)')),
   if(message.isNotEmpty)Padding(padding:const EdgeInsets.all(16),child:Text(message)),
   const Text('Paid services are never fulfilled before verified settlement and moderation. '
    'No cash purchase, priority jump or loudspeaker takeover occurs in this preview.',
    style:TextStyle(color:Colors.white70)),
  ]),
 );
}
