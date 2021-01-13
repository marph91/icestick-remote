library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ir_sampler is
  generic (
    C_BITS : integer := 8;
    C_CYCLES_PER_BIT : integer := 104;
    C_BRAM_CNT : integer range 1 to 2 := 2 -- 2, because max ir frequency is reached (115.2 kbps)
  );
  port (
    isl_clk   : in std_logic;
    isl_data  : in std_logic;
    osl_data  : out std_logic
  );
end ir_sampler;

architecture behavioral of ir_sampler is
  constant C_SAMPLE_CYCLES : integer := 210/C_BRAM_CNT; -- 9 us

  signal usig_bram_addr : unsigned(7+C_BRAM_CNT downto 0) := (others => '0');
  signal usig_sample_addr : unsigned(10+C_BRAM_CNT downto 0) := (others => '0'); -- 1 byte (2^3) bigger than usig_bram_addr -> for counting bits
  signal int_sample_cnt : integer range 0 to C_SAMPLE_CYCLES := 0;

  signal slv_sampled_byte,
         slv_bram_data_out: std_logic_vector(7 downto 0) := (others => '0');

  signal slv_bram_addr : std_logic_vector(usig_bram_addr'RANGE) := (others => '0');

  signal isl_data_d1,
         sl_bram_valid,
         sl_bram_we,
         sl_uart_ready : std_logic := '0';

  type t_state is (IDLE, SAMPLE, SEND);
  signal state : t_state;

begin
  i_uart_tx : entity work.uart_tx
  generic map (
    C_BITS => C_BITS,
    C_CYCLES_PER_BIT => C_CYCLES_PER_BIT
  )
  port map (
    isl_clk => isl_clk,
    isl_valid => sl_bram_valid,
    islv_data => slv_bram_data_out,
    osl_ready => sl_uart_ready,
    osl_data_n => osl_data -- TODO: check low active
  );

  i_bram : entity work.bram
  generic map (
    C_ADDR_WIDTH => usig_bram_addr'LENGTH,
    C_DATA_WIDTH => C_BITS
  )
  port map (
    isl_clk => isl_clk,
    isl_we => sl_bram_we,
    islv_addr => slv_bram_addr,
    islv_data => slv_sampled_byte,
    oslv_data => slv_bram_data_out
  );
  slv_bram_addr <= std_logic_vector(usig_bram_addr);

  proc_receive_data : process(isl_clk)
  begin
    if rising_edge(isl_clk) then
      isl_data_d1 <= isl_data; -- for falling edge detection

      case state is
        when IDLE =>
          sl_bram_valid <= '0';
          if isl_data = '1' and isl_data_d1 = '0' then
            state <= SAMPLE;
            usig_sample_addr <= usig_sample_addr + 1;
            slv_sampled_byte(0) <= isl_data;
            sl_bram_we <= '1';
          end if;

        when SAMPLE =>
          if int_sample_cnt /= C_SAMPLE_CYCLES then
            int_sample_cnt <= int_sample_cnt + 1;
          else
            int_sample_cnt <= 0;
            usig_sample_addr <= usig_sample_addr + 1;
            if usig_sample_addr(2 downto 0) = "111" then -- modulo 8
              usig_bram_addr <= usig_bram_addr + 1;
            end if;
            if usig_sample_addr /= 2**usig_sample_addr'LENGTH-1 then
              slv_sampled_byte <= slv_sampled_byte(slv_sampled_byte'LEFT-1 downto 0) & isl_data;
            else
              state <= SEND;
              sl_bram_we <= '0';
              sl_bram_valid <= '1';
            end if;
          end if;

        when SEND =>
          if sl_uart_ready = '1' and sl_bram_valid = '0' then
            usig_bram_addr <= usig_bram_addr + 1;
            if usig_bram_addr /= 2**usig_bram_addr'LENGTH-1 then
              sl_bram_valid <= '1';
            else
              state <= IDLE;
              sl_bram_valid <= '0';
            end if;
          else
            sl_bram_valid <= '0';
          end if;

        end case;
    end if;
  end process;
end behavioral;