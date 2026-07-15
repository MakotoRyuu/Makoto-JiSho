# Makoto_JiSho

**iOS 18+ ONLY**

[中文](#中文) | [日本語](#日本語) | [English](#english)

---

<a id="中文"></a>

## 中文

小而美的 Swift + SwiftUI 背单词 App，inspired by [Free高考英语](https://space.bilibili.com/2742391)。

> 像刷短视频一样刷单词——通过简单直观的上下滑动交互，让背单词变得轻快、无压力、容易坚持。

### 功能特性

#### 刷单词

- 单张单词卡片全屏展示，内容简洁：英文单词 + 中文释义
- 纯手势操作，无按钮干扰
  - 向上滑动 → 下一个单词
  - 向下滑动 → 上一个单词
- 瞬间切换，无动画延迟，单卡片渲染，无论词库多大都保持流畅
- 断点续刷：进入刷词页时自动定位到上次退出时的单词位置
- 刷完所有单词后自动返回首页

#### 多词书管理

- 每次导入 `.txt` 文件时自动创建新词书
- 在词书之间自由切换，每个词书保留独立的刷词进度和统计数据
- 支持左滑删除词书（删除时一并清除该词书的单词和进度）
- 活跃词书 ID 持久化存储，重启 App 后保持选择

#### 导入单词

支持读取 `.txt` 文件，格式要求：

```
apple 苹果
book 书
cat 猫
```

- 每行一个单词，英文在前，中文在后，中间以一个空格分隔
- 空行自动忽略
- 重复导入时：若英文单词已存在则更新其中文释义，不存在则追加

#### 进度统计

首页展示：

- 总词数量
- 已刷数量（至少刷过 1 次的单词数）
- 已刷轮次（完成整轮刷词的次数）
- 本轮进度条

### 技术栈

| 技术 | 说明 |
|------|------|
| Swift | 主要开发语言 |
| SwiftUI | 声明式 UI 框架 |
| SwiftData | 本地数据持久化 |

### 系统要求

- iOS 18+
- 仅支持竖屏模式
- 支持深色模式
- 完全离线可用，无需网络连接

### 数据模型

| 模型 | 字段 | 说明 |
|------|------|------|
| `WordBook` | `id`, `name`, `createdAt` | 词书 |
| `Word` | `english`, `chinese`, `lastSeenAt`, `createdAt`, `wordBookID` | 单词，归属某个词书 |
| `ProgressState` | `bookID`, `currentIndex`, `completedRounds`, `reviewedEnglishWords` | 每个词书的进度记录 |

---

<a id="日本語"></a>

## 日本語

Swift + SwiftUI で作られた、小さく美しい単語帳アプリ。[Free高考英语](https://space.bilibili.com/2742391) にインスパイアード。

> ショート動画をスクロールする感覚で単語を学習——直感的な上下スワイプ操作で、軽やかでストレスなく、継続しやすい学びを実現。

### 機能一覧

#### 単語カード

- 全画面表示の単語カード：英単語 + 中国語の意味
- ジェスチャー操作のみ、ボタンなし
  - 上スワイプ → 次の単語
  - 下スワイプ → 前の単語
- アニメーションなしの瞬間切替。カード1枚ずつのレンダリングで、単語帳のサイズに関係なくスムーズ
- 復習再開：カード画面に入る際に前回の退出位置に自動ジャンプ
- 全単語を読み終えたら自動的にホームに戻る

#### 複数単語帳管理

- `.txt` ファイルのインポートごとに新しい単語帳を自動作成
- 単語帳を自由に切り替え、各単語帳が独立した進捗と統計を保持
- 左スワイプで単語帳を削除（削除時に単語と進捗も一括削除）
- アクティブな単語帳 ID を永続化し、アプリ再起動後も選択を保持

#### 単語のインポート

`.txt` ファイルの読み込みに対応。フォーマット：

```
apple りんご
book 本
cat 猫
```

- 1行1単語、英語の後に中国語、スペース1つで区切
- 空行は自動的に無視
- 再インポート時：英単語が既存なら中国語の意味を更新、なければ追加

#### 進捗統計

ホーム画面に表示：

- 総単語数
- 学習済み数（少なくとも1回読んだ単語数）
- 完了ラウンド数（全単語を1周した回数）
- 現在のラウンドのプログレスバー

### 技術スタック

| 技術 | 説明 |
|------|------|
| Swift | メイン開発言語 |
| SwiftUI | 宣言型 UI フレームワーク |
| SwiftData | ローカルデータ永続化 |

### システム要件

- iOS 18+
- 縦向きのみ対応
- ダークモード対応
- 完全オフライン対応、ネットワーク不要

### データモデル

| モデル | フィールド | 説明 |
|------|------|------|
| `WordBook` | `id`, `name`, `createdAt` | 単語帳 |
| `Word` | `english`, `chinese`, `lastSeenAt`, `createdAt`, `wordBookID` | 単語。特定の単語帳に所属 |
| `ProgressState` | `bookID`, `currentIndex`, `completedRounds`, `reviewedEnglishWords` | 単語帳ごとの進捗記録 |

---

<a id="english"></a>

## English

A small and elegant vocabulary app built with Swift + SwiftUI, inspired by [Free高考英语](https://space.bilibili.com/2742391).

> Swipe through words like scrolling short videos — an intuitive up-and-down gesture interface that makes vocabulary learning lightweight, stress-free, and easy to stick with.

### Features

#### Word Cards

- Full-screen word card display: English word + Chinese definition
- Gesture-only interaction, no buttons
  - Swipe up → next word
  - Swipe down → previous word
- Instant switching with no animation delay; single-card rendering stays smooth regardless of dictionary size
- Resume from where you left off: automatically jumps to the last viewed word when entering the card view
- Returns to the home screen automatically after completing all words

#### Multi-Dictionary Management

- Automatically creates a new dictionary on each `.txt` file import
- Switch freely between dictionaries, each maintaining independent progress and statistics
- Swipe left to delete a dictionary (removes all words and progress for that dictionary)
- Active dictionary ID is persisted across app restarts

#### Word Import

Supports `.txt` file import with the following format:

```
apple 苹果
book 书
cat 猫
```

- One word per line: English first, Chinese second, separated by a single space
- Blank lines are automatically ignored
- Re-importing: updates the Chinese definition if the English word already exists, otherwise appends

#### Progress Statistics

Displayed on the home screen:

- Total word count
- Reviewed count (words viewed at least once)
- Completed rounds (number of full passes through the dictionary)
- Current round progress bar

### Tech Stack

| Technology | Description |
|------|------|
| Swift | Primary development language |
| SwiftUI | Declarative UI framework |
| SwiftData | Local data persistence |

### System Requirements

- iOS 18+
- Portrait orientation only
- Dark mode support
- Fully offline, no network connection required

### Data Model

| Model | Fields | Description |
|------|------|------|
| `WordBook` | `id`, `name`, `createdAt` | Dictionary |
| `Word` | `english`, `chinese`, `lastSeenAt`, `createdAt`, `wordBookID` | Word, belongs to a specific dictionary |
| `ProgressState` | `bookID`, `currentIndex`, `completedRounds`, `reviewedEnglishWords` | Progress record per dictionary |

---
