# AI Research Sandbox Template

GPU対応の学習環境と、SSH越しでも快適な開発・可視化を実現するためのDocker Composeテンプレートです。

## 特徴

- **GPU Support**: `nvidia/cuda:12.4.1` ベース。
- **AI CLI Tools**: `gemini-cli`, `github/copilot`, `openai/codex`, `Claude Code` インストール済み。
- **Developer Tools**: `git`, `git-lfs`, `gh` (GitHub CLI) インストール済み。
- **Modern Editor**: `Neovim` + `LazyVim` によるIDEライクな開発環境。
- **Remote Visualization**: `File Browser` により、SSH越しでもブラウザから画像や実験結果をプレビュー可能。
- **Persistent Cache**: `uv`, `huggingface`, `npm`, `dvc` のキャッシュをNASに逃がす設定済み。

## ディレクトリ構成

- `Dockerfile`: コンテナのビルド定義。
- `docker-compose.yml`: サービス（開発環境 + 可視化ツール）の定義。
- `.env`: NASのパスやポートの設定（`.env.example` から作成）。
- `project/`: ソースコード。ホストのこのディレクトリがコンテナの `/workspace` に同期されます。
- `models/`: NAS上の学習済みモデル保存用ディレクトリ。

## セットアップ

### 1. 環境設定
`.env.example` を `.env` にコピーし、自分の環境に合わせて `NAS_PATH` を書き換えてください。
```bash
cp .env.example .env
```

### 2. 起動
```bash
docker compose up -d --build
```

### 3. 開発開始 (LazyVim)
コンテナに入って `nvim` を起動すると、初回にプラグインのインストールが始まります。
```bash
docker compose exec sandbox nvim
```

## GitHub の連携 (一度だけでOK)

GitHub CLI (`gh`) の設定はNASに保存されるため、一度ログインすればコンテナを再作成しても認証が維持されます。

1. コンテナ内でログインを実行:
   ```bash
   gh auth login
   ```
2. 画面の指示に従って認証（HTTPSを選択すると、SSHキーの設定なしでpush/pullが可能になります）。

複数のターミナル（Neovim用 + エージェント用など）を効率よく管理するため、**Zellij** を推奨しています。

### 1. Zellij の起動
コンテナに入った後、`zellij` と打つだけでリッチなレイアウトが使えます。
```bash
docker compose exec sandbox zellij
```

### 2. 基本操作
- **ペイン分割**: `Alt` + `n` (新しいペイン)
- **ペイン移動**: `Alt` + `矢印キー`
- **タブ作成**: `Alt` + `t`
- **画面の全域表示**: `Alt` + `f` (Neovimを使う時に便利)

### 3. 並列開発のイメージ
- **Pane 1**: `nvim` でコード編集
- **Pane 2**: `gemini-cli` や `claude` でのリサーチ・コード生成
- **Pane 3**: 実験の実行やログの監視

SSHが切れても、`zellij attach` で作業状態を復元できます。

`viz` サービス（File Browser）を使うことで、ブラウザからNASやプロジェクト内のファイルを確認できます。

### 1. ポートフォワード付きでSSH接続
ローカルPCからサーバーへ接続する際、ポート `8080`（または `.env` で設定した値）を転送します。
```bash
ssh -L 8080:localhost:8080 user@your-server-ip
```

### 2. ブラウザでアクセス
ローカルPCのブラウザで以下を開きます。
- **URL**: `http://localhost:8080`
- **初期ユーザー/パス名**: `admin` / `admin` (初回ログイン後に変更を推奨)

ここから `/srv/nas` や `/srv/project` 内の画像、ログ、CSVなどを直接プレビューできます。

## 便利な設定

- **エイリアス**: `ll` (`ls -l`), `cat` (`batcat --style=plain`), `bat` (`batcat --style=plain`) が登録済み。
- **TERM**: `xterm-256color` が自動設定されているため、最初からカラー表示が有効です。
- **DVC**: キャッシュ先が自動的にNAS上のディレクトリに設定されています。
