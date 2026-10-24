import 'package:flutter_test/flutter_test.dart';
import 'package:tekntandao_tv/src/domain/models.dart';
import 'package:tekntandao_tv/src/features/android_tv/tv_library.dart';
void main(){
  const news=TvChannel(id:'n',title:'News',number:1,category:'News',description:'World');
  const school=TvChannel(id:'e',title:'Math',number:2,category:'Learning',description:'Lessons');
  test('library search is independent of ranking or engagement',(){
    final lib=TvLibrary();expect(lib.filter([school,news],'').map((c)=>c.number),[1,2]);
    expect(lib.filter([school,news],'math').single.id,'e');
  });
  test('kids mode restricts catalogue and favorite toggles',(){
    final lib=TvLibrary()..kidsMode=true;
    expect(lib.filter([news,school],'').single.id,'e');
    lib.toggleFavorite('e');expect(lib.favorites.contains('e'),true);
    lib.toggleFavorite('e');expect(lib.favorites.contains('e'),false);
  });
}
