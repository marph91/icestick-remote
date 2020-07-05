library ieee;
  use ieee.std_logic_1164.all;

entity tb_remote is
end tb_remote;

architecture behavioral of tb_remote is
  constant C_QUARTZ_FREQ : integer := 12000000; -- Hz
  constant C_BAUDRATE : integer := 115200; -- words / s

  constant C_CLK_PERIOD : time := (10**9 / C_QUARTZ_FREQ) * 1 ns;

  constant C_BITS : integer := 8;
  constant C_CYCLES_PER_BIT : integer := C_QUARTZ_FREQ / C_BAUDRATE;

  signal sl_clk       : std_logic := '0';
  signal sl_uart_in,
         sl_uart_out : std_logic := '0';
  signal sl_ir : std_logic := '0';

  signal slv_input_word : std_logic_vector(C_BITS-1 downto 0) := (others => '0');
begin
  dut: entity work.remote
  port map (
    isl_clk   => sl_clk,
    isl_uart  => sl_uart_in,
    isl_ir    => sl_ir,
    osl_ir    => sl_ir,
    osl_uart  => sl_uart_out
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

    for i in 0 to 5 loop
      sl_uart_in <= '1';
      slv_input_word <= "10101010";
      wait for C_CLK_PERIOD;

      sl_uart_in <= '0'; -- start bit
      wait for C_CLK_PERIOD * C_CYCLES_PER_BIT;

      for j in slv_input_word'REVERSE_RANGE loop
        sl_uart_in <= slv_input_word(j); -- LSB first
        wait for C_CLK_PERIOD * C_CYCLES_PER_BIT;
      end loop;

      sl_uart_in <= '1'; -- stop bit
      wait for C_CLK_PERIOD * C_CYCLES_PER_BIT;
      sl_uart_in <= '1';
    end loop;

    wait for 40 ms;

    wait;
  end process;
end behavioral;