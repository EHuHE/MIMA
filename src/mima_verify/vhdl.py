"""Deterministic structural VHDL renderer for the theory JSON format."""

from __future__ import annotations

from typing import Any, Mapping

from .core import VerificationError, validate_structure


PORTS: dict[str, tuple[tuple[str, ...], str]] = {
    "INV": (("A",), "ZN"),
    "BUF": (("A",), "Z"),
    "NAND2": (("A1", "A2"), "ZN"),
    "NOR2": (("A1", "A2"), "ZN"),
    "AND2": (("A1", "A2"), "ZN"),
    "OR2": (("A1", "A2"), "ZN"),
    "XOR2": (("A", "B"), "Z"),
    "XNOR2": (("A", "B"), "ZN"),
    "NAND3": (("A1", "A2", "A3"), "ZN"),
    "AOI21": (("B1", "B2", "A"), "ZN"),
    "OAI21": (("B1", "B2", "A"), "ZN"),
    "NOR3": (("A1", "A2", "A3"), "ZN"),
    "AND3": (("A1", "A2", "A3"), "ZN"),
    "OR3": (("A1", "A2", "A3"), "ZN"),
    "MUX2": (("A", "B", "S"), "Z"),
    "OAI22": (("A1", "A2", "B1", "B2"), "ZN"),
    "AOI22": (("A1", "A2", "B1", "B2"), "ZN"),
    "NAND4": (("A1", "A2", "A3", "A4"), "ZN"),
    "NOR4": (("A1", "A2", "A3", "A4"), "ZN"),
    "AND4": (("A1", "A2", "A3", "A4"), "ZN"),
    "OR4": (("A1", "A2", "A3", "A4"), "ZN"),
}

LEGACY_COMPONENT_ORDER = (
    "BUF",
    "INV",
    "NAND2",
    "AND2",
    "XNOR2",
    "NAND3",
    "OAI21",
    "AND3",
    "NAND4",
    "AND4",
    "NOR2",
    "OAI22",
    "AOI22",
    "OR2",
    "XOR2",
    "AOI21",
    "NOR3",
    "OR3",
    "MUX2",
    "NOR4",
    "OR4",
)


def _net(name: str) -> str:
    if len(name) == 2 and name[0] == "x" and name[1].isdigit():
        return f"input({name[1]})"
    return name


def render_vhdl(spec: Mapping[str, Any]) -> bytes:
    """Render exactly the stable VHDL representation bound by candidate hashes."""

    validate_structure(spec)
    gates = spec["gates"]
    # The newest ablation renderer sorted declarations. Earlier promoted
    # candidates retained first-use order. Both profiles are content-bound in
    # metadata, so select the historical profile deterministically by name.
    if str(spec.get("name", "")).startswith("apn_sbox_diag_cw20_single_"):
        used_types = sorted({gate["type"] for gate in gates})
    else:
        present = {gate["type"] for gate in gates}
        used_types = [gate_type for gate_type in LEGACY_COMPONENT_ORDER if gate_type in present]
    lines = [
        "library IEEE;",
        "use IEEE.STD_LOGIC_1164.ALL;",
        "",
        "entity SB is",
        "    Port ( input : in STD_LOGIC_VECTOR (5 downto 0);",
        "           output : out STD_LOGIC_VECTOR (5 downto 0));",
        "end SB;",
        "",
        "architecture Structural of SB is",
        "",
    ]
    for gate_type in used_types:
        try:
            input_ports, output_port = PORTS[gate_type]
        except KeyError as exc:
            raise VerificationError(f"no VHDL port map for {gate_type}") from exc
        lines.extend(
            [
                f"    component {gate_type}_X1 is",
                "        Port ( "
                + ", ".join(input_ports)
                + f" : in STD_LOGIC; {output_port} : out STD_LOGIC);",
                "    end component;",
                "",
            ]
        )

    signals = [gate["out"] for gate in gates]
    for offset in range(0, len(signals), 8):
        lines.append("    signal " + ", ".join(signals[offset : offset + 8]) + " : STD_LOGIC;")
    lines.extend(["", "begin", ""])

    for gate in gates:
        input_ports, output_port = PORTS[gate["type"]]
        bindings = [f"{port} => {_net(net)}" for port, net in zip(input_ports, gate["in"])]
        bindings.append(f"{output_port} => {gate['out']}")
        lines.append(
            f"    u_{gate['id']} : {gate['type']}_X1 Port Map (" + ", ".join(bindings) + ");"
        )

    lines.append("")
    for index in range(6):
        lines.append(f"    output({index}) <= {spec['outputs'][f'y{index}']};")
    lines.extend(["", "end Structural;"])
    return ("\n".join(lines) + "\n").encode("utf-8")
