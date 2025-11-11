import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/color_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/calendar_item.dart';
import '../models/language_settings.dart';
import '../providers/calendar_provider.dart';
import 'edit_item_screen.dart';

// 設定画面のUI
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isReorderMode = false;
  List<CalendarItem>? _reorderableItems;
  GoogleSignInAccount? _googleUser;
  bool _isCheckingSignIn = true; // サインイン状態の確認中フラグ
  bool _isDeletingFirestoreData = false; // Firestoreデータ削除中フラグ

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _googleUser = account;
        _isCheckingSignIn = false; // 確認完了
      });
    });
    
    // 現在のユーザーを確認し、サインインしていない場合のみsignInSilently()を実行
    if (_googleSignIn.currentUser == null) {
      await _googleSignIn.signInSilently();
    } else {
      setState(() {
        _googleUser = _googleSignIn.currentUser;
      });
    }
    
    // 確認完了フラグを設定（onCurrentUserChangedが呼ばれない場合用）
    setState(() {
      _isCheckingSignIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Providerから現在の状態を取得し、変更を監視
    final provider = context.watch<CalendarProvider>();
    final currentStartOfWeek = provider.settings.startOfWeek;
    final items = provider.items;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: ListView(
        children: <Widget>[
          // 週の開始曜日設定
          ListTile(
            title: Text(localizations.weekStartsOn),
            subtitle: Text(currentStartOfWeek == ColorConstants.sundayStartOfWeek ? localizations.sunday : localizations.monday),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(localizations.weekStartsOn),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RadioListTile<int>(
                          title: Text(localizations.sunday),
                          value: ColorConstants.sundayStartOfWeek,
                          groupValue: currentStartOfWeek,
                          onChanged: (int? value) {
                            if (value != null) {
                              context.read<CalendarProvider>().updateStartOfWeek(value);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        RadioListTile<int>(
                          title: Text(localizations.monday),
                          value: ColorConstants.mondayStartOfWeek,
                          groupValue: currentStartOfWeek,
                          onChanged: (int? value) {
                            if (value != null) {
                              context.read<CalendarProvider>().updateStartOfWeek(value);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const Divider(),
          // 言語設定
          ListTile(
            title: Text(localizations.language),
            subtitle: Text(_getCurrentLanguageName(provider.languageSettings.selectedLocale, localizations)),
            onTap: () {
              _showLanguageDialog(context, provider, localizations);
            },
          ),
          const Divider(),
          // Googleアカウント連携
          _isCheckingSignIn
              ? ListTile(
                  leading: const CircularProgressIndicator(strokeWidth: 2.0),
                  title: Text(localizations.googleAccount),
                  subtitle: Text(localizations.checkingLoginStatus),
                )
              : _googleUser != null
                  ? ListTile(
                      leading: _googleUser?.photoUrl != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(_googleUser!.photoUrl!),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      title: Text(localizations.googleAccount),
                      subtitle: Text(_googleUser!.displayName ?? localizations.loggedIn),
                      trailing: TextButton(
                        onPressed: _handleGoogleSignOut,
                        child: Text(localizations.logoutButton),
                      ),
                    )
                  : ListTile(
                      title: Text(localizations.googleAccount),
                      subtitle: Text(localizations.notLoggedIn),
                      trailing: ElevatedButton(
                        onPressed: _handleGoogleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          localizations.loginButton,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
          // Googleアカウントにログインしている場合のみ、Firestoreデータ削除ボタンを表示
          if (_googleUser != null) ...[
            const Divider(),
            ListTile(
              title: Text(localizations.deleteFirestoreData),
              subtitle: Text(localizations.deleteFirestoreDataDescription),
              trailing: ElevatedButton(
                onPressed: _isDeletingFirestoreData ? null : () => _confirmAndDeleteFirestoreData(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: _isDeletingFirestoreData
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(localizations.deleteButton),
              ),
            ),
          ],
          const Divider(),
          // 事柄の管理セクション
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              localizations.manageItems,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
           // 事柄リスト
           if (provider.isSyncingItems)
             const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
           else if (_isReorderMode)
             ..._buildReorderableList(provider, localizations)
           else
             ...items.map((item) {
               return ListTile(
                 leading: Container(
                   width: 24,
                   height: 24,
                   color: item.getEffectiveColor(provider.settings),
                 ),
                 // デバッグモードの時は、事柄名の後にidを表示
                 title: Text(kDebugMode ? '${item.name} (${item.id})' : item.name),
                 trailing: Icon(
                   item.isEnabled ? Icons.check_circle : Icons.not_interested,
                   color: item.isEnabled ? Colors.green : Colors.grey,
                 ),
                 onTap: () {
                   Navigator.of(context).push(
                     MaterialPageRoute(
                       builder: (context) => EditItemScreen(item: item),
                     ),
                   );
                 },
               );
             }).toList(),
          
          // 並べ替えモードのボタン
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isReorderMode
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _cancelReorder,
                      child: Text(localizations.cancelButton),
                    ),
                    ElevatedButton(
                      onPressed: () => _saveReorder(provider),
                      child: Text(localizations.saveButton),
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed: _startReorderMode,
                  child: Text(localizations.changeDisplayOrder),
                ),
          ),
        ],
      ),
    );
  }

  // 並べ替えモードを開始
  void _startReorderMode() {
    final provider = context.read<CalendarProvider>();
    setState(() {
      _isReorderMode = true;
      // 有効な事柄のみを並べ替え対象とする
      _reorderableItems = provider.items.where((item) => item.isEnabled).toList();
    });
  }

  // 並べ替えをキャンセル
  void _cancelReorder() {
    setState(() {
      _isReorderMode = false;
      _reorderableItems = null;
    });
  }

  // 並べ替えを保存
  Future<void> _saveReorder(CalendarProvider provider) async {
    if (_reorderableItems != null) {
      // 有効な事柄の並べ替え結果と無効な事柄を結合
      final disabledItems = provider.items.where((item) => !item.isEnabled).toList();
      final allItems = [..._reorderableItems!, ...disabledItems];
      await provider.reorderItems(allItems);
    }
    setState(() {
      _isReorderMode = false;
      _reorderableItems = null;
    });
  }

  // 並べ替え可能なリストを構築
  List<Widget> _buildReorderableList(CalendarProvider provider, AppLocalizations localizations) {
    if (_reorderableItems == null) return [];
    
    return [
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false, // デフォルトのドラッグハンドルを無効化
        itemCount: _reorderableItems!.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = _reorderableItems!.removeAt(oldIndex);
            _reorderableItems!.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final item = _reorderableItems![index];
          return ReorderableDragStartListener(
            key: ValueKey(item.id),
            index: index,
            child: ListTile(
              leading: Container(
                width: 24,
                height: 24,
                color: item.getEffectiveColor(provider.settings),
              ),
              title: Text(kDebugMode ? '${item.name} (${item.id})' : item.name),
              trailing: const Icon(Icons.drag_handle),
            ),
          );
        },
      ),
    ];
  }

  // Google Sign-Out処理
  Future<void> _handleGoogleSignOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      setState(() {
        _googleUser = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loggedOut)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.logoutFailed(e.toString()))),
        );
      }
      print("Error during Google Sign-Out: $e");
    }
  }

  // Google Sign-In処理
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // ユーザーがサインインをキャンセルした
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebaseにサインイン
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      setState(() {
        _googleUser = googleUser;
      });

      // Googleサインイン成功のメッセージ表示など
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loggedInAs(userCredential.user?.displayName ?? ''))),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loginFailed(e.toString()))),
        );
      }
      print("Error during Google Sign-In: $e");
    }
  }

  // Firestoreデータ削除の確認と実行
  Future<void> _confirmAndDeleteFirestoreData(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final bool confirm = await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.confirmDelete),
          content: Text(localizations.deleteFirestoreDataConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.cancelButton),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: Text(localizations.deleteButton),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      setState(() {
        _isDeletingFirestoreData = true; // 削除処理開始
      });
      try {
        await context.read<CalendarProvider>().deleteFirestoreUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.firestoreDataDeletedSuccessfully)),
          );
        }
        // 削除成功後、Googleサインアウト
        await _handleGoogleSignOut();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.firestoreDataDeletionFailed(e.toString()))),
          );
        }
        print("Error deleting Firestore data: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isDeletingFirestoreData = false; // 削除処理終了
          });
        }
      }
    }
  }

  String _getCurrentLanguageName(Locale? selectedLocale, AppLocalizations localizations) {
    if (selectedLocale == null) {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final defaultLocale = LanguageSettings.getDefaultLocale(deviceLocale);
      return _getLanguageDisplayName(defaultLocale, localizations);
    }
    
    switch (selectedLocale.toString()) {
      case 'en':
        return localizations.english;
      case 'ja':
        return localizations.japanese;
      case 'zh':
        return localizations.chineseSimplified;
      case 'zh_TW':
        return localizations.chineseTraditional;
      case 'ko':
        return localizations.korean;
      case 'fr':
        return localizations.french;
      case 'de':
        return localizations.german;
      case 'es':
        return localizations.spanish;
      case 'hi':
        return localizations.hindi;
      case 'id':
        return localizations.indonesian;
      case 'pt':
        return localizations.portuguese;
      case 'ar':
        return localizations.arabic;
      default:
        return selectedLocale.toString();
    }
  }

  void _showLanguageDialog(BuildContext context, CalendarProvider provider, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ...LanguageSettings.supportedLocales.map((locale) {
                return RadioListTile<Locale?>(
                  title: Text(_getLanguageDisplayName(locale, localizations)),
                  value: locale,
                  groupValue: provider.languageSettings.selectedLocale,
                  onChanged: (Locale? value) {
                    provider.updateLanguage(value);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _getLanguageDisplayName(Locale locale, AppLocalizations localizations) {
    switch (locale.toString()) {
      case 'en':
        return localizations.english;
      case 'ja':
        return localizations.japanese;
      case 'zh':
        return localizations.chineseSimplified;
      case 'zh_TW':
        return localizations.chineseTraditional;
      case 'ko':
        return localizations.korean;
      case 'fr':
        return localizations.french;
      case 'de':
        return localizations.german;
      case 'es':
        return localizations.spanish;
      case 'hi':
        return localizations.hindi;
      case 'id':
        return localizations.indonesian;
      case 'pt':
        return localizations.portuguese;
      case 'ar':
        return localizations.arabic;
      default:
        return locale.toString();
    }
  }


}
