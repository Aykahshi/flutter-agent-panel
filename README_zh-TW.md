# Flutter Agent Panel

![App Icon Placeholder](assets/images/app_icon.png)

**專為 AI 時代打造的現代化跨平台終端整合工具。**

[English](README.md) | [繁體中文](README_zh-TW.md)

---

## 懶人包 (TL;DR)
Flutter Agent Panel 是一個結合**強大終端機模擬器**與 **AI Agent 管理**的桌面應用程式。它可以讓你透過 **工作區 (Workspaces)** 來管理不同的專案，並在同一個介面中流暢地使用傳統終端機與 CLI 基礎的 AI 代理 (如 Claude Code, GitHub Copilot CLI)。

**為什麼需要這個 App？**
*   **統一介面**：不再需要在編輯器終端機和 AI 對話視窗之間頻繁切換。
*   **情境管理**：透過工作區將你的終端機視窗依照專案分類，井然有序。
*   **跨平台支援**：使用 Flutter 開發，完美支援 Windows, macOS 與 Linux。

---

## 專案簡介與動機
軟體開發的模式正在改變。我們不再只是單純輸入指令，更多時候我們是在與智慧代理人 (Agents) 協作。**Flutter Agent Panel** 的誕生正是為了與解決開發工具碎片化的問題。

**解決的痛點：**
開發者經常需要同時開啟多個終端機視窗來跑伺服器、Git 指令，現在又多了 AI Agent。管理這些分散的視窗非常繁瑣且容易打斷心流。

**解決方案：**
我們提供了一個統一的「Agent 面板」，讓傳統終端機與 AI Agent 能和諧共存。

*   **致敬與啟發**：本專案深受 [better-agent-terminal](https://github.com/tony1223/better-agent-terminal) 的啟發。歡迎大家去支持原本的專案！

## 重點功能
1.  **多工作區管理 (Multi-Workspace)**：依照專案或是情境群組化你的終端機。在不同工作區間切換時，狀態都能完整保留。
2.  **專業級終端模擬器**：基於 `xterm.dart` 與 `flutter_pty` 構建，支援標準終端機功能、字型連字 (Ligatures) 與佈景主題。
3.  **AI Agent 整合**：
    *   **預設支援**：一鍵啟動主流 AI CLI 工具，包括 **Claude Code**, **Qwen Code**, **Codex**, **Gemini**, **OpenCode** 以及 **GitHub Copilot**。
    *   **高度客製**：可針對每個 Agent 自定義啟動指令、環境變數與工作目錄。
4.  **現代化 UI/UX**：
    *   使用 Flutter 版的 [shadcn_ui](https://flutter-shadcn-ui.mariuti.com/) 打造，介面簡潔美觀。
    *   支援深色/淺色模式切換。
    *   響應式設計。

## 使用教學

### 1. 管理工作區 (Workspaces)
建立不同的工作區來區分你的任務。每個工作區都擁有獨立的終端機與 Agent 列表。
![添加工作區](example/workspace.png)
隨意拖拉調整工作區順序。
![重新排序工作區](example/reorder-workspace.gif)

### 2. 使用終端機 (Terminal)
透過 `xterm.dart` 支援多種終端機 (PowerShell, Bash, Zsh, cmd.exe, wsl, etc.)，支援自定義終端機，享受流暢的使用體驗。
![終端機截圖 Placeholder](example/terminal.png)
豐富的內建主題，支援匯入自定義主題 Json。
![主題設定](example/terminal-theme.png)
支援調整字體大小、字型、字型粗細、斜體等。
![字型設定](example/terminal-font.png)
隨意拖拉調整終端機順序。
![重新排序終端機](example/reorder-terminal.gif)

### 3. 啟動 AI Agents
透過 Agent 選單快速啟動預設的 AI 助手。App 會自動處理指令執行與環境設定。
![Agent 選擇清單](example/open-agent.gif)
*支援整合：Claude, Gemini, Copilot 以及自定義指令。*
![Agent 自定義](example/agent-setting.gif)

## 開發指南
若要在本地端建置並執行專案：

```bash
# 下載依賴套件
flutter pub get

# 生成 auto_route 程式碼
dart run lean_builder build

# 執行 App
flutter run
```
