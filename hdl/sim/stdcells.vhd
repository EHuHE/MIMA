-- Independent behavioral models for the gate names emitted by mima_verify.
-- These models are used only for exhaustive functional simulation.

library ieee;
use ieee.std_logic_1164.all;
entity BUF_X1 is port (A : in std_logic; Z : out std_logic); end entity;
architecture sim of BUF_X1 is begin Z <= A; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity INV_X1 is port (A : in std_logic; ZN : out std_logic); end entity;
architecture sim of INV_X1 is begin ZN <= not A; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity NAND2_X1 is port (A1, A2 : in std_logic; ZN : out std_logic); end entity;
architecture sim of NAND2_X1 is begin ZN <= not (A1 and A2); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity NOR2_X1 is port (A1, A2 : in std_logic; ZN : out std_logic); end entity;
architecture sim of NOR2_X1 is begin ZN <= not (A1 or A2); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity AND2_X1 is port (A1, A2 : in std_logic; ZN : out std_logic); end entity;
architecture sim of AND2_X1 is begin ZN <= A1 and A2; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity OR2_X1 is port (A1, A2 : in std_logic; ZN : out std_logic); end entity;
architecture sim of OR2_X1 is begin ZN <= A1 or A2; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity XOR2_X1 is port (A, B : in std_logic; Z : out std_logic); end entity;
architecture sim of XOR2_X1 is begin Z <= A xor B; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity XNOR2_X1 is port (A, B : in std_logic; ZN : out std_logic); end entity;
architecture sim of XNOR2_X1 is begin ZN <= A xnor B; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity NAND3_X1 is port (A1, A2, A3 : in std_logic; ZN : out std_logic); end entity;
architecture sim of NAND3_X1 is begin ZN <= not (A1 and A2 and A3); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity NOR3_X1 is port (A1, A2, A3 : in std_logic; ZN : out std_logic); end entity;
architecture sim of NOR3_X1 is begin ZN <= not (A1 or A2 or A3); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity AND3_X1 is port (A1, A2, A3 : in std_logic; ZN : out std_logic); end entity;
architecture sim of AND3_X1 is begin ZN <= A1 and A2 and A3; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity OR3_X1 is port (A1, A2, A3 : in std_logic; ZN : out std_logic); end entity;
architecture sim of OR3_X1 is begin ZN <= A1 or A2 or A3; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity AOI21_X1 is port (B1, B2, A : in std_logic; ZN : out std_logic); end entity;
architecture sim of AOI21_X1 is begin ZN <= not ((B1 and B2) or A); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity OAI21_X1 is port (B1, B2, A : in std_logic; ZN : out std_logic); end entity;
architecture sim of OAI21_X1 is begin ZN <= not ((B1 or B2) and A); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity MUX2_X1 is port (A, B, S : in std_logic; Z : out std_logic); end entity;
architecture sim of MUX2_X1 is begin Z <= A when S = '0' else B; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity OAI22_X1 is port (A1, A2, B1, B2 : in std_logic; ZN : out std_logic); end entity;
architecture sim of OAI22_X1 is begin ZN <= not ((A1 or A2) and (B1 or B2)); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity AOI22_X1 is port (A1, A2, B1, B2 : in std_logic; ZN : out std_logic); end entity;
architecture sim of AOI22_X1 is begin ZN <= not ((A1 and A2) or (B1 and B2)); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity NAND4_X1 is port (A1, A2, A3, A4 : in std_logic; ZN : out std_logic); end entity;
architecture sim of NAND4_X1 is begin ZN <= not (A1 and A2 and A3 and A4); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity NOR4_X1 is port (A1, A2, A3, A4 : in std_logic; ZN : out std_logic); end entity;
architecture sim of NOR4_X1 is begin ZN <= not (A1 or A2 or A3 or A4); end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity AND4_X1 is port (A1, A2, A3, A4 : in std_logic; ZN : out std_logic); end entity;
architecture sim of AND4_X1 is begin ZN <= A1 and A2 and A3 and A4; end architecture;

library ieee;
use ieee.std_logic_1164.all;
entity OR4_X1 is port (A1, A2, A3, A4 : in std_logic; ZN : out std_logic); end entity;
architecture sim of OR4_X1 is begin ZN <= A1 or A2 or A3 or A4; end architecture;
