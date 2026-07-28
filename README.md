# AI Research Sandbox Template

<p align="center">
  <b>AI研究でよく使うツールを集めた開発環境の Docker 開発テンプレート</b>
</p>

<p align="center">
  <a href="https://developer.nvidia.com/cuda-toolkit"><img src="https://img.shields.io/badge/NVIDIA-CUDA_12.4.1-76B900?style=for-the-badge&logo=nvidia&logoColor=white" alt="NVIDIA CUDA" /></a>
  <a href="https://github.com/astral-sh/uv"><img src="https://img.shields.io/badge/Python-uv_fast-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="uv" /></a>
  <a href="https://github.com/LazyVim/LazyVim"><img src="https://img.shields.io/badge/Editor-Neovim_/_LazyVim-57A143?style=for-the-badge&logo=neovim&logoColor=white" alt="LazyVim" /></a>
  <a href="https://zellij.dev/"><img src="https://img.shields.io/badge/Multiplexer-Zellij-4B5563?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Zellij" /></a>
  <a href="https://tailscale.com/"><img src="https://img.shields.io/badge/Network-Tailscale-24292F?style=for-the-badge&logo=tailscale&logoColor=white" alt="Tailscale" /></a>
  <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-Compose_v2-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker" /></a>
</p>


## クイックスタート

### 1. 環境変数の設定
リポジトリをクローン後、`.env.example` をコピーして設定ファイルを作成します。

```bash
cp .env.example .env
```

### 2. コンテナの起動
Docker Compose で開発環境と可視化サービスを一括起動します。

```bash
docker compose up -d --build
```

### 3. 開発セッションの開始
コンテナに入り、Neovim や Zellij を起動します。

```bash
# Zellij でマルチペイン開発環境を立ち上げる 
docker compose exec sandbox zellij

# または直接 Neovim を起動
docker compose exec sandbox nvim
```


## ディレクトリ構成

```text
.
├── Dockerfile              # NVIDIA CUDA 12.4 + LazyVim + Zellij + AI Tools の定義
├── docker-compose.yml      # sandbox, filebrowser, tailscale のサービス定義
├── .env.example            # パスやポートの設定テンプレート
├── README.md               # プロジェクトドキュメント
└── (HDD_PATH)/             # 外部ストレージ上の永続化ディレクトリ (コンテナ内 /hdd)
    ├── workspace/          # [ホスト <-> コンテナ /workspace] 同期ディレクトリ
    ├── cache/              # uv, huggingface, npm, dvc, gh のキャッシュ
    └── models/             # 大型モデル保存領域
```

## アーキテクチャ

```mermaid
graph TD
    classDef host fill:#2d3748,stroke:#cbd5e0,color:#fff;
    classDef container fill:#1a202c,stroke:#4a5568,color:#fff;
    classDef service fill:#2b6cb0,stroke:#63b3ed,color:#fff;
    classDef user fill:#2f855a,stroke:#9ae6b4,color:#fff;

    User["💻 Local PC / Developer"]:::user

    subgraph Host ["🖥️ Remote Experiment Host & HDD"]
        subgraph Storage [" "]
            Workspace["/workspace (Source Code)"]:::host
            HDD["/hdd (Models, Caches, GH Auth)"]:::host
        end

        subgraph Docker ["🐳 Docker Compose Stack"]
            subgraph Sandbox ["sandbox Container"]
                NV["🟢 NVIDIA CUDA 12.4.1"]:::service
            end

            subgraph FileBrowser ["filebrowser Container"]
                FB["🌐 File Browser Web UI (Port 8080)"]:::service
            end

            subgraph TS ["tailscale Container"]
                Mesh["🔒 Tailscale Mesh Node"]:::service
            end
        end
    end

    User -->|SSH| Mesh
    Mesh -->|Attach Shell| Sandbox
    User -->|Port Forward| FB
    
    Sandbox <--> Workspace
    Sandbox <--> HDD
    FileBrowser -.->Workspace
    FileBrowser -.->HDD
```
