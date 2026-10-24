import 'package:flutter/material.dart';
import '../../domain/models.dart';
import 'tv_library.dart';

class TvDiscoveryScreen extends StatefulWidget {
  final List<TvChannel> channels;
  final TvLibrary library;
  final ValueChanged<TvChannel> onSelect;
  const TvDiscoveryScreen({super.key,required this.channels,required this.library,required this.onSelect});
  @override
  State<TvDiscoveryScreen> createState()=>_TvDiscoveryScreenState();
}
class _TvDiscoveryScreenState extends State<TvDiscoveryScreen> {
  String query='';
  @override
  Widget build(BuildContext context) {
    final items=widget.library.filter(widget.channels,query);
    return Scaffold(appBar:AppBar(title:const Text('Find channels & programmes')),
      body:Padding(padding:const EdgeInsets.all(30),child:Column(children:[
        TextField(autofocus:true,decoration:const InputDecoration(
          prefixIcon:Icon(Icons.search),labelText:'Search channels, programmes and categories'),
          onChanged:(value)=>setState(()=>query=value)),
        const SizedBox(height:18),
        Row(children:[
          FilterChip(label:const Text('Kids mode'),selected:widget.library.kidsMode,
            onSelected:(v){setState(()=>widget.library.kidsMode=v);widget.library.save();}),
          const SizedBox(width:12),
          Text('${items.length} channels'),
        ]),
        Expanded(child:ListView.builder(itemCount:items.length,itemBuilder:(ctx,index) {
          final c=items[index];
          return ListTile(
            autofocus:index==0,
            leading:Text('${c.number}',style:const TextStyle(fontSize:22)),
            title:Text(c.title,style:const TextStyle(fontSize:20)),
            subtitle:Text(c.category),
            trailing:IconButton(tooltip:'Favorite',icon:Icon(
              widget.library.favorites.contains(c.id) ? Icons.star : Icons.star_border),
              onPressed:(){setState(()=>widget.library.toggleFavorite(c.id));widget.library.save();}),
            onTap:()=>widget.onSelect(c),
          );
        })),
        const Text('AI recommendations and voice transcription require an authenticated, consent-aware service.',
          style:TextStyle(color:Colors.white60)),
      ])));
  }
}
