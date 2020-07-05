library ieee;
  use ieee.std_logic_1164.all;
library work;
  use work.codec_pkg.all;

entity tb_ir_encoder is
end tb_ir_encoder;

architecture behavioral of tb_ir_encoder is
  constant C_CLK_PERIOD : time := 83.333 ns;

  signal sl_clk : std_logic := '0';
  signal sl_valid_in : std_logic := '0';
  signal slv_data_in : std_logic_vector(7 downto 0) := (0 => '1', others => '0');
  signal sl_ir_out : std_logic := '0';
begin
  dut: entity work.ir_encoder
  generic map (
    C_DUTY_CYCLE => 2,
    C_CODEC => NEC
  )
  port map (
    isl_clk   => sl_clk,
    isl_valid => sl_valid_in,
    islv_data => slv_data_in,
    osl_ir    => sl_ir_out
  );

  clk_proc : process
  begin
    sl_clk <= '1';
    wait for C_CLK_PERIOD / 2;
    sl_clk <= '0';
    wait for C_CLK_PERIOD / 2;
  end process;

  stim_proc : process
  begin
    wait for C_CLK_PERIOD;
    sl_valid_in <= '1';
    wait for C_CLK_PERIOD * 6;
    sl_valid_in <= '0';

    wait for 110 ms;
    wait for C_CLK_PERIOD;
    sl_valid_in <= '1';
    wait for C_CLK_PERIOD * 6;
    sl_valid_in <= '0';
    wait;
  end process;
end behavioral;