import 'package:bloc/bloc.dart';
import 'package:marvel_comics/domain/character_model.dart';
import 'package:marvel_comics/domain/comic_model.dart';
import 'package:meta/meta.dart';

import '../../../data/repository/comic_repository.dart';

part 'character_details_state.dart';

class CharacterDetailsCubit extends Cubit<CharacterDetailsState> {
  final ComicRepository comicRepository;
  List<ComicModel> series = [];
  List<ComicModel> events = [];
  List<ComicModel> stories = [];

  CharacterDetailsCubit(this.comicRepository)
      : super(CharacterDetailsInitial());

  Future<void> getCharacterDetails(CharacterModel characterModel) async {
    emit(CharacterDetailsLoading());
    try {
      await getSeries(characterModel);
      emit(CharacterDetailsSuccess(stories, events, series));
    } catch (e) {
      emit(CharacterDetailsFailed(e.toString()));
    }
  }

  Future<void> getSeries(CharacterModel characterModel) async {
    try {
      var responses = await Future.wait([
        for (int i = 0; i < characterModel.series.items.length; i++)
          comicRepository
              .getCharacterDetails(characterModel.series.items[i].resourceURI)
      ]);

      responses.map((response) {
        if (response.code == 200) {
          series = response.result.comics;
        }
      });
    } catch (e) {
      print(e.toString());
      emit(CharacterDetailsFailed(e.toString()));
    }
  }
}
