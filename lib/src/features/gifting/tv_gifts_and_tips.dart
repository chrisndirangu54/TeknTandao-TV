import 'package:flutter/material.dart';
import '../watch_parties/watch_party_screen.dart';

/// Shared gifting entry point. No money moves without a verified checkout.
class TvGiftsAndTips extends StatefulWidget {
 final PartyService? service;
 const TvGiftsAndTips({super.key,this.service});
 @override State<TvGiftsAndTips> createState()=>_TvGiftsAndTipsState();
}
class _TvGiftsAndTipsState extends State<TvGiftsAndTips> {
 final recipient=TextEditingController();
 final amount=TextEditingController(text:'50');
 String kind='creator',context='tv',feedback='';
 bool pending=false;
 Future<void> createIntent()async{
  final shillings=int.tryParse(amount.text.trim());
  if(shillings==null||shillings<1||shillings>1000000){setState(()=>feedback='Enter a valid amount in KSh.');return;}
  if(widget.service==null){setState(()=>feedback='Secure tipping checkout is not connected.');return;}
  setState(()=>pending=true);
  try{
   final request=await widget.service!.post('createTvTipIntent',{
    'recipientId':recipient.text.trim(),'recipientKind':kind,
    'amountMinor':shillings*100,'context':context,
    'idempotencyKey':'tip_${DateTime.now().microsecondsSinceEpoch}',
   });
   if(mounted)setState(()=>feedback='Tip intent ${request['intentId']} is pending payment. No funds have been transferred.');
  }catch(_){if(mounted)setState(()=>feedback='Unable to create tip intent. Confirm recipient eligibility and sign-in.');}
  finally{if(mounted)setState(()=>pending=false);}
 }
 @override void dispose(){recipient.dispose();amount.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('Gifts and tips')),
  body:ListView(padding:const EdgeInsets.all(24),children:[
   Text('Support the creators you enjoy',style:Theme.of(context).textTheme.headlineSmall),
   const SizedBox(height:8),
   const Text('Optional gifts and tips can support creators, DJs, party hosts and broadcasters. '
      'No pay-to-win votes. No automatic spending.'),
   const SizedBox(height:18),
   TextField(controller:recipient,decoration:const InputDecoration(labelText:'Verified recipient ID')),
   const SizedBox(height:12),
   DropdownButtonFormField<String>(value:kind,decoration:const InputDecoration(labelText:'Support'),
    items:const ['creator','dj','host','broadcaster'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),
    onChanged:(v)=>setState(()=>kind=v??'creator')),
   const SizedBox(height:12),
   DropdownButtonFormField<String>(value:context,decoration:const InputDecoration(labelText:'Experience'),
    items:const ['tv','music','podcast','watch_party'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),
    onChanged:(v)=>setState(()=>context=v??'tv')),
   const SizedBox(height:12),
   TextField(controller:amount,keyboardType:TextInputType.number,decoration:const InputDecoration(
     labelText:'Tip amount in KSh')),
   const SizedBox(height:16),
   FilledButton.icon(onPressed:pending?null:createIntent,
     icon:const Icon(Icons.favorite),label:Text(pending?'Preparing…':'Prepare tip (no charge)')),
   const SizedBox(height:14),
   Text(feedback),
   const SizedBox(height:18),
   const Text('Actual payments, gift inventory, creator payouts and receipts require '
     'Workspace billing verification and an approved payment processor.',
     style:TextStyle(color:Colors.white70)),
  ]),
 );
}
