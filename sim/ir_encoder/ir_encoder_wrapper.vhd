-- This wrapper is only needed to speed up the cocotb simulation performance.
-- The clock is generated in VHDL and doesn't need to be passed through VPI.
-- The resulting speedup is huge (220 s -> 10 s in a test run).

library ieee;
  use ieee.std_logic_1164.all;
library work;

entity ir_encoder_wrapper is
  generic (
    C_DUTY_CYCLE : integer range 1 to 2 := 2;
    C_CODEC : string := "kaseikyo";
    C_CLK_PERIOD : time := 83.333 ns
  );
  port (
    isl_valid         : in std_logic;
    islv_data         : in std_logic_vector(7 downto 0);
    osl_ir            : out std_logic;
    osl_encoder_ready : out std_logic
  );
end ir_encoder_wrapper;

architecture behavioral of ir_encoder_wrapper is
  signal sl_clk : std_logic := '0';
begin
  i_ir_encoder: entity work.ir_encoder
  generic map (
    C_DUTY_CYCLE => C_DUTY_CYCLE,
    C_CODEC => C_CODEC
  )
  port map (
    isl_clk   => sl_clk,
    isl_valid => isl_valid,
    islv_data => islv_data,
    osl_ir    => osl_ir
  );

  clk_proc : process
  begin
    sl_clk <= '1';
    wait for C_CLK_PERIOD / 2;
    sl_clk <= '0';
    wait for C_CLK_PERIOD / 2;
  end process;
end behavioral;