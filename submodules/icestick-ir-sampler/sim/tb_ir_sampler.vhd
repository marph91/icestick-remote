library ieee;
  use ieee.std_logic_1164.all;

entity tb_ir_sampler is
end tb_ir_sampler;

architecture behavioral of tb_ir_sampler is
  constant C_CLK_PERIOD : time := 83.333 ns;
  constant C_BRAM_CNT : integer range 1 to 2 := 2;

  signal sl_clk : std_logic := '0';
  signal sl_data_in : std_logic := '0';
  signal sl_data_out : std_logic;
begin
  dut: entity work.ir_sampler
  generic map (
    C_BITS => 8,
    C_CYCLES_PER_BIT => 104,
    C_BRAM_CNT => C_BRAM_CNT
  )
  port map (
    isl_clk   => sl_clk,
    isl_data  => sl_data_in,
    osl_data  => sl_data_out
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

    for i in 0 to 2**(7+C_BRAM_CNT)-1 loop
      sl_data_in <= '1';
      wait for 13.888 us;
      sl_data_in <= '0';
      wait for 13.888 us;
    end loop;
    wait;
  end process;
end behavioral;