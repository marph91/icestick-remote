library ieee;
  use ieee.std_logic_1164.all;

  use std.env.finish;

entity tb_remote is
  generic (
    C_DUTY_CYCLE   : integer range 1 to 2 := 2;
    C_CODEC        : string := "kaseikyo";
    C_WITH_SAMPLER : integer range 0 to 1 := 1
  );
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
  signal sl_ir_en : std_logic;
  signal sl_encoder_ready : std_logic;
  signal slv_zero : std_logic_vector(3 downto 0);

  signal slv_input_word : std_logic_vector(C_BITS-1 downto 0) := (others => '0');

  signal int_uart_out_count, int_ir_count : integer := 0;
begin
  i_remote : entity work.remote
  generic map (
    C_CYCLES_PER_BIT => C_CYCLES_PER_BIT,
    C_DUTY_CYCLE     => C_DUTY_CYCLE,
    C_CODEC          => C_CODEC,
    C_WITH_SAMPLER   => C_WITH_SAMPLER
  )
  port map (
    isl_clk           => sl_clk,
    isl_uart          => sl_uart_in,
    isl_ir            => sl_ir,
    osl_ir            => sl_ir,
    osl_ir_en         => sl_ir_en,
    osl_uart          => sl_uart_out,
    osl_encoder_ready => sl_encoder_ready,
    oslv_zero         => slv_zero
  );

  proc_clk : process
  begin
    sl_clk <= '1';
    wait for C_CLK_PERIOD / 2;
    sl_clk <= '0';
    wait for C_CLK_PERIOD / 2;
  end process;

  proc_count : process (sl_clk)
  begin
    if rising_edge(sl_clk) then
      if sl_uart_out = '1' then
        int_uart_out_count <= int_uart_out_count + 1;
      else
        int_uart_out_count <= 0;
      end if;

      if sl_ir = '0' then
        int_ir_count <= int_ir_count + 1;
      else
        int_ir_count <= 0;
      end if;
    end if;
  end process;
  
  proc_stim : process
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

    wait until int_uart_out_count > 3 ms / C_CLK_PERIOD and int_ir_count > 3 ms / C_CLK_PERIOD;
    assert sl_encoder_ready = '1';
    finish;
  end process;

  proc_check_constant_signals : process (sl_clk)
  begin
    if rising_edge(sl_clk) then
      assert sl_ir_en = '0';
      assert slv_zero = "000";
    end if;
  end process;
end behavioral;