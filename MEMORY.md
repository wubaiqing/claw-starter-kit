# MEMORY.md - 助手的长期记忆

*这里记录重要的事情、决定、偏好和经验教训。*
*助手会在日常工作中自动维护这个文件。*

## 关于主人

## 重要事件

## 经验与教训

- 多 agent 场景下如果出现 “No API key found for provider openai-codex”，优先检查各 agent 的 `auth-profiles.json` 是否存在且已授权；实践上可让子 agent 的 `auth-profiles.json` 软链接到 `agents/main/auth-profiles.json`，避免 token 刷新后不同步。

## 偏好与习惯

- 日历/会议时间展示：统一以北京时间（Asia/Shanghai）为准。
- Telegram 定时任务（cron）默认投递到群「智囊军团」(telegram:-5286513234)，不要私聊嗖嗖；如需私聊必须显式说明。

## 系统约定（工作区与技能）

- Skills 分层：系统级 skills 与自定义 skills 分离；**自定义优先于系统**（同名时以自定义为准）。
- 天气：日常天气推送只使用高德天气 API（昌平 `city=110114`，key 走环境变量 `AMAP_WEATHER_KEY`）。
- 文档/记忆里避免出现具体服务器路径、token 等敏感信息。
