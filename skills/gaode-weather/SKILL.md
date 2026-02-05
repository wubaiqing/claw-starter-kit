---
name: gaode-weather
description: 使用高德地图天气 API 获取每日天气（城市 code 如 110114 昌平），从 .env 环境变量 AMAP_WEATHER_KEY 读取 key。用于定时天气推送、替代 wttr.in、在国内网络更稳定时获取实时天气。
---

# gaode-weather

用高德天气 API 拉取“实况天气（extensions=base）”，并输出一行适合推送的中文文案。

## 前置：配置 Key

把 Key 放到 **OpenClaw 运行环境的 .env** 里（例如 OpenClaw 的运行环境变量文件），变量名：

```
AMAP_WEATHER_KEY="<your-key>"
```

（不要把 key 提交到 git。）

## 用法

在项目根目录下：

```bash
bash skills/gaode-weather/scripts/gaode-weather.sh 110114
```

- 参数是高德 `city` code（默认 110114 / 昌平）。
- 成功：stdout 输出一行天气。
- 失败：stdout 输出失败原因，并返回非 0（调用方可兜底）。

## 推荐输出格式

`【每日天气】北京·昌平：晴 11°C｜湿度 38%｜风 东南 3级（高德 2026-02-04 16:30）`

## 注意

- 不要在日志/输出里打印 key。
- API：`https://restapi.amap.com/v3/weather/weatherInfo?city=<code>&extensions=base&output=JSON&key=<key>`
