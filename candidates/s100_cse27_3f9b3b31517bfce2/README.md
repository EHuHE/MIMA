# `s100_cse27_3f9b3b31517bfce2`

当前已验证搜索范围内、`D_theory = 197.952 ps` 这一组中的低面积代表。

- 直接父候选：`s100_y1x4_3f8b9fd2cfc1e3ff`
- 变换：合并三组 64 位真值签名完全相同的内部网络
- `D_theory = 197.952 ps`
- `D_sta = 0.279394060373 ns`
- 面积：`248.710 GE`
- 门数：189

它比 STA 代表少 `1.064 GE`，但实际延时略高，因此两者互不支配并同时保留；这不是全局
最优证明。`metadata.json` 保存三个 CSE 操作、父图与内容哈希。复验命令：

```bash
mima-verify candidates/s100_cse27_3f9b3b31517bfce2/theory.json
mima-replay-recipe \
  candidates/s100_y1x4_3f8b9fd2cfc1e3ff \
  candidates/s100_cse27_3f9b3b31517bfce2
```

STA 原始运行依赖未随仓库分发的官方流程和固定工具链。可审计的结果摘要与原始证据哈希见
`results/release/current.json`。
