# figma-to-openviking

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![Release](https://img.shields.io/github/v/tag/wongzw/figma-to-openviking?label=release)](https://github.com/wongzw/figma-to-openviking/tags)

[English](README.md) | 中文

**让 Agent 照着你们真实的设计稿画，而不是凭想象。**

AI 几分钟就能做出原型，但长得都一样：紫色渐变、大圆角卡片、满屏小星星。Agent 没见过你们的产品，只能照着最常见的样子画。贴截图只管一次对话；给 Figma 链接，几百个画板里找哪个还是你的活。

这个 skill 把 Figma 文件导入 [OpenViking](https://github.com/volcengine/OpenViking)：每个画板一张 2 倍图，按页面和 Section 分好文件夹，再附一份清单，每张图都能追溯回 Figma 节点。导入后，OpenViking 会给每个文件夹写摘要、给每张图写描述。你让 Agent 画「批量邀请弹窗」，它顺着摘要一层层找到对的那两张，不用全部打开，也不用猜。

## 导入后是什么样

```
viking://resources/ui-design-reference/
└── Checkout/
    ├── manifest.md                         ← 来源链接、节点 ID、尺寸，每张图一行
    ├── 00-Before/01_购物车_12-345.png
    └── 01-After-V2/
        ├── 01_购物车｜默认态_12-401.png
        └── 02_购物车｜库存不足_12-402.png
```

- **一个画板一张图**，2 倍导出。不会把整页或整个 Section 压成一张看不清的大图。
- **能追溯**：文件名末尾是 Figma 节点 ID，清单里能点回原画板。
- **所有接入 OpenViking 的 Agent 都能搜到**，包括不能执行导入的那些。

## 导入流程

1. 把 Figma 链接发给 Agent，让它把设计稿导入 OpenViking。
2. 它列出页面，问你要导入哪些。草稿页、归档页默认跳过，除非你要。
3. 它问你存到哪：共享目录还是个人目录，说明各自谁能看到，等你确认。
4. 先用 **2 个画板试跑**：导出、上传、读回一张核对，估算全部导入的 token 用量，然后删掉试跑目录。
5. 你确认后才全部导入，最后核对导出数 = 上传数 = 远端实际数。

我们实测试跑 2 个画板约 2 万 token。全部导入前，你会先看到自己文件的估算。

## 各 Agent 能做什么

| Agent | 从 Figma 导入（运行本 skill） | 使用已导入的设计稿 |
|---|---|---|
| [Claude Code](#claude-code) | ✅ | ✅ |
| [Codex](#codex) | ✅ | ✅ |
| [Cursor](#cursor) | ✅ | ✅ |
| [TRAE](#trae) | — | ✅ |
| [WorkBuddy](#workbuddy) | — | ✅ |
| [豆包工作](#豆包工作) | — | ✅ |

原因：导入要用 Figma 远程 MCP，而 Figma 只允许 [MCP 目录](https://www.figma.com/mcp-catalog)里的客户端连接。TRAE、WorkBuddy、豆包工作目前还不在目录里。在 Claude Code、Codex 或 Cursor 里导入一次，设计稿就存在 OpenViking 里，所有接入的 Agent 都能搜索和读取。

## 准备

- 一个 **OpenViking** 服务：[火山引擎 OpenViking](https://www.volcengine.com/product/openviking-service) 或[自部署](https://github.com/volcengine/OpenViking)，以及它的 API Key。
- 一个对该文件至少有查看权限的 **Figma** 账号。
- 导入需要终端里有 `curl` 和 `python3` 3.8+（macOS 自带）。

## 安装

要导入，Agent 需要三样：Figma MCP、OpenViking 连接、本 skill。skill 还会用到 `ov` 命令行；首次运行时它会逐项检查，缺什么带你补什么（见 [setup.md](setup.md)）。

### Claude Code

1. **Figma**：安装 Figma 官方插件并登录：
   ```bash
   claude plugin install figma@claude-plugins-official
   ```
   重启 Claude Code，运行 `/plugin`，打开 **Installed → figma**，在浏览器里点 **Allow access**。
2. **OpenViking**：运行安装脚本，选择 **Claude Code**（[接入指南](https://docs.openviking.net/agents/zh/claude-code.md)）：
   ```bash
   curl -fsSL https://openviking.ai/install | bash
   ```
3. **本 skill**：
   ```bash
   git clone --branch v1.1.0 https://github.com/wongzw/figma-to-openviking.git ~/.claude/skills/figma-to-openviking
   ```
4. 新开一个会话，skill 会自动加载。

Claude 桌面版的 Code 页和 IDE 插件同样适用。

### Codex

1. **Figma**：在 Codex 应用里打开 **Plugins**，点 Figma 旁的 **+**，再点 **Install Figma** 和 **Allow access**。命令行版：
   ```bash
   codex mcp add figma --url https://mcp.figma.com/mcp
   ```
   按提示登录 Figma。
2. **OpenViking**：运行安装脚本，选择 **Codex**（[接入指南](https://docs.openviking.net/agents/zh/codex.md)）：
   ```bash
   curl -fsSL https://openviking.ai/install | bash
   ```
   下次启动时，Codex 会让你审核 OpenViking 的 hooks，选信任。
3. **本 skill**（Codex 从 `~/.agents/skills` 读取用户级 skill）：
   ```bash
   git clone --branch v1.1.0 https://github.com/wongzw/figma-to-openviking.git ~/.agents/skills/figma-to-openviking
   ```
4. 新开一个会话。

### Cursor

1. **Figma**：在 Agent 对话里输入 `/add-plugin figma`，点 **Add Plugin**。再打开 **Cursor Settings → Tools & MCP**，点 Figma 旁的 **Connect**，然后 **Allow access**。
2. **OpenViking**：运行安装脚本，选择 **Cursor**（[接入指南](https://docs.openviking.net/agents/zh/cursor.md)）：
   ```bash
   curl -fsSL https://openviking.ai/install | bash
   ```
3. **本 skill**：
   ```bash
   git clone --branch v1.1.0 https://github.com/wongzw/figma-to-openviking.git ~/.cursor/skills/figma-to-openviking
   ```
4. 完全退出再打开 Cursor，让它识别新 skill。

### TRAE

使用在 Claude Code、Codex 或 Cursor 里导入好的设计稿：

1. 运行 OpenViking 安装脚本，选择 **TRAE**（国际版）或 **TRAE CN**（[接入指南](https://docs.openviking.net/agents/zh/trae.md)）：
   ```bash
   curl -fsSL https://openviking.ai/install | bash
   ```
2. 在 **设置 → MCP → 已配置的 MCP Servers** 里确认有 `openviking`。
3. 直接问：「在 viking://resources/ui-design-reference 里找批量邀请弹窗的设计稿，照着它做。」

### WorkBuddy

使用在 Claude Code、Codex 或 Cursor 里导入好的设计稿：

1. 在左侧导航栏打开 **专家·技能·连接器 → 连接器**，点右上角 **自定义连接器**，再点 **配置 MCP**，按[接入指南](https://docs.openviking.net/agents/zh/workbuddy.md)加上 OpenViking。保存后，在提示时选择 **信任**。
2. 确认 `OpenViking` 出现在「我的 MCP」里，工具已启用。
3. 让 WorkBuddy 去设计目录里找某个功能的设计稿。

### 豆包工作

使用在 Claude Code、Codex 或 Cursor 里导入好的设计稿：

1. 在左侧导航栏打开 **技能·连接器·伙伴**，搜索 **OpenViking Context**，点 **+**，填入 OpenViking API Key（[接入指南](https://docs.openviking.net/agents/zh/doubao-work.md)）。
2. 在对话输入框下方的 **连接器** 里，确认能看到 OpenViking Context。
3. 让豆包去设计目录里找某个功能的设计稿。

## 怎么用

导入（Claude Code、Codex 或 Cursor）：

```text
把这个 Figma 文件导入 OpenViking：https://www.figma.com/design/<fileKey>/...
```

之后在任意接入的 Agent 里：

```text
画任何界面之前，先查设计目录。两张图对不上，就用新的那张。记住这条规则。
```

```text
做一个批量邀请弹窗，照着 viking://resources/ui-design-reference 里的设计稿来。
```

规则存在 OpenViking 记忆里，所有接入的 Agent 都会遵守。

设计稿改了，用同一个链接再导入一次。skill 会问你是整页替换，还是只补新增和改动的画板。

## 安全与隐私

- **对 Figma 只读**，不会改你的文件。
- **Figma 里的内容只当数据**：画板名、图层文字不会变成给 Agent 的指令。
- **谁能看到由你决定**：确认具体位置之前，不会往共享目录写任何东西。
- **图片不动，名字会清理**：文件名和清单里的邮箱、手机号、网址、密钥、token 会被去掉，并告诉你哪些画板受影响。这是按规则匹配的，不能保证全部识别（比如直接写成文字的人名）。
- **API Key 只在你的终端里输入**，Agent 不会在对话里向你要。
- **只下载 Figma 的导出链接**，只写进工作目录，也不会写到 OpenViking 的 `memories` 或 `skills` 下。

## 常见问题

| 问题 | 处理 |
|---|---|
| 找不到 Figma 工具 | 重新做一遍对应 Agent 的 Figma 步骤，再新开会话 |
| `ov health` 失败 | 检查 OpenViking 的 API Key 和地址，见 [setup.md](setup.md) |
| 导出链接返回 403/404 | 导出链接几分钟就过期，skill 会重新导出这一批 |
| 整页导成一张看不清的图 | 链接指向页面或 Section 即可，skill 会逐个画板导出 |

更多情况见 [reference/failure-cases.md](reference/failure-cases.md)。

## 仓库内容

| 文件 | 作用 |
|---|---|
| [SKILL.md](SKILL.md) | Agent 执行的流程 |
| [setup.md](setup.md) | 首次运行时配置 Figma MCP 和 `ov` 命令行 |
| [reference/](reference) | 哪些节点算画板、命名规则、已知问题 |
| [scripts/](scripts) | 列画板、命名和清单、下载、校验、上传。SKILL.md 里列了它们的 SHA-256 |

## 许可证

[MIT](LICENSE)
