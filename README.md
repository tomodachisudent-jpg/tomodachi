# Shift Reservation Sample (FastAPI + Vue + Supabase + Slack)

本番運用を意識した**RBAC/RLS/給与計算/Slack通知**付きのシフト・予約管理アプリのサンプルです。

## スタック
- Backend: FastAPI (Python 3.11)
- Frontend: Vue 3 + Vite + Pinia + Axios
- DB: Supabase (PostgreSQL) + RLS
- Hosting: Koyeb（単一コンテナにNginx+Uvicornで同梱）
- Security: Cloudflare (WAF, HTTPS)

## 機能一覧

### ユーザー・認証
- **認証**: JWTによるセキュアなログイン・認証管理
- **ユーザー管理**: 管理者による講師・生徒アカウントの登録

### 予約・シフト管理
- **シフト登録**: 講師による授業可能枠（オンライン/対面）の登録
- **予約機能**: 生徒による授業予約とキャンセル
- **通知連携**: 予約時のSlack通知

### プロフィール管理
- **生徒プロフィール**: 生徒自身の基本情報（名前、年齢、学習目的など）の登録・編集

### 管理機能
- **給与計算**: 授業実績に基づいた月次の給与計算
- **実績管理**: 提供された授業のログ記録

## セットアップ
1. Supabase で `supabase/schema.sql` → `supabase/policies.sql` を順に実行
2. 管理者ユーザを1件追加（`passlib[bcrypt]`でハッシュ作成）
3. `.env` を作成し `DATABASE_URL`, `JWT_SECRET`, `SLACK_DEFAULT_WEBHOOK` を設定
4. Docker イメージをビルド＆起動
   ```bash
   docker build -t shift-sample .
   docker run -p 8080:80 --env-file .env shift-sample
   # http://localhost:8080
   ```

## 主要エンドポイント
- `POST /api/auth/login` : ログイン（JWT）
- `POST /api/admin/users` : 管理者がユーザ作成（provider/receiver含む）
- `POST /api/provider/shifts` : シフト作成
- `POST /api/receiver/reservations` : 予約作成（Slack通知）
- `GET  /api/receiver/profile` : 生徒プロフィール取得
- `POST /api/receiver/profile` : 生徒プロフィール保存
- `POST /api/reservations/{id}/cancel` : 予約キャンセル（代行可）
- `POST /api/provider/service-logs` : 提供実績登録
- `GET  /api/admin/payroll?month=2025-08-01` : 月次給与集計

詳細は `apis/` および `ui/src/pages/*.vue` を参照してください。
