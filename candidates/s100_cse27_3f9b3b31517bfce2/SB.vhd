library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SB is
    Port ( input : in STD_LOGIC_VECTOR (5 downto 0);
           output : out STD_LOGIC_VECTOR (5 downto 0));
end SB;

architecture Structural of SB is

    component BUF_X1 is
        Port ( A : in STD_LOGIC; Z : out STD_LOGIC);
    end component;

    component INV_X1 is
        Port ( A : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component NAND2_X1 is
        Port ( A1, A2 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component AND2_X1 is
        Port ( A1, A2 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component XNOR2_X1 is
        Port ( A, B : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component NAND3_X1 is
        Port ( A1, A2, A3 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component OAI21_X1 is
        Port ( B1, B2, A : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component AND3_X1 is
        Port ( A1, A2, A3 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component NAND4_X1 is
        Port ( A1, A2, A3, A4 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component AND4_X1 is
        Port ( A1, A2, A3, A4 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component NOR2_X1 is
        Port ( A1, A2 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component OAI22_X1 is
        Port ( A1, A2, B1, B2 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    component AOI22_X1 is
        Port ( A1, A2, B1, B2 : in STD_LOGIC; ZN : out STD_LOGIC);
    end component;

    signal y0_bx0, y0_bx1, y0_bx2, y0_bx3, y0_bx4, y0_bx5, y0_ix0, y0_ix1 : STD_LOGIC;
    signal y0_ix2, y0_ix3, y0_ix4, y0_ix5, y1_bx2, y1_bx3, y1_bx4, y1_bx5 : STD_LOGIC;
    signal y1_ix0, y1_ix1, y1_ix2, y1_ix3, y1_ix4, y1_ix5, y2_bx0, y2_bx1 : STD_LOGIC;
    signal y2_bx2, y2_bx3, y2_bx4, y2_bx5, y2_ix0, y2_ix1, y2_ix2, y2_ix3 : STD_LOGIC;
    signal y2_ix4, y2_ix5, y3_bx1, y3_bx3, y3_bx4, y3_bx5, y4_bx0, y4_bx1 : STD_LOGIC;
    signal y4_bx2, y4_bx3, y5_bx3, y5_bx5, y5_f_g3_p1012_right_local_bx1, y0_f_g0_c0_nprod, y0_f_g0_c1_nprod, y0_f_g1_c0_nprod : STD_LOGIC;
    signal y0_f_g1_c2_nprod, y0_f_g1_p13_common, y0_f_g2_p78_common, y0_f_g2_p78_left, y0_f_g2_p910_common, y0_f_g2_p910_xnor, y0_f_g3_x0_c0_nprod, y0_f_g3_x0_c1_nprod : STD_LOGIC;
    signal y0_f_g3_x0_c2_nprod, y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n0, y1_f_g0_c1_nprod, y1_f_g0_c2_nprod, y1_f_g0_c3_nprod, y1_f_g1_p46_common, y1_f_g1_p57_common, y1_f_g1_p57_left_neg : STD_LOGIC;
    signal y1_f_g1_p57_right_neg, y1_f_g2_p1011_common, y1_f_g2_p1011_left_neg, y1_f_g2_p1011_right_neg, y1_f_g2_p89_common, y1_f_g2_p89_xnor, y1_f_g3_p1213_common, y1_f_g3_p1213_left : STD_LOGIC;
    signal y1_f_g3_p1213_right, y2_f_g0_c0_nprod, y2_f_g0_c1_nprod, y2_f_g0_c2_nprod, y2_f_g0_c3_nprod, y2_f_g1a_common, y2_f_g1a_left, y2_f_g1a_right : STD_LOGIC;
    signal y2_f_g1b_common, y2_f_g1b_left, y2_f_g1b_right, y2_f_g2a_common, y2_f_g2a_xnor, y2_f_g2b_common, y2_f_g2b_left, y2_f_g2b_right : STD_LOGIC;
    signal y2_f_g3a_common, y2_f_g3a_left, y2_f_g3a_right, y2_f_g3b_common, y2_f_g3b_left, y2_f_g3b_right, y3_f_g0_p03_common, y3_f_g0_p03_left : STD_LOGIC;
    signal y3_f_g0_p03_right, y3_f_g0_p12_left, y3_f_g0_p12_right, y3_f_g1_p47_common, y3_f_g1_p47_left, y3_f_g1_p47_right, y3_f_g1_p56_common, y3_f_g1_p56_left : STD_LOGIC;
    signal y3_f_g1_p56_right, y3_f_g2_p1011_common, y3_f_g2_p1011_left, y3_f_g2_p1011_right, y3_f_g2_p89_common, y3_f_g2_p89_left, y3_f_g2_p89_right, y3_f_g3_p1213_common : STD_LOGIC;
    signal y3_f_g3_p1213_right, y4_c1_nprod, y4_c2_nprod, y4_c3_nprod, y4_c4_nprod, y4_c5_nprod, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_common, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_left : STD_LOGIC;
    signal y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_right, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg2_common, r47_y4_and4_negative, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_left, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_right, y5_f_g0_c1_nprod, y5_f_g0_c2_nprod, y5_f_g0_c3_nprod : STD_LOGIC;
    signal y5_f_g1_c0_nprod, y5_f_g1_c1_nprod, y5_f_g1_c2_nprod, y5_f_g2_p78_xnor, y5_f_g3_p1012_common, y5_f_g3_p1012_left, y5_f_g3_p1012_right, y5_f_g3_p911_common : STD_LOGIC;
    signal y5_f_g3_p911_left, y5_f_g3_p911_right, y0_f_g1_p13_neg, y0_f_g2_p78_lor, y0_f_g3_x0_res_or, y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n1, r47_y1_and4_negative, y1_f_g0_neg : STD_LOGIC;
    signal y1_f_g1_p57_lor, y1_f_g2_p1011_lor, y1_f_g3_p1213_neg, y2_f_g0_neg, y2_f_g1a_lor, y2_f_g1b_lor, y2_f_g2b_lor, y2_f_g3a_lor : STD_LOGIC;
    signal y2_f_g3b_lor, y3_f_g0_p03_lor, y3_f_g0_p12_lor, y3_f_g1_p47_lor, y3_f_g1_p56_lor, y3_f_g2_p1011_lor, y3_f_g2_p89_lor, y3_f_g3_p1213_neg : STD_LOGIC;
    signal y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_left_pos, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_right_pos, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_nor, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg2_nor, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_nor, y5_f_g0_neg, y5_f_g1_neg, y5_f_g2_p78_neg : STD_LOGIC;
    signal y5_f_g3_p1012_lor, y0_f_g2_neg, y0_f_g3_neg, y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n2, y2_f_g1_neg, y2_f_g2_neg, y2_f_g3_neg, y3_f_g0_neg : STD_LOGIC;
    signal y3_f_g1_neg, y3_f_g2_neg, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_nor, r40_y5k2_d5a95ec45789ce72_n0, y5_f_g3_neg, y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1, r42_y1k3_5b94b51f9e719569_n0, r42_y1k3_5b94b51f9e719569_n1 : STD_LOGIC;
    signal y1_factored_pairs, y2_st_g1aix3_g3b501_out_g2_g130_legal, y3_factored_pairs, y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1, y5_st_p1012_out_g3_a1 : STD_LOGIC;

begin

    u_y0_bx0 : BUF_X1 Port Map (A => input(0), Z => y0_bx0);
    u_y0_bx1 : BUF_X1 Port Map (A => input(1), Z => y0_bx1);
    u_y0_bx2 : BUF_X1 Port Map (A => input(2), Z => y0_bx2);
    u_y0_bx3 : BUF_X1 Port Map (A => input(3), Z => y0_bx3);
    u_y0_bx4 : BUF_X1 Port Map (A => input(4), Z => y0_bx4);
    u_y0_bx5 : BUF_X1 Port Map (A => input(5), Z => y0_bx5);
    u_y0_ix0 : INV_X1 Port Map (A => input(0), ZN => y0_ix0);
    u_y0_ix1 : INV_X1 Port Map (A => input(1), ZN => y0_ix1);
    u_y0_ix2 : INV_X1 Port Map (A => input(2), ZN => y0_ix2);
    u_y0_ix3 : INV_X1 Port Map (A => input(3), ZN => y0_ix3);
    u_y0_ix4 : INV_X1 Port Map (A => input(4), ZN => y0_ix4);
    u_y0_ix5 : INV_X1 Port Map (A => input(5), ZN => y0_ix5);
    u_y1_bx2 : BUF_X1 Port Map (A => input(2), Z => y1_bx2);
    u_y1_bx3 : BUF_X1 Port Map (A => input(3), Z => y1_bx3);
    u_y1_bx4 : BUF_X1 Port Map (A => input(4), Z => y1_bx4);
    u_y1_bx5 : BUF_X1 Port Map (A => input(5), Z => y1_bx5);
    u_y1_ix0 : INV_X1 Port Map (A => input(0), ZN => y1_ix0);
    u_y1_ix1 : INV_X1 Port Map (A => input(1), ZN => y1_ix1);
    u_y1_ix2 : INV_X1 Port Map (A => input(2), ZN => y1_ix2);
    u_y1_ix3 : INV_X1 Port Map (A => input(3), ZN => y1_ix3);
    u_y1_ix4 : INV_X1 Port Map (A => input(4), ZN => y1_ix4);
    u_y1_ix5 : INV_X1 Port Map (A => input(5), ZN => y1_ix5);
    u_y2_bx0 : BUF_X1 Port Map (A => input(0), Z => y2_bx0);
    u_y2_bx1 : BUF_X1 Port Map (A => input(1), Z => y2_bx1);
    u_y2_bx2 : BUF_X1 Port Map (A => input(2), Z => y2_bx2);
    u_y2_bx3 : BUF_X1 Port Map (A => input(3), Z => y2_bx3);
    u_y2_bx4 : BUF_X1 Port Map (A => input(4), Z => y2_bx4);
    u_y2_bx5 : BUF_X1 Port Map (A => input(5), Z => y2_bx5);
    u_y2_ix0 : INV_X1 Port Map (A => input(0), ZN => y2_ix0);
    u_y2_ix1 : INV_X1 Port Map (A => input(1), ZN => y2_ix1);
    u_y2_ix2 : INV_X1 Port Map (A => input(2), ZN => y2_ix2);
    u_y2_ix3 : INV_X1 Port Map (A => input(3), ZN => y2_ix3);
    u_y2_ix4 : INV_X1 Port Map (A => input(4), ZN => y2_ix4);
    u_y2_ix5 : INV_X1 Port Map (A => input(5), ZN => y2_ix5);
    u_y3_bx1 : BUF_X1 Port Map (A => input(1), Z => y3_bx1);
    u_y3_bx3 : BUF_X1 Port Map (A => input(3), Z => y3_bx3);
    u_y3_bx4 : BUF_X1 Port Map (A => input(4), Z => y3_bx4);
    u_y3_bx5 : BUF_X1 Port Map (A => input(5), Z => y3_bx5);
    u_y4_bx0 : BUF_X1 Port Map (A => input(0), Z => y4_bx0);
    u_y4_bx1 : BUF_X1 Port Map (A => input(1), Z => y4_bx1);
    u_y4_bx2 : BUF_X1 Port Map (A => input(2), Z => y4_bx2);
    u_y4_bx3 : BUF_X1 Port Map (A => input(3), Z => y4_bx3);
    u_y5_bx3 : BUF_X1 Port Map (A => input(3), Z => y5_bx3);
    u_y5_bx5 : BUF_X1 Port Map (A => input(5), Z => y5_bx5);
    u_y5_f_g3_p1012_right_local_bx1 : BUF_X1 Port Map (A => input(1), Z => y5_f_g3_p1012_right_local_bx1);
    u_y0_f_g0_c0_nprod : NAND4_X1 Port Map (A1 => y0_ix1, A2 => y0_ix2, A3 => y0_bx5, A4 => y0_ix3, ZN => y0_f_g0_c0_nprod);
    u_y0_f_g0_c1_nprod : NAND4_X1 Port Map (A1 => y0_bx1, A2 => y0_bx2, A3 => y0_ix4, A4 => y0_ix5, ZN => y0_f_g0_c1_nprod);
    u_y0_f_g1_c0_nprod : NAND4_X1 Port Map (A1 => y0_bx1, A2 => y0_bx2, A3 => y0_ix3, A4 => y0_bx4, ZN => y0_f_g1_c0_nprod);
    u_y0_f_g1_c2_nprod : NAND4_X1 Port Map (A1 => y0_ix0, A2 => y0_ix2, A3 => y0_bx3, A4 => y0_bx5, ZN => y0_f_g1_c2_nprod);
    u_y0_f_g1_p13_common : NAND2_X1 Port Map (A1 => y2_ix2, A2 => y2_ix3, ZN => y0_f_g1_p13_common);
    u_y0_f_g2_p78_common : AND3_X1 Port Map (A1 => y0_ix0, A2 => y0_ix3, A3 => y0_bx4, ZN => y0_f_g2_p78_common);
    u_y0_f_g2_p78_left : NAND2_X1 Port Map (A1 => y0_bx5, A2 => y0_bx2, ZN => y0_f_g2_p78_left);
    u_y0_f_g2_p910_common : AND3_X1 Port Map (A1 => y0_ix0, A2 => y3_bx1, A3 => y1_bx5, ZN => y0_f_g2_p910_common);
    u_y0_f_g2_p910_xnor : XNOR2_X1 Port Map (A => y0_bx3, B => y0_bx4, ZN => y0_f_g2_p910_xnor);
    u_y0_f_g3_x0_c0_nprod : NAND4_X1 Port Map (A1 => y0_bx3, A2 => y0_ix1, A3 => y0_ix2, A4 => y2_ix5, ZN => y0_f_g3_x0_c0_nprod);
    u_y0_f_g3_x0_c1_nprod : NAND4_X1 Port Map (A1 => y0_ix4, A2 => y0_ix1, A3 => y0_bx2, A4 => y0_bx5, ZN => y0_f_g3_x0_c1_nprod);
    u_y0_f_g3_x0_c2_nprod : NAND4_X1 Port Map (A1 => y0_ix4, A2 => y0_bx1, A3 => y0_ix2, A4 => y0_ix3, ZN => y0_f_g3_x0_c2_nprod);
    u_y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n0 : NAND4_X1 Port Map (A1 => y0_ix0, A2 => y0_ix1, A3 => y0_bx3, A4 => y0_ix4, ZN => y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n0);
    u_y1_f_g0_c1_nprod : NAND4_X1 Port Map (A1 => y0_bx1, A2 => y1_ix2, A3 => y1_bx4, A4 => y1_ix5, ZN => y1_f_g0_c1_nprod);
    u_y1_f_g0_c2_nprod : NAND4_X1 Port Map (A1 => y1_ix0, A2 => y1_ix1, A3 => y1_bx2, A4 => y1_bx3, ZN => y1_f_g0_c2_nprod);
    u_y1_f_g0_c3_nprod : NAND4_X1 Port Map (A1 => y1_ix0, A2 => y0_bx1, A3 => y1_bx3, A4 => y1_bx4, ZN => y1_f_g0_c3_nprod);
    u_y1_f_g1_p46_common : AND3_X1 Port Map (A1 => y1_ix1, A2 => y1_ix5, A3 => y1_bx2, ZN => y1_f_g1_p46_common);
    u_y1_f_g1_p57_common : AND3_X1 Port Map (A1 => y1_bx3, A2 => y1_bx5, A3 => y1_ix4, ZN => y1_f_g1_p57_common);
    u_y1_f_g1_p57_left_neg : NAND2_X1 Port Map (A1 => y1_ix1, A2 => y0_bx2, ZN => y1_f_g1_p57_left_neg);
    u_y1_f_g1_p57_right_neg : NAND2_X1 Port Map (A1 => y1_ix0, A2 => y1_ix2, ZN => y1_f_g1_p57_right_neg);
    u_y1_f_g2_p1011_common : AND3_X1 Port Map (A1 => y0_bx0, A2 => y1_ix1, A3 => y1_ix2, ZN => y1_f_g2_p1011_common);
    u_y1_f_g2_p1011_left_neg : NAND2_X1 Port Map (A1 => y1_ix4, A2 => y1_ix5, ZN => y1_f_g2_p1011_left_neg);
    u_y1_f_g2_p1011_right_neg : NAND2_X1 Port Map (A1 => y1_bx4, A2 => y1_bx3, ZN => y1_f_g2_p1011_right_neg);
    u_y1_f_g2_p89_common : AND3_X1 Port Map (A1 => y1_bx4, A2 => y1_ix1, A3 => y1_ix3, ZN => y1_f_g2_p89_common);
    u_y1_f_g2_p89_xnor : XNOR2_X1 Port Map (A => y1_bx5, B => y0_bx0, ZN => y1_f_g2_p89_xnor);
    u_y1_f_g3_p1213_common : AND3_X1 Port Map (A1 => y0_bx0, A2 => y0_bx1, A3 => y1_bx2, ZN => y1_f_g3_p1213_common);
    u_y1_f_g3_p1213_left : AND2_X1 Port Map (A1 => y1_ix3, A2 => y1_ix4, ZN => y1_f_g3_p1213_left);
    u_y1_f_g3_p1213_right : AND2_X1 Port Map (A1 => y1_bx3, A2 => y1_bx5, ZN => y1_f_g3_p1213_right);
    u_y2_f_g0_c0_nprod : NAND4_X1 Port Map (A1 => y2_ix1, A2 => y2_bx2, A3 => y2_bx4, A4 => y2_bx5, ZN => y2_f_g0_c0_nprod);
    u_y2_f_g0_c1_nprod : NAND4_X1 Port Map (A1 => y2_bx1, A2 => y2_bx2, A3 => y2_bx3, A4 => y2_bx5, ZN => y2_f_g0_c1_nprod);
    u_y2_f_g0_c2_nprod : NAND4_X1 Port Map (A1 => y2_ix0, A2 => y2_ix2, A3 => y2_ix3, A4 => y2_bx5, ZN => y2_f_g0_c2_nprod);
    u_y2_f_g0_c3_nprod : NAND4_X1 Port Map (A1 => y2_ix0, A2 => y2_bx1, A3 => y2_bx4, A4 => y2_bx5, ZN => y2_f_g0_c3_nprod);
    u_y2_f_g1a_common : AND2_X1 Port Map (A1 => y2_ix4, A2 => y2_ix5, ZN => y2_f_g1a_common);
    u_y2_f_g1a_left : NAND2_X1 Port Map (A1 => y2_bx0, A2 => y2_ix2, ZN => y2_f_g1a_left);
    u_y2_f_g1a_right : NAND3_X1 Port Map (A1 => y0_ix3, A2 => y2_ix0, A3 => y2_bx2, ZN => y2_f_g1a_right);
    u_y2_f_g1b_common : AND2_X1 Port Map (A1 => y2_bx1, A2 => y2_ix2, ZN => y2_f_g1b_common);
    u_y2_f_g1b_left : NAND3_X1 Port Map (A1 => y2_bx5, A2 => y2_ix3, A3 => y2_bx4, ZN => y2_f_g1b_left);
    u_y2_f_g1b_right : NAND3_X1 Port Map (A1 => y2_bx3, A2 => y2_ix5, A3 => y2_ix4, ZN => y2_f_g1b_right);
    u_y2_f_g2a_common : AND3_X1 Port Map (A1 => y2_bx5, A2 => y2_ix1, A3 => y2_bx3, ZN => y2_f_g2a_common);
    u_y2_f_g2a_xnor : XNOR2_X1 Port Map (A => y0_bx4, B => y2_bx0, ZN => y2_f_g2a_xnor);
    u_y2_f_g2b_common : AND2_X1 Port Map (A1 => y2_bx0, A2 => y2_ix4, ZN => y2_f_g2b_common);
    u_y2_f_g2b_left : NAND3_X1 Port Map (A1 => y2_bx2, A2 => y2_ix3, A3 => y1_bx5, ZN => y2_f_g2b_left);
    u_y2_f_g2b_right : NAND3_X1 Port Map (A1 => y0_ix5, A2 => y0_ix1, A3 => y3_bx3, ZN => y2_f_g2b_right);
    u_y2_f_g3a_common : AND3_X1 Port Map (A1 => y2_ix1, A2 => y2_ix2, A3 => y1_ix5, ZN => y2_f_g3a_common);
    u_y2_f_g3a_left : NAND2_X1 Port Map (A1 => y2_bx0, A2 => y2_ix3, ZN => y2_f_g3a_left);
    u_y2_f_g3a_right : NAND3_X1 Port Map (A1 => y2_bx3, A2 => y2_bx4, A3 => y2_ix0, ZN => y2_f_g3a_right);
    u_y2_f_g3b_common : AND3_X1 Port Map (A1 => y2_ix5, A2 => y2_bx0, A3 => y2_bx1, ZN => y2_f_g3b_common);
    u_y2_f_g3b_left : NAND2_X1 Port Map (A1 => y2_bx3, A2 => y2_ix2, ZN => y2_f_g3b_left);
    u_y2_f_g3b_right : NAND3_X1 Port Map (A1 => y2_ix3, A2 => y2_bx4, A3 => y2_bx2, ZN => y2_f_g3b_right);
    u_y3_f_g0_p03_common : AND2_X1 Port Map (A1 => y2_ix2, A2 => y3_bx3, ZN => y3_f_g0_p03_common);
    u_y3_f_g0_p03_left : NAND2_X1 Port Map (A1 => y2_ix1, A2 => y2_ix4, ZN => y3_f_g0_p03_left);
    u_y3_f_g0_p03_right : NAND2_X1 Port Map (A1 => y2_ix0, A2 => y0_ix5, ZN => y3_f_g0_p03_right);
    u_y3_f_g0_p12_left : NAND3_X1 Port Map (A1 => y2_ix1, A2 => y1_bx2, A3 => y3_bx5, ZN => y3_f_g0_p12_left);
    u_y3_f_g0_p12_right : NAND3_X1 Port Map (A1 => y3_bx1, A2 => y3_bx3, A3 => y0_ix5, ZN => y3_f_g0_p12_right);
    u_y3_f_g1_p47_common : AND2_X1 Port Map (A1 => y2_ix0, A2 => y3_bx4, ZN => y3_f_g1_p47_common);
    u_y3_f_g1_p47_left : NAND2_X1 Port Map (A1 => y2_ix1, A2 => y2_ix2, ZN => y3_f_g1_p47_left);
    u_y3_f_g1_p47_right : NAND3_X1 Port Map (A1 => y1_bx2, A2 => y0_ix3, A3 => y0_ix5, ZN => y3_f_g1_p47_right);
    u_y3_f_g1_p56_common : AND2_X1 Port Map (A1 => y2_bx0, A2 => y2_ix1, ZN => y3_f_g1_p56_common);
    u_y3_f_g1_p56_left : NAND2_X1 Port Map (A1 => y2_ix4, A2 => y3_bx5, ZN => y3_f_g1_p56_left);
    u_y3_f_g1_p56_right : NAND2_X1 Port Map (A1 => y1_bx2, A2 => y3_bx4, ZN => y3_f_g1_p56_right);
    u_y3_f_g2_p1011_common : AND3_X1 Port Map (A1 => y0_bx5, A2 => y0_bx0, A3 => y0_ix2, ZN => y3_f_g2_p1011_common);
    u_y3_f_g2_p1011_left : NAND2_X1 Port Map (A1 => y1_ix3, A2 => y3_bx4, ZN => y3_f_g2_p1011_left);
    u_y3_f_g2_p1011_right : NAND2_X1 Port Map (A1 => y3_bx3, A2 => y2_ix4, ZN => y3_f_g2_p1011_right);
    u_y3_f_g2_p89_common : AND2_X1 Port Map (A1 => y2_ix0, A2 => y1_bx2, ZN => y3_f_g2_p89_common);
    u_y3_f_g2_p89_left : NAND3_X1 Port Map (A1 => y0_ix3, A2 => y2_ix1, A3 => y0_ix5, ZN => y3_f_g2_p89_left);
    u_y3_f_g2_p89_right : NAND3_X1 Port Map (A1 => y2_ix4, A2 => y3_bx1, A3 => y3_bx3, ZN => y3_f_g2_p89_right);
    u_y3_f_g3_p1213_common : AND3_X1 Port Map (A1 => y2_bx0, A2 => y0_ix3, A3 => y2_ix4, ZN => y3_f_g3_p1213_common);
    u_y3_f_g3_p1213_right : AND3_X1 Port Map (A1 => y3_bx1, A2 => y2_ix2, A3 => y0_ix5, ZN => y3_f_g3_p1213_right);
    u_y4_c1_nprod : NAND4_X1 Port Map (A1 => y4_bx1, A2 => y4_bx2, A3 => y4_bx3, A4 => y1_bx4, ZN => y4_c1_nprod);
    u_y4_c2_nprod : NAND4_X1 Port Map (A1 => y4_bx3, A2 => y1_ix0, A3 => y4_bx2, A4 => y1_bx4, ZN => y4_c2_nprod);
    u_y4_c3_nprod : NAND4_X1 Port Map (A1 => y4_bx0, A2 => y1_ix1, A3 => y1_ix4, A4 => y1_ix3, ZN => y4_c3_nprod);
    u_y4_c4_nprod : NAND4_X1 Port Map (A1 => y4_bx3, A2 => y1_ix1, A3 => y4_bx0, A4 => y2_ix5, ZN => y4_c4_nprod);
    u_y4_c5_nprod : NAND4_X1 Port Map (A1 => y4_bx1, A2 => y4_bx0, A3 => y3_bx5, A4 => y1_ix3, ZN => y4_c5_nprod);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_common : AND3_X1 Port Map (A1 => y1_ix3, A2 => y1_ix1, A3 => y1_ix0, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_common);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_left : AND2_X1 Port Map (A1 => y1_ix2, A2 => y1_bx4, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_left);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_right : AND2_X1 Port Map (A1 => y4_bx2, A2 => y3_bx5, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_right);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg2_common : AND3_X1 Port Map (A1 => y1_ix0, A2 => y4_bx1, A3 => y1_ix2, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg2_common);
    u_r47_y4_and4_nand : NAND4_X1 Port Map (A1 => y1_ix0, A2 => y4_bx2, A3 => y2_ix5, A4 => y1_ix3, ZN => r47_y4_and4_negative);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_left : INV_X1 Port Map (A => r47_y4_and4_negative, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_left);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_right : AND4_X1 Port Map (A1 => y4_bx0, A2 => y1_ix2, A3 => y4_bx3, A4 => y1_ix4, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_right);
    u_y5_f_g0_c1_nprod : NAND4_X1 Port Map (A1 => y1_ix3, A2 => y4_bx2, A3 => y4_bx1, A4 => y1_ix5, ZN => y5_f_g0_c1_nprod);
    u_y5_f_g0_c2_nprod : NAND4_X1 Port Map (A1 => y0_ix0, A2 => y5_bx3, A3 => y3_bx4, A4 => y1_ix5, ZN => y5_f_g0_c2_nprod);
    u_y5_f_g0_c3_nprod : NAND4_X1 Port Map (A1 => y0_ix0, A2 => y5_f_g3_p1012_right_local_bx1, A3 => y1_ix4, A4 => y1_ix5, ZN => y5_f_g0_c3_nprod);
    u_y5_f_g1_c0_nprod : NAND4_X1 Port Map (A1 => y0_ix0, A2 => y4_bx1, A3 => y4_bx2, A4 => y5_bx3, ZN => y5_f_g1_c0_nprod);
    u_y5_f_g1_c1_nprod : NAND4_X1 Port Map (A1 => y4_bx0, A2 => y5_bx3, A3 => y1_ix4, A4 => y5_bx5, ZN => y5_f_g1_c1_nprod);
    u_y5_f_g1_c2_nprod : NAND4_X1 Port Map (A1 => y4_bx0, A2 => y4_bx1, A3 => y4_bx2, A4 => y1_ix3, ZN => y5_f_g1_c2_nprod);
    u_y5_f_g2_p78_xnor : XNOR2_X1 Port Map (A => y4_bx2, B => y5_bx5, ZN => y5_f_g2_p78_xnor);
    u_y5_f_g3_p1012_common : AND2_X1 Port Map (A1 => y4_bx0, A2 => y0_ix2, ZN => y5_f_g3_p1012_common);
    u_y5_f_g3_p1012_left : NAND3_X1 Port Map (A1 => y3_bx4, A2 => y0_ix5, A3 => y0_ix3, ZN => y5_f_g3_p1012_left);
    u_y5_f_g3_p1012_right : NAND3_X1 Port Map (A1 => y5_f_g3_p1012_right_local_bx1, A2 => y5_bx3, A3 => y5_bx5, ZN => y5_f_g3_p1012_right);
    u_y5_f_g3_p911_common : AND3_X1 Port Map (A1 => y0_ix1, A2 => y0_ix2, A3 => y1_ix4, ZN => y5_f_g3_p911_common);
    u_y5_f_g3_p911_left : NAND2_X1 Port Map (A1 => y0_ix0, A2 => y5_bx5, ZN => y5_f_g3_p911_left);
    u_y5_f_g3_p911_right : NAND2_X1 Port Map (A1 => y4_bx0, A2 => y2_ix5, ZN => y5_f_g3_p911_right);
    u_y0_f_g1_p13_neg : NAND4_X1 Port Map (A1 => y0_ix4, A2 => y0_ix0, A3 => y0_f_g1_p13_common, A4 => y1_ix5, ZN => y0_f_g1_p13_neg);
    u_y0_f_g2_p78_lor : NAND2_X1 Port Map (A1 => y0_f_g2_p78_left, A2 => y3_f_g1_p47_left, ZN => y0_f_g2_p78_lor);
    u_y0_f_g3_x0_res_or : NAND3_X1 Port Map (A1 => y0_f_g3_x0_c0_nprod, A2 => y0_f_g3_x0_c1_nprod, A3 => y0_f_g3_x0_c2_nprod, ZN => y0_f_g3_x0_res_or);
    u_y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n1 : AND3_X1 Port Map (A1 => y0_f_g0_c0_nprod, A2 => y0_f_g0_c1_nprod, A3 => y0_f_g1_c0_nprod, ZN => y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n1);
    u_r47_y1_and4_nand : NAND4_X1 Port Map (A1 => y0_f_g0_c0_nprod, A2 => y1_f_g0_c1_nprod, A3 => y1_f_g0_c2_nprod, A4 => y1_f_g0_c3_nprod, ZN => r47_y1_and4_negative);
    u_y1_f_g0_neg : INV_X1 Port Map (A => r47_y1_and4_negative, ZN => y1_f_g0_neg);
    u_y1_f_g1_p57_lor : NAND2_X1 Port Map (A1 => y1_f_g1_p57_left_neg, A2 => y1_f_g1_p57_right_neg, ZN => y1_f_g1_p57_lor);
    u_y1_f_g2_p1011_lor : NAND2_X1 Port Map (A1 => y1_f_g2_p1011_left_neg, A2 => y1_f_g2_p1011_right_neg, ZN => y1_f_g2_p1011_lor);
    u_y1_f_g3_p1213_neg : OAI21_X1 Port Map (B1 => y1_f_g3_p1213_left, B2 => y1_f_g3_p1213_right, A => y1_f_g3_p1213_common, ZN => y1_f_g3_p1213_neg);
    u_y2_f_g0_neg : AND4_X1 Port Map (A1 => y2_f_g0_c0_nprod, A2 => y2_f_g0_c1_nprod, A3 => y2_f_g0_c2_nprod, A4 => y2_f_g0_c3_nprod, ZN => y2_f_g0_neg);
    u_y2_f_g1a_lor : NAND2_X1 Port Map (A1 => y2_f_g1a_left, A2 => y2_f_g1a_right, ZN => y2_f_g1a_lor);
    u_y2_f_g1b_lor : NAND2_X1 Port Map (A1 => y2_f_g1b_left, A2 => y2_f_g1b_right, ZN => y2_f_g1b_lor);
    u_y2_f_g2b_lor : NAND2_X1 Port Map (A1 => y2_f_g2b_left, A2 => y2_f_g2b_right, ZN => y2_f_g2b_lor);
    u_y2_f_g3a_lor : NAND2_X1 Port Map (A1 => y2_f_g3a_left, A2 => y2_f_g3a_right, ZN => y2_f_g3a_lor);
    u_y2_f_g3b_lor : NAND2_X1 Port Map (A1 => y2_f_g3b_left, A2 => y2_f_g3b_right, ZN => y2_f_g3b_lor);
    u_y3_f_g0_p03_lor : NAND2_X1 Port Map (A1 => y3_f_g0_p03_left, A2 => y3_f_g0_p03_right, ZN => y3_f_g0_p03_lor);
    u_y3_f_g0_p12_lor : NAND2_X1 Port Map (A1 => y3_f_g0_p12_left, A2 => y3_f_g0_p12_right, ZN => y3_f_g0_p12_lor);
    u_y3_f_g1_p47_lor : NAND2_X1 Port Map (A1 => y3_f_g1_p47_left, A2 => y3_f_g1_p47_right, ZN => y3_f_g1_p47_lor);
    u_y3_f_g1_p56_lor : NAND2_X1 Port Map (A1 => y3_f_g1_p56_left, A2 => y3_f_g1_p56_right, ZN => y3_f_g1_p56_lor);
    u_y3_f_g2_p1011_lor : NAND2_X1 Port Map (A1 => y3_f_g2_p1011_left, A2 => y3_f_g2_p1011_right, ZN => y3_f_g2_p1011_lor);
    u_y3_f_g2_p89_lor : NAND2_X1 Port Map (A1 => y3_f_g2_p89_left, A2 => y3_f_g2_p89_right, ZN => y3_f_g2_p89_lor);
    u_y3_f_g3_p1213_neg : OAI21_X1 Port Map (B1 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_right, B2 => y3_f_g3_p1213_right, A => y3_f_g3_p1213_common, ZN => y3_f_g3_p1213_neg);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_left_pos : NAND3_X1 Port Map (A1 => y0_f_g3_x0_c0_nprod, A2 => y4_c4_nprod, A3 => y4_c3_nprod, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_left_pos);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_right_pos : NAND3_X1 Port Map (A1 => y4_c1_nprod, A2 => y4_c2_nprod, A3 => y4_c5_nprod, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_right_pos);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_nor : OAI21_X1 Port Map (B1 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_left, B2 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_right, A => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_common, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_nor);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg2_nor : OAI21_X1 Port Map (B1 => y1_f_g3_p1213_left, B2 => y1_f_g3_p1213_right, A => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg2_common, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg2_nor);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_nor : OAI21_X1 Port Map (B1 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_left, B2 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_right, A => y4_bx1, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_nor);
    u_y5_f_g0_neg : AND4_X1 Port Map (A1 => y3_f_g2_p89_right, A2 => y5_f_g0_c1_nprod, A3 => y5_f_g0_c2_nprod, A4 => y5_f_g0_c3_nprod, ZN => y5_f_g0_neg);
    u_y5_f_g1_neg : AND3_X1 Port Map (A1 => y5_f_g1_c0_nprod, A2 => y5_f_g1_c1_nprod, A3 => y5_f_g1_c2_nprod, ZN => y5_f_g1_neg);
    u_y5_f_g2_p78_neg : NAND2_X1 Port Map (A1 => y1_f_g2_p89_common, A2 => y5_f_g2_p78_xnor, ZN => y5_f_g2_p78_neg);
    u_y5_f_g3_p1012_lor : NAND2_X1 Port Map (A1 => y5_f_g3_p1012_left, A2 => y5_f_g3_p1012_right, ZN => y5_f_g3_p1012_lor);
    u_y0_f_g2_neg : AOI22_X1 Port Map (A1 => y0_f_g2_p78_common, A2 => y0_f_g2_p78_lor, B1 => y0_f_g2_p910_xnor, B2 => y0_f_g2_p910_common, ZN => y0_f_g2_neg);
    u_y0_f_g3_neg : NAND2_X1 Port Map (A1 => y0_bx0, A2 => y0_f_g3_x0_res_or, ZN => y0_f_g3_neg);
    u_y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n2 : AND3_X1 Port Map (A1 => y0_f_g1_c2_nprod, A2 => y0_f_g1_p13_neg, A3 => y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n0, ZN => y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n2);
    u_y2_f_g1_neg : AOI22_X1 Port Map (A1 => y2_f_g1a_common, A2 => y2_f_g1a_lor, B1 => y2_f_g1b_common, B2 => y2_f_g1b_lor, ZN => y2_f_g1_neg);
    u_y2_f_g2_neg : OAI22_X1 Port Map (A1 => y2_f_g2a_common, A2 => y2_f_g2b_common, B1 => y2_f_g2a_xnor, B2 => y2_f_g2b_lor, ZN => y2_f_g2_neg);
    u_y2_f_g3_neg : AOI22_X1 Port Map (A1 => y2_f_g3a_common, A2 => y2_f_g3a_lor, B1 => y2_f_g3b_common, B2 => y2_f_g3b_lor, ZN => y2_f_g3_neg);
    u_y3_f_g0_neg : AOI22_X1 Port Map (A1 => y3_f_g0_p03_common, A2 => y3_f_g0_p03_lor, B1 => y3_bx4, B2 => y3_f_g0_p12_lor, ZN => y3_f_g0_neg);
    u_y3_f_g1_neg : AOI22_X1 Port Map (A1 => y3_f_g1_p47_common, A2 => y3_f_g1_p47_lor, B1 => y3_f_g1_p56_common, B2 => y3_f_g1_p56_lor, ZN => y3_f_g1_neg);
    u_y3_f_g2_neg : AOI22_X1 Port Map (A1 => y3_f_g2_p89_common, A2 => y3_f_g2_p89_lor, B1 => y3_f_g2_p1011_common, B2 => y3_f_g2_p1011_lor, ZN => y3_f_g2_neg);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_nor : NOR2_X1 Port Map (A1 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_left_pos, A2 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_right_pos, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_nor);
    u_r40_y5k2_d5a95ec45789ce72_n0 : OAI21_X1 Port Map (B1 => y3_f_g0_p03_left, B2 => y5_f_g3_p911_right, A => y5_f_g3_p911_left, ZN => r40_y5k2_d5a95ec45789ce72_n0);
    u_y5_f_g3_neg : OAI22_X1 Port Map (A1 => y5_f_g3_p1012_common, A2 => y5_f_g3_p911_common, B1 => y5_f_g3_p1012_lor, B2 => r40_y5k2_d5a95ec45789ce72_n0, ZN => y5_f_g3_neg);
    u_y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1 : NAND4_X1 Port Map (A1 => y0_f_g2_neg, A2 => y0_f_g3_neg, A3 => y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n2, A4 => y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1_n1, ZN => y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1);
    u_r42_y1k3_5b94b51f9e719569_n0 : OAI22_X1 Port Map (A1 => y1_f_g2_p89_common, A2 => y1_f_g1_p46_common, B1 => y0_f_g2_p910_xnor, B2 => y1_f_g2_p89_xnor, ZN => r42_y1k3_5b94b51f9e719569_n0);
    u_r42_y1k3_5b94b51f9e719569_n1 : OAI22_X1 Port Map (A1 => y1_f_g1_p57_lor, A2 => y1_f_g2_p1011_lor, B1 => y1_f_g2_p1011_common, B2 => y1_f_g1_p57_common, ZN => r42_y1k3_5b94b51f9e719569_n1);
    u_y1_factored_pairs : NAND4_X1 Port Map (A1 => r42_y1k3_5b94b51f9e719569_n0, A2 => y1_f_g0_neg, A3 => y1_f_g3_p1213_neg, A4 => r42_y1k3_5b94b51f9e719569_n1, ZN => y1_factored_pairs);
    u_y2_st_g1aix3_g3b501_out_g2_g130_legal : NAND4_X1 Port Map (A1 => y2_f_g0_neg, A2 => y2_f_g1_neg, A3 => y2_f_g3_neg, A4 => y2_f_g2_neg, ZN => y2_st_g1aix3_g3b501_out_g2_g130_legal);
    u_y3_factored_pairs : NAND4_X1 Port Map (A1 => y3_f_g0_neg, A2 => y3_f_g2_neg, A3 => y3_f_g3_p1213_neg, A4 => y3_f_g1_neg, ZN => y3_factored_pairs);
    u_y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1 : NAND4_X1 Port Map (A1 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg0_nor, A2 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg1_nor, A3 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg2_nor, A4 => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1_pg3_nor, ZN => y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1);
    u_y5_st_p1012_out_g3_a1 : NAND4_X1 Port Map (A1 => y5_f_g3_neg, A2 => y5_f_g0_neg, A3 => y5_f_g2_p78_neg, A4 => y5_f_g1_neg, ZN => y5_st_p1012_out_g3_a1);

    output(0) <= y0_st_g1pair_tail_g3x0_phys_p13c405_g3ix4a1;
    output(1) <= y1_factored_pairs;
    output(2) <= y2_st_g1aix3_g3b501_out_g2_g130_legal;
    output(3) <= y3_factored_pairs;
    output(4) <= y4_st_part_6222_tailpack_c9best_pg0dm_pg123fact_c0_bx3_a1;
    output(5) <= y5_st_p1012_out_g3_a1;

end Structural;
