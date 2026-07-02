# 餐廳評分系統建置筆記

## 推薦技術組合

- **後端**：Spring Boot
- **部署**：Google Cloud Run
- **資料庫**：Supabase 上的 Postgres
- **ORM**：Spring Data JPA
- **資料庫 migration**：Flyway
- **API 文件**：springdoc OpenAPI / Swagger
- **容器化**：Docker

## 為什麼選這組

- **Spring Boot** 很適合以 CRUD 為主的 HTTP API。
- **Cloud Run** 支援 HTTP 服務、低流量情境，以及 scale to zero。
- **Supabase Postgres** 提供代管 Postgres，不需要自己維護主機。
- **Flyway** 可以讓 schema 變更清楚、可追蹤、好維護。

## Supabase 設定建議

- **Enable Data API**：可選
- **Automatically expose new tables**：關閉
- **Enable automatic RLS**：暫時關閉

原因：這個系統是由 Spring Boot 當主要後端，所以 API 存取與授權應該主要留在後端控制，而不是直接由 Supabase 自動對外暴露。

## MVP 範圍

第一版先只做這些功能：

1. 列出餐廳
2. 建立餐廳資料
3. 新增評分
4. 新增簡短評論
5. 依地區、類型與分數篩選

## 初始資料表建議

### `restaurants`

- `id`
- `name`
- `area`
- `category`
- `address`
- `note`
- `created_at`

### `ratings`

- `id`
- `restaurant_id`
- `score`
- `comment`
- `visited_at`
- `created_at`

## 實作順序

1. 建立 Supabase 專案並開好 Postgres 資料庫。
2. 建立 Spring Boot 專案，加入 Spring Web、Spring Data JPA、PostgreSQL Driver、Validation、Actuator 與 Flyway。
3. 用環境變數設定資料庫連線：
   - `SPRING_DATASOURCE_URL`
   - `SPRING_DATASOURCE_USERNAME`
   - `SPRING_DATASOURCE_PASSWORD`
4. 先加入 `restaurants` 與 `ratings` 的第一版 Flyway migration。
5. 實作 JPA entity、repository、service 與 controller。
6. 先完成第一批 CRUD API：
   - `GET /restaurants`
   - `POST /restaurants`
   - `GET /restaurants/{id}`
   - `POST /restaurants/{id}/ratings`
   - `GET /restaurants?area=...&category=...&minScore=...`
7. 在本機連到 Supabase Postgres，確認流程正常。
8. 補上 Spring Boot 的 Dockerfile，並使用 `8080` port。
9. 把容器部署到 Google Cloud Run。
10. 在 Cloud Run 設定資料庫連線用的環境變數。
11. 先加上最基本的私人使用保護，例如 token 驗證或簡單登入。
12. 等後端與資料庫流程穩定後，再做輕量前端。

## 實務注意事項

- 為了後續擴充與雲端部署便利，優先選 **Postgres**，不要先用 SQLite。
- 不要把 JPA auto-DDL 當成長期 schema 管理方案。
- Spring Boot 部署在 Cloud Run 上會有一些 cold start 延遲。
- 以這個低流量私人專案來說，cold start 通常可以接受。
- 資料庫帳密不要放進版本控制。
