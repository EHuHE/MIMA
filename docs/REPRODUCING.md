# 复现指南与证据边界

## 1. 完全自包含的检查

Python 3.10 以上即可运行，不需要网络和第三方包：

```bash
python3 -m pip install -e .
python3 -m unittest discover -s tests -v

for candidate in \
  s100_apl_94432cbb162fe56d \
  s100_apl_29fd2ff6b6c1dffd \
  s100_y1x4_3f8b9fd2cfc1e3ff \
  s100_cse27_3f9b3b31517bfce2
do
  mima-verify "candidates/${candidate}/theory.json"
done
```

这些命令验证合法门型、门输入数、单驱动、无环、纯组合结构、64 项真值表、理论最长路径、
声明延时、元数据哈希，以及理论 JSON 到 VHDL 的逐字节往返。

## 2. 配方重放与小型搜索

```bash
mima-replay-recipe \
  candidates/s100_apl_94432cbb162fe56d \
  candidates/s100_apl_29fd2ff6b6c1dffd

mima-replay-recipe \
  candidates/s100_y1x4_3f8b9fd2cfc1e3ff \
  candidates/s100_cse27_3f9b3b31517bfce2

mima-search-cse candidates/s100_y1x4_3f8b9fd2cfc1e3ff/theory.json --limit 10
```

搜索输出中的 `D_sta_ns` 固定为 `NOT_RUN`；只有真正完成统一 STA 后才能填写数值。

## 3. 可选 GHDL 仿真

```bash
mima-simulate candidates/s100_apl_29fd2ff6b6c1dffd/SB.vhd
mima-simulate candidates/s100_cse27_3f9b3b31517bfce2/SB.vhd
```

若 GHDL 不可用，命令返回 `NOT_RUN` 和原因，而不是把候选标成失败。本仓库的行为模型只用于
功能仿真，不参与 STA 或面积评价。

## 4. 官方理论检查与 STA

仓库包含赛题二 PDF 供题意核对，但不分发官方模板、理论校验器和标准单元库。取得这些
官方附件后，先依据 `THIRD_PARTY.md` 核对 SHA-256，再在仓库外准备一个新的运行目录；
不要在官方模板内生成结果。

官方理论校验命令形式为：

```bash
python3 <official-verifier> candidates/<candidate>/theory.json
```

实际评价必须固定并记录：

- Yosys 0.33；
- GHDL 4.1.0；
- OpenSTA 3.1.0；
- 指定 Nangate45 Liberty，SHA-256 见 `THIRD_PARTY.md`；
- 同一综合脚本、约束、六个输出端点和超时策略。

每次运行应使用全新的输出目录，保存完整命令、工具版本、综合日志、六输出 STA 报告、面积、
候选哈希和终态。依赖缺失写 `NOT_RUN`；执行超时写 `TIMEOUT`；只有完整执行后发现功能或结构
错误才写 `FAIL`。

## 5. 公开仓库没有包含什么

原始实验和双 fresh 审计保存在本地研究归档，不进入 Git。`results/release/current.json` 保存其
内容哈希，使汇总结论仍可回溯到原始证据，但公开克隆无法仅凭这些哈希重新生成历史 STA；
它可以重新运行独立功能/理论检查，并在自行取得合法工具和材料后重新运行 STA。
