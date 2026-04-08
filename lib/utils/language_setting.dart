import 'package:abiya_translator/api/apis.dart';
import 'package:abiya_translator/api/http_helper.dart';
import 'package:abiya_translator/api/responses.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String keyLanguageFrom = 'language_from';
const String keyLanguageTo = 'language_to';

class LanguageSetting {
  List<LanguageItem> languages = [];
  List<ModelItem> models = [];
  ValueNotifier<LanguageConfig?> config = ValueNotifier(null);
  ValueNotifier<LanguageConfig?> runtimeConfig = ValueNotifier(null);
  LanguageSetting() {
    getLanauges();
  }

  void getLanauges() {
    HttpHelper<LanguageListResponse>(LanguageListResponse.new).post(
      apiGetLanguageList,
      null,
      onResponse: (response) async {
        languages = response.languageList;

        models = response.models;
        LanguageConfig localConfig = await getLocalConfig();
        if (localConfig.from == -1 || localConfig.to == -1) {
          int from = -1;
          int to = -1;
          //get the first supported model
          for (ModelItem item in models) {
            if (item.support) {
              from = item.fromId;
              to = item.toId;
              break;
            }
          }
          setLanguageConfig(LanguageConfig(from, to), true);
        } else {
          config.value = localConfig;
          runtimeConfig.value = localConfig;
        }
      },
      onError: (et, em) {},
    );
  }

  void setLanguageConfig(LanguageConfig config, bool writeConfig) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt(keyLanguageFrom, config.from);
    preferences.setInt(keyLanguageTo, config.to);
    if (writeConfig) {
      this.config.value = config;
    }
    runtimeConfig.value = config;
  }

  Future<LanguageConfig> getLocalConfig() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return LanguageConfig(
      preferences.getInt(keyLanguageFrom) ?? -1,
      preferences.getInt(keyLanguageTo) ?? -1,
    );
  }
}

class LanguageConfig {
  final int from;
  final int to;
  LanguageConfig(this.from, this.to);

  LanguageConfig switchLanaugae() {
    return LanguageConfig(to, from);
  }
}
