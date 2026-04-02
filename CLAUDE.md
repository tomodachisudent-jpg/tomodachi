# 日本語教室予約管理システム

## フォルダ構成

```
tomodachi_classroom/
├── apis/                    # バックエンドAPI (FastAPI)
│   ├── crud/               # データベース操作層
│   ├── services/           # 外部サービス連携層
│   ├── main.py            # FastAPIアプリケーションエントリーポイント
│   ├── security.py        # セキュリティ関連（JWT, パスワードハッシュ等）
│   ├── deps.py            # 依存性注入
│   ├── models.py          # SQLAlchemyデータモデル
│   └── schemas.py         # Pydanticスキーマ（リクエスト/レスポンス定義）
├── ui/                    # フロントエンド (Vue 3 + Quasar Framework)
│   ├── src/
│   │   ├── pages/         # ページコンポーネント
│   │   ├── components/    # 再利用可能なコンポーネント
│   │   ├── layouts/       # レイアウトコンポーネント
│   │   ├── router/        # Vue Routerルーティング設定
│   │   ├── stores/        # Pinia状態管理ストア
│   │   ├── boot/          # アプリ起動時の初期化処理
│   │   ├── i18n/          # 国際化（多言語対応）
│   │   ├── css/           # グローバルスタイル
│   │   ├── assets/        # 静的アセット（画像等）
│   │   └── App.vue        # ルートコンポーネント
│   ├── public/            # 静的ファイル
│   ├── package.json       # Node.js依存関係
│   └── quasar.config.js   # Quasar設定
├── supabase/              # Supabaseスキーマ・RLSポリシー定義
├── .devcontainer/         # VSCode Dev Container設定
├── doc/                   # プロジェクトドキュメント
├── requirements.txt       # Pythonパッケージ依存関係
├── docker-compose.yml     # Docker Compose設定
├── Dockerfile            # Dockerマルチステージビルド定義
├── nginx.conf            # Nginxリバースプロキシ設定
├── supervisord.conf      # プロセス管理設定
└── README.md             # プロジェクト概要
```

## システム構成

### アーキテクチャ
- **アーキテクチャパターン**: 3層アーキテクチャ（プレゼンテーション層・ビジネスロジック層・データアクセス層）
- **API設計**: RESTful API
- **認証方式**: JWT (JSON Web Token)
- **セキュリティ**: RBAC（ロールベースアクセス制御）+ RLS（Row Level Security）

### 技術スタック

#### バックエンド
- **言語**: Python 3.11
- **フレームワーク**: FastAPI
- **Webサーバー**: Uvicorn (ASGI server)
- **ORM**: SQLAlchemy
- **バリデーション**: Pydantic
- **認証**: python-jose (JWT), bcrypt (パスワードハッシュ)
- **HTTPクライアント**: httpx
- **その他**: python-multipart, python-dotenv

#### フロントエンド
- **言語**: JavaScript (ES Module)
- **フレームワーク**: Vue 3 (Composition API)
- **UIフレームワーク**: Quasar Framework v2
- **ビルドツール**: Vite
- **状態管理**: Pinia
- **ルーティング**: Vue Router v4
- **HTTPクライアント**: Axios
- **国際化**: Vue I18n
- **リッチテキストエディタ**: TipTap
- **カレンダー**: vue-cal

#### データベース
- **DBMS**: PostgreSQL (Supabase)
- **クライアント**: @supabase/supabase-js, psycopg2-binary
- **セキュリティ**: Row Level Security (RLS)

#### インフラ・デプロイ
- **コンテナ**: Docker (マルチステージビルド)
- **オーケストレーション**: Docker Compose
- **リバースプロキシ**: Nginx
- **プロセス管理**: supervisord
- **ホスティング**: Koyeb (単一コンテナ構成)
- **CDN/WAF**: Cloudflare

#### 外部連携
- **通知サービス**:
  - Slack (Webhook)
  - LINE Messaging API
  - メール送信

### データフロー
1. クライアント（Vue SPA）→ Nginx (ポート80)
2. Nginx → APIリクエストはUvicorn/FastAPI (ポート8088) へプロキシ
3. FastAPI → Supabase (PostgreSQL) へデータアクセス
4. FastAPI → Slack/LINE へ通知送信
5. レスポンスを逆順でクライアントへ返却

## 設計書
 - バックエンド
   - 処理の流れを文章で記述する。利用するDBデータ、APIリクエスト項目があれば記載する。
   - コードやテストコードは基本的に記載しない。テスト仕様書、APIレスポンスも記載しない。
 - フロントエンド
   - 画面項目、イベント発生時の処理、APIエンドポイントを記載
   - 活性/非活性、初期値、APIリクエスト内容は記載しない

