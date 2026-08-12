# `s100_apl_29fd2ff6b6c1dffd`

当前已验证搜索范围内的 STA/综合得分代表，也是四个保留候选中的最终提交结构。

- 直接父候选：`s100_apl_94432cbb162fe56d`
- 变换：用一个等价 `OAI21` 替换局部 `NAND2` 连接，并删除一项死逻辑
- `D_theory = 197.952 ps`
- `D_sta = 0.278555244207 ns`
- 面积：`249.774 GE`
- 门数：189

这些数值是当前搜索范围内的已验证结果，不是全局最优证明。`metadata.json` 保存父图、配方与
内容哈希；可以执行以下命令进行自包含验证和逐字节配方重放：

```bash
mima-verify candidates/s100_apl_29fd2ff6b6c1dffd/theory.json
mima-replay-recipe \
  candidates/s100_apl_94432cbb162fe56d \
  candidates/s100_apl_29fd2ff6b6c1dffd
```

STA 原始运行依赖未随仓库分发的官方流程和固定工具链。可审计的结果摘要与原始证据哈希见
`results/release/current.json`。
