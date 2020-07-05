library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity tb_uart is
end tb_uart;

architecture behavioral of tb_uart is
  constant C_QUARTZ_FREQ : integer := 12000000; -- Hz
  constant C_BAUDRATE : integer := 115200; -- words / s

  constant C_CLK_PERIOD : time := (10**9 / C_QUARTZ_FREQ) * 1 ns;

  constant C_BITS : integer := 8;
  constant C_CYCLES_PER_BIT : integer := C_QUARTZ_FREQ / C_BAUDRATE;

  signal sl_clk : std_logic := '0';
  signal sl_valid_in_tx : std_logic := '0';
  signal slv_data_in_tx : std_logic_vector(C_BITS-1 downto 0);
  signal sl_data_out_tx : std_logic := '0';
  signal sl_valid_out_rx : std_logic := '0';
  signal slv_data_out_rx : std_logic_vector(C_BITS-1 downto 0);

begin
  dut_tx: entity work.uart_tx
  generic map (
    C_BITS => C_BITS,
    C_CYCLES_PER_BIT => C_CYCLES_PER_BIT
  )
  port map (
    isl_clk => sl_clk,
    isl_valid => sl_valid_in_tx,
    islv_data => slv_data_in_tx,
    osl_data_n => sl_data_out_tx
  );

  dut_rx: entity work.uart_rx
  generic map (
    C_BITS => C_BITS,
    C_CYCLES_PER_BIT => C_CYCLES_PER_BIT
  )
  port map (
    isl_clk => sl_clk,
    isl_data_n => sl_data_out_tx,
    oslv_data => slv_data_out_rx,
    osl_valid => sl_valid_out_rx
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

    for i in 0 to 2**C_BITS-1 loop
      sl_valid_in_tx <= '1';
      slv_data_in_tx <= std_logic_vector(to_unsigned(i, C_BITS));
      wait for C_CLK_PERIOD;
      sl_valid_in_tx <= '0';

      wait until sl_valid_out_rx = '1';
      wait for C_CLK_PERIOD * C_CYCLES_PER_BIT * 3 / 2;
      assert slv_data_in_tx = slv_data_out_rx report to_string(slv_data_in_tx) & " " & to_string(slv_data_out_rx);
    end loop;
    wait;
  end process;
end behavioral;