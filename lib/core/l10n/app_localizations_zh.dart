// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get general => '一般';

  @override
  String get workspace => '工作區';

  @override
  String get terminal => '終端機';

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
  String get appFontFamily => 'App 字型系列';

  @override
  String get appFontFamilyDescription => '選擇應用程式的全域字型系列。';

  @override
  String get defaultGeist => '預設 (Geist)';

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
  String get fontPreviewText => 'echo \"Hello World! 你好世界！\"';

  @override
  String get about => '關於';

  @override
  String get help => '幫助';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get restartingTerminal => '正在重新啟動終端機...';

  @override
  String get cursorBlink => '游標閃爍';

  @override
  String get cursorBlinkDescription => '允許終端機游標閃爍。';

  @override
  String get agents => '智能助手';

  @override
  String get agentsDescription => '管理 AI 智能助手及其設定';

  @override
  String get agentName => '名稱';

  @override
  String get agentCommand => '命令';

  @override
  String get agentArgs => '參數';

  @override
  String get agentEnv => '環境變數';

  @override
  String get installAgentTitle => '安裝助手';

  @override
  String installAgentMessage(String name, String command) {
    return '助手 \'$name\' 尚未安裝。\n是否要使用以下命令安裝？\n\n$command';
  }

  @override
  String get agentNotInstalled => '助手未安裝';

  @override
  String get installingAgent => '正在安裝助手...';

  @override
  String get agentInstalled => '助手安裝成功';

  @override
  String get agentInstallFailed => '助手安裝失敗';

  @override
  String get noCustomAgents => '尚未設定自定義助手';

  @override
  String get customAgent => '自定義助手';

  @override
  String get addCustomAgent => '新增自定義助手';

  @override
  String get editCustomAgent => '編輯自定義助手';

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
  String get customShellsDescription => '管理自定義 Shell，像是 fish 等';

  @override
  String get addCustomShell => '新增自定義 Shell';

  @override
  String get editCustomShell => '編輯自定義 Shell';

  @override
  String get deleteCustomShell => '刪除自定義 Shell';

  @override
  String get shellName => 'Shell 名稱';

  @override
  String get shellNamePlaceholder => '例如: fish';

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

  @override
  String get startingTerminal => '正在啟動...';

  @override
  String get loading => '載入中...';

  @override
  String get agentShell => 'Shell';

  @override
  String get agentShellDescription => '選擇開啟此助手時使用的 Shell';

  @override
  String get defaultShellOption => '預設 (PowerShell)';

  @override
  String get globalEnvironmentVariables => '全域環境變數';

  @override
  String get globalEnvironmentVariablesDescription => '套用至所有終端機的環境變數';

  @override
  String get editWorkspace => '編輯工作區';

  @override
  String get deleteWorkspace => '刪除工作區';

  @override
  String get pinWorkspace => '釘選工作區';

  @override
  String get unpinWorkspace => '取消釘選';

  @override
  String get searchWorkspaces => '搜尋工作區...';

  @override
  String get workspaceName => '工作區名稱';

  @override
  String get workspaceIcon => '圖示';

  @override
  String get workspacePath => '資料夾路徑';

  @override
  String get workspaceTags => '標籤';

  @override
  String get tagsPlaceholder => '輸入標籤，以逗號分隔';

  @override
  String get confirmDeleteWorkspace => '確定要刪除此工作區嗎？';

  @override
  String get createWorkspace => '建立工作區';

  @override
  String get terminalSearchPlaceholder => '尋找';

  @override
  String get terminalSearchPrevious => '上一個符合項目';

  @override
  String get terminalSearchNext => '下一個符合項目';

  @override
  String get terminalSearchCaseSensitive => '區分大小寫';

  @override
  String get terminalSearchRegex => '使用正規表達式';

  @override
  String get close => '關閉';

  @override
  String get addTerminal => '新增終端機';

  @override
  String get addAgent => '新增AI助手';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get general => '常规';

  @override
  String get workspace => '工作区';

  @override
  String get terminal => '终端';

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
  String get appFontFamily => 'App 字体系列';

  @override
  String get appFontFamilyDescription => '选择应用程序的全局字体系列。';

  @override
  String get defaultGeist => '默认 (Geist)';

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
  String get fontPreviewText => 'echo \"Hello World! 你好世界！\"';

  @override
  String get about => '关于';

  @override
  String get help => '帮助';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get restartingTerminal => '正在重启终端...';

  @override
  String get cursorBlink => '光标闪烁';

  @override
  String get cursorBlinkDescription => '允许终端光标闪烁。';

  @override
  String get agents => '智能助手';

  @override
  String get agentsDescription => '管理 AI 智能助手及其配置';

  @override
  String get agentName => '名称';

  @override
  String get agentCommand => '命令';

  @override
  String get agentArgs => '参数';

  @override
  String get agentEnv => '环境变量';

  @override
  String get installAgentTitle => '安装助手';

  @override
  String installAgentMessage(String name, String command) {
    return '助手 \'$name\' 尚未安装。\n是否要使用以下命令安装？\n\n$command';
  }

  @override
  String get agentNotInstalled => '助手未安装';

  @override
  String get installingAgent => '正在安装助手...';

  @override
  String get agentInstalled => '助手安装成功';

  @override
  String get agentInstallFailed => '助手安装失败';

  @override
  String get noCustomAgents => '尚未配置自定义助手';

  @override
  String get customAgent => '自定义助手';

  @override
  String get addCustomAgent => '添加自定义助手';

  @override
  String get editCustomAgent => '编辑自定义助手';

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
  String get customShellsDescription => '管理自定义 Shell，像是 fish 等';

  @override
  String get addCustomShell => '添加自定义 Shell';

  @override
  String get editCustomShell => '编辑自定义 Shell';

  @override
  String get deleteCustomShell => '删除自定义 Shell';

  @override
  String get shellName => 'Shell 名称';

  @override
  String get shellNamePlaceholder => '例如: fish';

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

  @override
  String get startingTerminal => '正在启动...';

  @override
  String get loading => '正在加载...';

  @override
  String get agentShell => 'Shell';

  @override
  String get agentShellDescription => '选择开启此助手时使用的 Shell';

  @override
  String get defaultShellOption => '预设 (PowerShell)';

  @override
  String get globalEnvironmentVariables => '全局环境变量';

  @override
  String get globalEnvironmentVariablesDescription => '应用于所有终端的环境变量';

  @override
  String get editWorkspace => '编辑工作区';

  @override
  String get deleteWorkspace => '删除工作区';

  @override
  String get pinWorkspace => '置顶工作区';

  @override
  String get unpinWorkspace => '取消置顶';

  @override
  String get searchWorkspaces => '搜索工作区...';

  @override
  String get workspaceName => '工作区名称';

  @override
  String get workspaceIcon => '图标';

  @override
  String get workspacePath => '文件夹路径';

  @override
  String get workspaceTags => '标签';

  @override
  String get tagsPlaceholder => '输入标签，用逗号分隔';

  @override
  String get confirmDeleteWorkspace => '确定要删除此工作区吗？';

  @override
  String get createWorkspace => '创建工作区';

  @override
  String get terminalSearchPlaceholder => '查找';

  @override
  String get terminalSearchPrevious => '上一个匹配项';

  @override
  String get terminalSearchNext => '下一个匹配项';

  @override
  String get terminalSearchCaseSensitive => '区分大小写';

  @override
  String get terminalSearchRegex => '使用正则表达式';

  @override
  String get close => '关闭';

  @override
  String get addTerminal => '新增终端';

  @override
  String get addAgent => '新增AI助手';
}
