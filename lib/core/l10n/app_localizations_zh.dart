// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter 代理面板';

  @override
  String get general => '常规';

  @override
  String get workspace => '工作区';

  @override
  String get terminal => '终端';

  @override
  String get newTerminal => '新建终端';

  @override
  String get settings => '设置';

  @override
  String get selectWorkspacePrompt => '选择或建立工作区以开始';

  @override
  String get noTerminalsOpen => '没有开启的终端';

  @override
  String get selectShell => '选择 Shell';

  @override
  String get workspaces => '工作区';

  @override
  String get noWorkspaces => '没有工作区';

  @override
  String get addWorkspace => '新增工作区';

  @override
  String get dark => '深色';

  @override
  String get light => '亮色';

  @override
  String get oneDark => 'One Dark';

  @override
  String get dracula => 'Dracula';

  @override
  String get monokai => 'Monokai';

  @override
  String get nord => 'Nord';

  @override
  String get solarizedDark => 'Solarized Dark';

  @override
  String get githubDark => 'GitHub Dark';

  @override
  String get pwsh7 => 'PowerShell 7';

  @override
  String get powershell => 'Windows PowerShell';

  @override
  String get cmd => '命令提示符';

  @override
  String get wsl => 'WSL';

  @override
  String get gitBash => 'Git Bash';

  @override
  String get appearance => '外观';

  @override
  String get theme => '主题';

  @override
  String get terminalSettings => '终端设置';

  @override
  String get fontFamily => '字体系列';

  @override
  String get fontSize => '字体大小';

  @override
  String get bold => '粗体';

  @override
  String get italic => '斜体';

  @override
  String get shellSettings => 'Shell 设置';

  @override
  String get defaultShell => '默认 Shell';

  @override
  String get customShellPath => '自定义 Shell 路径';

  @override
  String get browse => '浏览';

  @override
  String get custom => '自定义';

  @override
  String get language => '语言';

  @override
  String get english => '英文';

  @override
  String get chineseHant => '繁體中文';

  @override
  String get chineseHans => '简体中文';

  @override
  String get fontPreview => '字体预览';

  @override
  String get fontPreviewText =>
      'Build beautiful, natively compiled applications from a single codebase.';

  @override
  String get about => '关于';

  @override
  String get help => '帮助';

  @override
  String get configureAppDescription => '配置应用程序偏好设置';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get restartingTerminal => '正在重启终端...';

  @override
  String get cursorBlink => '光标闪爍';

  @override
  String get cursorBlinkDescription => '允许终端光标闪爍。';

  @override
  String get themeDescription => '选择应用程序主题模式。';

  @override
  String get terminalSettingsDescription => '配置终端外观和行為。';

  @override
  String get fontFamilyDescription => '选择终端使用的字體。';

  @override
  String get shellSettingsDescription => '选择默认的 Shell。';

  @override
  String get shellPathPlaceholder => '例如: C:\\path\\to\\shell.exe';

  @override
  String get customShells => '自定义 Shell';

  @override
  String get customShellsDescription => '管理自定义 Shell 配置，用于外部终端应用。';

  @override
  String get manageCustomShells => '管理自定义 Shell';

  @override
  String get addCustomShell => '添加自定义 Shell';

  @override
  String get editCustomShell => '编辑自定义 Shell';

  @override
  String get deleteCustomShell => '删除自定义 Shell';

  @override
  String get shellName => 'Shell 名称';

  @override
  String get shellNamePlaceholder => '例如: Warp Terminal';

  @override
  String get shellIcon => 'Shell 图标';

  @override
  String get isExternalTerminal => '外部终端应用';

  @override
  String get isExternalTerminalDescription =>
      '作为独立窗口启动（适用于 Warp、Windows Terminal 等应用）';

  @override
  String get noCustomShells => '尚未配置自定义 Shell';

  @override
  String get addYourFirstCustomShell => '添加您的第一个自定义 Shell 开始使用';

  @override
  String get confirmDeleteShell => '确定要删除此自定义 Shell 吗？';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get customTheme => '自定义主题';

  @override
  String get customThemeDescription => '粘贴JSON主题配置以自定义终端颜色。';

  @override
  String get applyCustomTheme => '添加自定义主题';

  @override
  String get clearCustomTheme => '清除';

  @override
  String get customThemeFolderHint => '导入的主题保存到 ~/.flutter-agent-panel/themes/';

  @override
  String get jsonMustBeObject => 'JSON必须是对象';

  @override
  String missingRequiredField(Object field) {
    return '缺少必填字段: $field';
  }

  @override
  String invalidJson(Object message) {
    return '无效的JSON: $message';
  }

  @override
  String errorParsingTheme(Object message) {
    return '解析主题时出错: $message';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Flutter 代理面板';

  @override
  String get general => '一般';

  @override
  String get workspace => '工作區';

  @override
  String get terminal => '終端機';

  @override
  String get newTerminal => '新建終端';

  @override
  String get settings => '設定';

  @override
  String get selectWorkspacePrompt => '選擇或建立工作區以開始';

  @override
  String get noTerminalsOpen => '沒有開啟的終端';

  @override
  String get selectShell => '選擇 Shell';

  @override
  String get workspaces => '工作區';

  @override
  String get noWorkspaces => '沒有工作區';

  @override
  String get addWorkspace => '新增工作區';

  @override
  String get dark => '深色';

  @override
  String get light => '亮色';

  @override
  String get oneDark => 'One Dark';

  @override
  String get dracula => 'Dracula';

  @override
  String get monokai => 'Monokai';

  @override
  String get nord => 'Nord';

  @override
  String get solarizedDark => 'Solarized Dark';

  @override
  String get githubDark => 'GitHub Dark';

  @override
  String get pwsh7 => 'PowerShell 7';

  @override
  String get powershell => 'Windows PowerShell';

  @override
  String get cmd => '命令提示字元';

  @override
  String get wsl => 'WSL';

  @override
  String get gitBash => 'Git Bash';

  @override
  String get appearance => '外觀';

  @override
  String get theme => '主題';

  @override
  String get terminalSettings => '終端機設定';

  @override
  String get fontFamily => '字型系列';

  @override
  String get fontSize => '字型大小';

  @override
  String get bold => '粗體';

  @override
  String get italic => '斜體';

  @override
  String get shellSettings => 'Shell 設定';

  @override
  String get defaultShell => '預設 Shell';

  @override
  String get customShellPath => '自定義 Shell 路徑';

  @override
  String get browse => '瀏覽';

  @override
  String get custom => '自定義';

  @override
  String get language => '語言';

  @override
  String get english => '英文';

  @override
  String get chineseHant => '繁體中文';

  @override
  String get chineseHans => '簡體中文';

  @override
  String get fontPreview => '字型預覽';

  @override
  String get fontPreviewText =>
      'Build beautiful, natively compiled applications from a single codebase.';

  @override
  String get about => '關於';

  @override
  String get help => '幫助';

  @override
  String get configureAppDescription => '設定應用程式偏好設定';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get restartingTerminal => '正在重新啟動終端機...';

  @override
  String get cursorBlink => '游標閃爍';

  @override
  String get cursorBlinkDescription => '允許終端機游標閃爍。';

  @override
  String get themeDescription => '選擇應用程式主題模式。';

  @override
  String get terminalSettingsDescription => '設定終端機外觀與行為。';

  @override
  String get fontFamilyDescription => '選擇終端機使用的字型。';

  @override
  String get shellSettingsDescription => '選擇預設使用的 Shell。';

  @override
  String get shellPathPlaceholder => '例如: C:\\path\\to\\shell.exe';

  @override
  String get customShells => '自定義 Shell';

  @override
  String get customShellsDescription => '管理自定義 Shell 設定，用於外部終端機應用程式。';

  @override
  String get manageCustomShells => '管理自定義 Shell';

  @override
  String get addCustomShell => '新增自定義 Shell';

  @override
  String get editCustomShell => '編輯自定義 Shell';

  @override
  String get deleteCustomShell => '刪除自定義 Shell';

  @override
  String get shellName => 'Shell 名稱';

  @override
  String get shellNamePlaceholder => '例如: Warp Terminal';

  @override
  String get shellIcon => 'Shell 圖示';

  @override
  String get isExternalTerminal => '外部終端機應用程式';

  @override
  String get isExternalTerminalDescription =>
      '作為獨立視窗啟動（適用於 Warp、Windows Terminal 等應用程式）';

  @override
  String get noCustomShells => '尚未設定自定義 Shell';

  @override
  String get addYourFirstCustomShell => '新增您的第一個自定義 Shell 以開始使用';

  @override
  String get confirmDeleteShell => '確定要刪除此自定義 Shell 嗎？';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '刪除';

  @override
  String get customTheme => '自定義主題';

  @override
  String get customThemeDescription => '貼上JSON主題設定以自定義終端機顏色。';

  @override
  String get applyCustomTheme => '添加自定義主題';

  @override
  String get clearCustomTheme => '清除';

  @override
  String get customThemeFolderHint => '匯入的主題儲存至 ~/.flutter-agent-panel/themes/';

  @override
  String get jsonMustBeObject => 'JSON 必須是物件';

  @override
  String missingRequiredField(Object field) {
    return '缺少必填欄位: $field';
  }

  @override
  String invalidJson(Object message) {
    return '無效的 JSON: $message';
  }

  @override
  String errorParsingTheme(Object message) {
    return '解析主題時發生錯誤: $message';
  }
}
