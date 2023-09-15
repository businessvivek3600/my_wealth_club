import 'dart:convert';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import '/constants/app_constants.dart';
import '/database/functions.dart';
import '/database/model/response/base/api_response.dart';
import '/database/model/response/gallery_thumbnail_model.dart';
import '/database/model/response/videos_model.dart';
import '/utils/default_logger.dart';
import '/utils/toasts.dart';

import '../database/repositories/gallery_video_repo.dart';

class GalleryProvider extends ChangeNotifier {
  //player
  late FlickManager flickManager;

  final GalleryRepo galleryRepo;
  GalleryProvider({required this.galleryRepo});
  List<GalleryThumbnailModel> thumbnails = [];
  List<String> images = [];
  bool loadingThumbnails = false;

  Future<void> getGalleryData(bool galleryPage) async {
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.gallery);
    List<GalleryThumbnailModel> _history = [];
    Map? map;
    loadingThumbnails = galleryPage == false;
    notifyListeners();
    if (isOnline) {
      ApiResponse apiResponse = await galleryRepo.getGalleryData();
      if (apiResponse.response != null &&
          apiResponse.response!.statusCode == 200) {
        map = apiResponse.response!.data;
        bool status = false;
        try {
          status = map?["status"];
          if (map?['is_logged_in'] == 0) {
            logOut();
          }
        } catch (e) {}
        try {
          if (status) {
            try {
              var cacheModel = APICacheDBModel(
                  key: AppConstants.gallery, syncData: jsonEncode(map));
              await APICacheManager().addCacheData(cacheModel);
            } catch (e) {}
          }
        } catch (e) {
          print('getGalleryData online hit failed \n $e');
        }
      }
    } else if (!isOnline && cacheExist) {
      var cacheData =
          (await APICacheManager().getCacheData(AppConstants.gallery)).syncData;
      map = jsonDecode(cacheData);
    } else {
      print('getGalleryData not online not cache exist ');
    }
    try {
      if (map != null) {
        try {
          thumbnails.clear();
          if (map['galleryData'] != null &&
              map['galleryData'] != false &&
              map['galleryData'].isNotEmpty) {
            map['galleryData'].forEach(
                (e) => _history.add(GalleryThumbnailModel.fromJson(e)));
            _history.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
            thumbnails = _history;
            notifyListeners();
          }
        } catch (e) {}
      }
    } catch (e) {}
    loadingThumbnails = false;
    notifyListeners();
  }

  bool loadingGalleryDetails = false;
  Future<void> getGalleryDetails(String header) async {
    Map? map;
    loadingGalleryDetails = true;
    notifyListeners();
    bool cacheExist = await APICacheManager()
        .isAPICacheKeyExist(AppConstants.galleryDetail + header);
    try {
      if (isOnline) {
        ApiResponse apiResponse =
            await galleryRepo.getGalleryDetails({'header': header});
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map?["status"];
            if (map?['is_logged_in'] == 0) {
              logOut();
            }
          } catch (e) {}
          try {
            if (status && map != null) {
              try {
                var cacheModel = APICacheDBModel(
                    key: AppConstants.galleryDetail + header,
                    syncData: jsonEncode(map));
                await APICacheManager().addCacheData(cacheModel);
              } catch (e) {}
            }
          } catch (e) {
            print('galleryData online hit failed \n $e');
          }
        } else if (!isOnline && cacheExist) {
          var cacheData = (await APICacheManager()
                  .getCacheData(AppConstants.galleryDetail + header))
              .syncData;
          map = jsonDecode(cacheData);
        } else {
          print('galleryData not online not cache exist ');
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('getPackageType failed ${e}');
    }
    if (map != null) {
      try {
        images.clear();

        if (map['galleryData'] != null && map['galleryData'].isNotEmpty) {
          map['galleryData'].forEach((e) => images.add(e));
          notifyListeners();
        }
      } catch (e) {
        print('galleryData error $e');
      }
    }
    loadingGalleryDetails = false;
    notifyListeners();
  }

  bool loadingVideos = false;
  List<VideoCategoryModel> categoryVideos = [];
  Map<String, String> videoLanguages = {};
  Future<void> getVideos(bool videoPage) async {
    Map? map;
    loadingVideos = !videoPage;
    notifyListeners();
    bool cacheExist =
        await APICacheManager().isAPICacheKeyExist(AppConstants.galleryVideos);
    try {
      if (isOnline) {
        ApiResponse apiResponse = await galleryRepo.galleryVideos();
        if (apiResponse.response != null &&
            apiResponse.response!.statusCode == 200) {
          map = apiResponse.response!.data;
          bool status = false;
          try {
            status = map?["status"];
            if (map?['is_logged_in'] == 0) {
              logOut();
            }
          } catch (e) {}
          try {
            if (status && map != null) {
              try {
                var cacheModel = APICacheDBModel(
                    key: AppConstants.galleryVideos, syncData: jsonEncode(map));
                await APICacheManager().addCacheData(cacheModel);
              } catch (e) {}
            }
          } catch (e) {
            print('getVideos online hit failed \n $e');
          }
        } else if (!isOnline && cacheExist) {
          var cacheData =
              (await APICacheManager().getCacheData(AppConstants.galleryVideos))
                  .syncData;
          map = jsonDecode(cacheData);
        } else {
          print('getVideos not online not cache exist ');
        }
      } else {
        Toasts.showWarningNormalToast('You are offline');
      }
    } catch (e) {
      print('getVideos failed ${e}');
    }
    if (map != null) {
      try {
        categoryVideos.clear();
        if (map['videoData'] != null && map['videoData'].isNotEmpty) {
          map['videoData'].forEach(
              (e) => categoryVideos.add(VideoCategoryModel.fromJson(e)));
          notifyListeners();
        }
        infoLog("map['videoData']  ${map['videoData']}");
        infoLog("categoryVideos  ${categoryVideos.length}");
      } catch (e) {
        print(' getVideos videoData error $e');
      }
      try {
        if (map['language_array'] != null && map['language_array'].isNotEmpty) {
          videoLanguages.clear();
          map['language_array']
              .entries
              .toList()
              .forEach((e) => videoLanguages.addAll({e.key: e.value}));
          // videoLanguages = map['language_array'];
          notifyListeners();
        }
      } catch (e) {
        print('getVideos  language_array error $e');
      }
    }
    loadingVideos = false;
    notifyListeners();
  }

  VideoCategoryModel? currentCategoryModel;
  CategoryVideo? currentVideo;
  setCategoryModel(VideoCategoryModel categoryModel) {
    currentCategoryModel = categoryModel;
    notifyListeners();
  }

  setCurrentVideo(CategoryVideo video) {
    currentVideo = video;
    notifyListeners();
  }

  clear() {
    thumbnails.clear();
    images.clear();
    categoryVideos.clear();
    loadingThumbnails = false;
  }
}
