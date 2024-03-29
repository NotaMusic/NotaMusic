import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nota_music/blocs/player_decorator/player_decorator_cubit.dart';
import 'package:nota_music/screens/main_page/detail_item_page/cubit/detail_item_page_cubit.dart';
import 'package:nota_music/screens/main_page/detail_item_page/detail_item_page_arg.dart';
import 'package:nota_music/widgets/track_in_list.dart';

@AutoRoute()
class DetailItemPage extends StatelessWidget {
  const DetailItemPage({
    required this.arg,
    Key? key,
  }) : super(key: key);

  final DetailItemPageArg arg;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailItemPageCubit, DetailItemPageState>(
      bloc: DetailItemPageCubit(arg, BlocProvider.of(context))..loadContent(),
      builder: (context, state) {
        return state.when(
          loading: (_) => const Center(
            child: SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(),
            ),
          ),
          error: (content) => Center(
            child: Text(
                content?.maybeMap(error: (e) => e.errorStr, orElse: () => null) ?? 'Ошибка при загрузке'),
          ),
          loaded: (content) {
            return content.when(
              playlist: (playlist) => Column(
                children: [
                  Row(children: [
                    playlist.getCoverImage() == null ? const SizedBox.shrink() : SizedBox(height: 64, child: Image.network(playlist.getCoverImage()!),),
                    Text(playlist.title ?? 'Playlist')
                  ],),
                  Expanded(child: ListView.builder(
                itemCount: playlist.tracks!.length,
                itemBuilder: (context, pos) => TrackInList(
                  track: playlist.tracks![pos].track!,
                  onClick: () => BlocProvider.of<PlayerDecoratorCubit>(context).playTrackInPlaylist(
                    playlist: playlist,
                    track: playlist.tracks![pos].track!,
                  ),
                ),
              ))
                ],
              ),
              error: (error) => Center(child: Text(error)),
              album: (album) => Column(
                children: [
                  Row(
                    children: [
                      album.getCoverImage() == null
                          ? const SizedBox.shrink()
                          : SizedBox(
                              height: 64,
                              child: Image.network(album.getCoverImage()!),
                            ),
                      Text(album.title ?? 'Album'),
                      Expanded(
                        child: ListView.builder(
                          itemCount: album.tracks?.length ?? 0,
                          itemBuilder: (item, pos) => TrackInList(
                            track: album.tracks![pos],
                            onClick: () => BlocProvider.of<PlayerDecoratorCubit>(context).playTrackInPlaylist(
                              playlist: album.toPlaylist(),
                              track: album.tracks![pos],
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              artist: (artist) => Column(children: [
                Row(children: [
                  artist.getCoverImage() == null ? const SizedBox.shrink() : SizedBox(height: 64, child: Image.network(artist.getCoverImage()!),),
                  Text(artist.title ?? 'Artist'),
                ],),
                // Expanded(child: ListView.builder(itemCount: artist.volumes, itemBuilder: (context, pos)=> ) )
              ],
              ),
            );
          },
        );
      },
    );
  }
}
