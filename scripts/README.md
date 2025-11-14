# scripts/ — 使用手冊

此目錄包含幾個方便的 shell 腳本，用於在開發機或 CI-friendly Docker 環境中快速設定與管理 metamcp stack。

檔案
- `setup-docker.sh`：第一次使用時執行，會從 `example.env` 建立 `.env`（若不存在）、產生 `BETTER_AUTH_SECRET`、啟動 Postgres 並建立 `pgcrypto` extension。
- `start.sh`：啟動服務。預設只啟 `app`；加上 `--all` 可一次啟全部服務（`docker compose up -d`）。
- `stop.sh`：停止並移除容器；加上 `--volumes` 會同時移除資料卷（`docker compose down -v`）。
- `status.sh`：顯示容器狀態與最近日誌；`--follow` 可串流日誌，`--tail N` 指定最近 N 行。

快速開始
1. 確認你已安裝 Docker 與 docker compose。
2. 在 repo 根執行：

```zsh
chmod +x scripts/*.sh
./scripts/setup-docker.sh
./scripts/start.sh
# or start everything
# ./scripts/start.sh --all
```

3. 開啟瀏覽器查看前端： `http://localhost:12008`

常見問題與排查
- .env 不要加入版本控制：請勿把 `.env` 提交到 GitHub。腳本不會覆寫已存在的 `.env`。
- migration 失敗與 `pgcrypto`：若 migration 顯示 `gen_random_uuid` 相關錯誤，請先確認 `./scripts/setup-docker.sh` 成功執行，且 `pgcrypto` 已建立。
- 權限：若腳本無法執行，請執行 `chmod +x scripts/*.sh`。

注意事項
- 本 PR 僅新增管理腳本與說明，不包含任何機密值或 `.env`。
- 若要在本機以非 Docker 方式運行，請參考 repo 的 README 與 `apps/*` 目錄內的指令。

如需我把腳本改為 bash、或自動用 `gh` 建 PR 的助手腳本，請告訴我。