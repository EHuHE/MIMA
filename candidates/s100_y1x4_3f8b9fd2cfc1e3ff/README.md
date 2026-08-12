# `s100_y1x4_3f8b9fd2cfc1e3ff`

这是 `s100_cse27_3f9b3b31517bfce2` 的直接父候选，保留它是为了确定性重放三个 CSE
合并操作。

- `D_theory = 197.952 ps`
- 门数：192
- 图 SHA-256：`3f8b9fd2cfc1e3ff8811db3413b4a623428f4685b8a3c8ad46f8741f84a1dc1c`

它本身会通过合法门型、单驱动、DAG、64 项真值表、理论延时和 VHDL 往返检查。公开结果不把
它作为新的最优点；它的职责是形成最小、可审计的生成链。

```bash
mima-verify candidates/s100_y1x4_3f8b9fd2cfc1e3ff/theory.json
```
