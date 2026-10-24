import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../../domain/models.dart';

/// Programme grid backed by channel schedules; no fabricated times.
class TvProgrammeGuide extends StatefulWidget {
  final AppServices services;
  final List<TvChannel> channels;
  final ValueChanged<TvChannel> onTune;
  const TvProgrammeGuide({super.key,required this.services,required this.channels,required this.onTune});
  @override
  State<TvProgrammeGuide> createState()=>_TvProgrammeGuideState();
}
class _TvProgrammeGuideState extends State<TvProgrammeGuide> {
  final Map<String,List<Programme>> schedule={};
  bool loading=true;
  @override
  void initState(){super.initState();refresh();}
  Future<void> refresh() async {
    setState(()=>loading=true);
    final entries=<String,List<Programme>>{};
    for(final channel in widget.channels){
      try {
        entries[channel.id]=await widget.services.catalog.schedule(channel.id);
      } catch (_) { entries[channel.id]=const []; }
      if (!mounted) return;
    }
    setState((){schedule..clear()..addAll(entries);loading=false;});
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:const Text('Programme guide'),actions:[
        IconButton(icon:const Icon(Icons.refresh),tooltip:'Refresh EPG',
          onPressed:loading?null:refresh),
      ]),
      body:loading?const Center(child:CircularProgressIndicator()):
        ListView.builder(padding:const EdgeInsets.all(24),itemCount:widget.channels.length,
          itemBuilder:(context,index){
            final channel=widget.channels[index];
            final programmes=schedule[channel.id] ?? const <Programme>[];
            return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
              crossAxisAlignment:CrossAxisAlignment.start,children:[
                ListTile(
                  title:Text('${channel.number}  ${channel.title}',style:const TextStyle(fontSize:22)),
                  subtitle:Text(channel.category),leading:const Icon(Icons.live_tv),
                  trailing:const Icon(Icons.play_arrow),onTap:()=>widget.onTune(channel)),
                if(programmes.isEmpty) const Padding(padding:EdgeInsets.all(12),
                  child:Text('Schedule not available from broadcaster')),
                for(final p in programmes.take(8))
                  ListTile(
                    title:Text(p.title),subtitle:Text(p.synopsis),
                    leading:Text('${p.beginsAt.toLocal().hour.toString().padLeft(2,'0')}:'
                      '${p.beginsAt.toLocal().minute.toString().padLeft(2,'0')}'),
                    onTap:()=>widget.onTune(channel),
                  ),
              ])));
          }),
    );
  }
}
