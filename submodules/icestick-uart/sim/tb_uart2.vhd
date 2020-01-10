library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity tb_uart2 is
end tb_uart2;

architecture behavioral of tb_uart2 is
  constant C_QUARTZ_FREQ : integer := 12000000; -- Hz
  constant C_BAUDRATE : integer := 115200; -- words / s

  constant C_CLK_PERIOD : time := (10**9 / C_QUARTZ_FREQ) * 1 ns;

  constant C_BITS : integer := 8;
  constant C_CYCLES_PER_BIT : integer := C_QUARTZ_FREQ / C_BAUDRATE;

  signal sl_clk : std_logic := '0';
  signal sl_data_in_uart_n : std_logic := '0';
  signal sl_data_out_uart : std_logic := '0';

  signal slv_data_out_rx2 : std_logic_vector(C_BITS-1 downto 0) := (others => '0');
  signal sl_valid_out_rx2 : std_logic := '0';

  signal slv_input_word : std_logic_vector(C_BITS-1 downto 0) := (others => '0');

begin
  dut_uart_top: entity work.uart_top
  generic map (
    C_BITS => C_BITS
  )
  port map (
    isl_clk => sl_clk,
    isl_data_n => sl_data_in_uart_n,
    osl_data_n => sl_data_out_uart
  );

  dut_rx2: entity work.uart_rx
  generic map (
    C_BITS => C_BITS,
    C_CYCLES_PER_BIT => C_CYCLES_PER_BIT
  )
  port map (
    isl_clk => sl_clk,
    isl_data_n => sl_data_out_uart,
    oslv_data => slv_data_out_rx2,
    osl_valid => sl_valid_out_rx2
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
      sl_data_in_uart_n <= '1';
      slv_input_word <= std_logic_vector(to_unsigned(i, C_BITS));
      wait for C_CLK_PERIOD;

      sl_data_in_uart_n <= '0'; -- start bit
      wait for C_CLK_PERIOD * C_CYCLES_PER_BIT;

      for j in slv_input_word'REVERSE_RANGE loop
        sl_data_in_uart_n <= not slv_input_word(j); -- LSB first
        wait for C_CLK_PERIOD * C_CYCLES_PER_BIT;
      end loop;

      sl_data_in_uart_n <= '1'; -- stop bit
      wait until sl_valid_out_rx2 = '1';
      assert slv_input_word = slv_data_out_rx2 report to_string(slv_input_word) & " " & to_string(slv_data_out_rx2);
    end loop;
    wait;
  end process;
end behavioral;