# 振込方法指定機能 - 開発計画

## 概要
先生（provider）が給与の受取方法を「手渡し」「銀行振込」「PayPay」から選択し、必要な情報を登録できるようにする。

- 振込方法の選択肢: 手渡し / 銀行振込 / PayPay
- 銀行振込選択時: 口座情報を入力
- PayPay選択時: 先生自身の受取用QRコードを登録
- 設定画面: 既存のプロフィール編集画面（ProviderProfile.vue）に追加
- 管理者も先生の振込方法を閲覧可能

---

## タスク一覧

| # | タスク | 依存 | レイヤー | 状態 |
|---|--------|------|----------|------|
| 1 | `providers`テーブルに振込方法カラム追加 | - | DB | 完了 |
| 2 | Pydanticスキーマ追加 | #1 | バックエンド | 完了 |
| 3 | 振込方法API追加 (GET/POST + QRアップロード) | #1, #2 | バックエンド | 完了 |
| 4 | 管理者向け振込方法閲覧API | #1, #2 | バックエンド | 完了 |
| 5 | ProviderProfile.vueに振込方法セクション追加 | #3 | フロントエンド | 完了 |
| 6 | 管理者画面で振込方法を表示 | #4 | フロントエンド | 完了 |
| 7 | RLSポリシー追加 | #1 | DB | 完了 |

---

## タスク詳細

### 1. DB: providersテーブルに振込方法カラムを追加

`providers`テーブルに以下のカラムを追加するALTER文を`supabase/schema.sql`に追記する。

| カラム名 | 型 | 説明 |
|---|---|---|
| `payment_method` | enum (`hand`, `bank`, `paypay`) | 振込方法。デフォルト `hand` |
| `bank_name` | text (nullable) | 銀行名（銀行振込時） |
| `bank_branch` | text (nullable) | 支店名（銀行振込時） |
| `bank_account_type` | text (nullable) | 口座種別: 普通/当座（銀行振込時） |
| `bank_account_number` | text (nullable) | 口座番号（銀行振込時） |
| `bank_account_holder` | text (nullable) | 口座名義（銀行振込時） |
| `paypay_qr_url` | text (nullable) | PayPay受取用QRコード画像URL |

enum型 `payment_method_type` を新規作成する。

### 2. バックエンド: Pydanticスキーマ追加

`apis/schemas.py`に`PaymentMethod`スキーマを追加する。

- payment_method: str (hand/bank/paypay)
- bank_name: Optional[str]
- bank_branch: Optional[str]
- bank_account_type: Optional[str]
- bank_account_number: Optional[str]
- bank_account_holder: Optional[str]
- paypay_qr_url: Optional[str]

### 3. バックエンド: 振込方法API追加 (provider.py)

`apis/provider.py`に以下のエンドポイントを追加する。

1. **GET `/api/provider/payment-method`** - 自分の振込方法設定を取得（providersテーブルから）
2. **POST `/api/provider/payment-method`** - 振込方法設定を保存/更新
   - payment_methodに応じて不要なフィールドはNULLにクリアする
   - bank選択時: bank_*フィールドを保存、paypay_qr_urlはNULLに
   - paypay選択時: paypay_qr_urlを保存、bank_*フィールドはNULLに
   - hand選択時: bank_*とpaypay_qr_urlをすべてNULLに
3. **POST `/api/provider/paypay-qr-upload`** - PayPay QRコード画像アップロード（Supabase Storage使用、既存のphoto-uploadと同様の仕組み）

### 4. バックエンド: 管理者向け振込方法閲覧API (admin.py)

管理者が先生の振込方法を閲覧できるようにする。
既存の給与計算APIレスポンス（GET `/api/admin/payroll/{provider_id}`）に振込方法情報を含める。

### 5. フロントエンド: ProviderProfile.vueに振込方法セクション追加

`ui/src/pages/ProviderProfile.vue`に振込方法設定セクションを追加する。

- ラジオボタン: 手渡し / 銀行振込 / PayPay
- 銀行振込選択時: 銀行名、支店名、口座種別（普通/当座のセレクト）、口座番号、口座名義の入力フォームを表示
- PayPay選択時: QRコードアップロードUI（q-file + アップロードボタン + 現在のQR画像表示）を表示
- 手渡し選択時: 追加入力なし
- 保存ボタンでAPIに送信
- 画面読み込み時にGET APIで現在の設定を取得して表示

### 6. フロントエンド: 管理者画面で振込方法を表示

管理者の給与計算画面（`ui/src/pages/AdminAnalytics.vue`）で、各先生の振込方法情報を表示する。

- 給与一覧の各行に振込方法（手渡し / 銀行振込 / PayPay）を表示
- 銀行振込の場合は口座情報を表示
- PayPayの場合はQRコード画像を表示

### 7. DB: RLSポリシー追加

`providers`テーブルの振込方法関連カラムに対するRLSポリシーを確認・追加する。

- 先生本人: 自分のレコードの閲覧・編集が可能
- 管理者: 全先生の振込方法を閲覧可能

※ 既存のprovidersテーブルのRLSポリシーで対応できている可能性あり。`supabase/policies.sql`を確認して必要に応じて追加。

---

## 実装の流れ

1. **DB変更** (#1) → enum型`payment_method_type`と7カラムを`providers`テーブルに追加
2. **バックエンド** (#2→#3, #4) → スキーマ定義 → API実装（先生用・管理者用を並行可能）
3. **フロントエンド** (#5, #6) → 先生のプロフィール画面と管理者画面を並行可能
4. **RLSポリシー** (#7) → DB変更後いつでも対応可能
