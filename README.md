# MIMA：固定 6 比特 APN S 盒的低延时实现

> English summary: this repository contains an independently reproducible,
> dependency-free verifier, deterministic recipe replay, a small CSE searcher,
> and four retained structural candidates for one fixed 6-bit APN S-box. It
> includes the official problem statement for reference, while excluding
> proprietary cell libraries, raw experiments, personal data, and bundled EDA
> binaries.

本项目研究一个固定 6 比特 APN 置换 S 盒的纯组合门级实现，同时维护两个互不替代的
目标：理论门延时模型下的 `D_theory`，以及统一综合、映射和 STA 流程下的 `D_sta`。
这里的“最好”都限定为当前已验证搜索范围，不声称全局最优。

赛题原文：[第十一届（2026）全国高校密码数学挑战赛赛题二 PDF](problem/2026密码数学挑战赛-赛题二.pdf)。
该 PDF 的版权归原权利人所有，不受本项目 MIT 许可证覆盖；仓库公开前仍需确认其再分发许可。

## 当前结果

| 候选 | 角色 | `D_theory` | `D_sta` | 面积 |
|---|---|---:|---:|---:|
| `s100_apl_29fd2ff6b6c1dffd` | 当前 STA/综合得分代表 | 197.952 ps | 0.278555244207 ns | 249.774 GE |
| `s100_cse27_3f9b3b31517bfce2` | 同理论延时组的低面积代表 | 197.952 ps | 0.279394060373 ns | 248.710 GE |

两个点互不支配，因此同时保留。对应的直接父候选也保存在 `candidates/`，用于逐字节重放
生成配方。完整机器可读快照见 `results/release/current.json`。

## 初学者先理解这条链

```text
固定真值表
  -> 用合法逻辑门组成无环图 DAG
  -> 64 个输入全部仿真
  -> 按门延时做加权最长路径，得到 D_theory
  -> 生成结构化 VHDL
  -> 用同一工具链综合、映射和 STA，得到 D_sta 与面积
  -> 分别维护理论榜、STA 榜和 Pareto 前沿
```

`D_theory` 是图上的确定性最长路径，适合快速筛选；`D_sta` 还受引脚、扇出、映射和
工具启发式影响，所以理论相同的候选仍可能有不同 STA。算法与搜索策略的详细入门说明见
[算法说明](docs/ALGORITHMS.md)，复现边界和命令见[复现指南](docs/REPRODUCING.md)。

## 五分钟验证

只需要 Python 3.10 或更高版本，无第三方 Python 依赖：

```bash
python3 -m pip install -e .
mima-verify candidates/s100_apl_29fd2ff6b6c1dffd/theory.json
mima-verify candidates/s100_cse27_3f9b3b31517bfce2/theory.json
python3 -m unittest discover -s tests -v
```

从直接父候选重放两个最终结构：

```bash
mima-replay-recipe \
  candidates/s100_apl_94432cbb162fe56d \
  candidates/s100_apl_29fd2ff6b6c1dffd

mima-replay-recipe \
  candidates/s100_y1x4_3f8b9fd2cfc1e3ff \
  candidates/s100_cse27_3f9b3b31517bfce2
```

如果系统已安装 GHDL，还可以直接穷举结构化 VHDL：

```bash
mima-simulate candidates/s100_apl_29fd2ff6b6c1dffd/SB.vhd
```

## 仓库边界

- 跟踪：赛题二 PDF、独立验证/搜索源码、四个候选、精简结果、测试和说明。
- 不跟踪：其他官方附件、官方模板、Nangate 门库、EDA 二进制、虚拟环境、原始实验、
  论文、演示文件和最终提交压缩包。
- STA 结果来自固定的 Yosys 0.33、GHDL 4.1.0、OpenSTA 3.1.0 和指定 Liberty 快照；
  缺少这些依赖时状态必须写为 `NOT_RUN`，不能写成候选失败。
- 仓库在竞赛结束并确认规则允许前保持私有；公开前必须再次执行发布审计。

```bash
mima-release-audit --root .
```

第三方材料不受本项目 MIT 许可证覆盖，详见 [THIRD_PARTY.md](THIRD_PARTY.md)。
