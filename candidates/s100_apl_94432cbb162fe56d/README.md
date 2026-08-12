# `s100_apl_94432cbb162fe56d`

这是 `s100_apl_29fd2ff6b6c1dffd` 的直接父候选，保留它是为了让最终局部替换能够从一个
公开、固定哈希的输入逐字节重放。

- `D_theory = 197.952 ps`
- 门数：190
- 图 SHA-256：`94432cbb162fe56d292cd3de47fd06204b01f70623827a77576714057c455cdc`

它本身会通过合法门型、单驱动、DAG、64 项真值表、理论延时和 VHDL 往返检查。公开结果不把
它作为新的最优点；它的职责是形成最小、可审计的生成链。

```bash
mima-verify candidates/s100_apl_94432cbb162fe56d/theory.json
```
