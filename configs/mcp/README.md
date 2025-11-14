# MCP config 範本（configs/mcp）

目的
- 存放與 metamcp 專案直接相關的 MCP 設定範本（不含任何私人 API key）。
- 團隊成員可從這裡複製合適的範本到自己的 VS Code `mcp.json`（或匯入到其他 MCP client）。

檔案
- `metamcp.example.json`：只包含 metamcp 本身的 entry（指向本地前端/後端）。
- `qdrant.example.json`：qdrant 的啟動/連線範本（不含 key）。
- `huggingface.example.json`：HuggingFace MCP 範本（不含 key）。
- `bootstrap.sh`：一鍵建立範本檔並可選擇把 metamcp entry 複製到使用者 VS Code mcp.json（需要使用者同意，且不會寫入任何 key）。

使用範例
1. 取得 repo 最新後（或由維護者已經放好）：
   - `ls configs/mcp` 會顯示三個範本與 `bootstrap.sh`。

2. 如果你想把 metamcp 範本匯入到本機 VS Code（一次性動作）：
   - 先備份你現在的 MCP 設定（很重要）：
     ```
     cp "$HOME/Library/Application Support/Code/User/mcp.json" "$HOME/Library/Application Support/Code/User/mcp.json.bak"
     ```
   - 使用 `bootstrap.sh` 的匯入功能（會提示你確認）：
     ```
     configs/mcp/bootstrap.sh --import-to-vscode
     ```

匯入前請先確認你的 VS Code user mcp.json 路徑是正確的，`bootstrap.sh` 會先備份現有檔案。

安全性
- 範本檔 `*.example.json` 不會含 API keys 或私人路徑。  
- 請勿把 `mcp.json`（含 key）放到 repo；維護者或 CI 需要時使用 secrets 管理。

如果你要我把這些檔案放到 repo 的其他位置或以不同格式（例如 `.vscode/`），請告知。