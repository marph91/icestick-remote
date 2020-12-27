library ieee;
  use ieee.std_logic_1164.all;
library work;
  use work.codec_pkg.all;

entity remote is
  generic (
    C_CYCLES_PER_BIT : integer := 104;
    C_DUTY_CYCLE     : integer := 2;
    C_CODEC          : string := "kaseikyo";
    C_WITH_SAMPLER   : integer range 0 to 1 := 1
  );
  port (
    isl_clk           : in std_logic;
    isl_uart          : in std_logic;
    isl_ir            : in std_logic;
    osl_ir            : out std_logic;
    osl_ir_en         : out std_logic;
    osl_uart          : out std_logic;
    osl_encoder_ready : out std_logic;
    -- Needed to prevent the red LEDs from lighting.
    -- TODO: Can this be done directly in the PCF?
    oslv_zero         : out std_logic_vector(3 downto 0)
  );
end remote;

architecture behavioral of remote is
  constant C_BITS_UART : integer := 8;

  signal slv_uart_valid_in : std_logic := '0';
  signal slv_uart_data_in : std_logic_vector(C_BITS_UART-1 downto 0) := (others => '0');

begin
  osl_ir_en <= '0'; -- enable IrDA (low active)

  i_uart_rx : entity work.uart_rx
  generic map (
    C_BITS => C_BITS_UART,
    C_CYCLES_PER_BIT => C_CYCLES_PER_BIT
  )
  port map (
    isl_clk    => isl_clk,
    isl_data_n => isl_uart,
    oslv_data  => slv_uart_data_in,
    osl_valid  => slv_uart_valid_in
  );

  i_ir_encoder : entity work.ir_encoder
  generic map (
    C_DUTY_CYCLE => C_DUTY_CYCLE,
    C_CODEC => C_CODEC
  )
  port map (
    isl_clk   => isl_clk,
    isl_valid => slv_uart_valid_in,
    islv_data => slv_uart_data_in,
    osl_ir    => osl_ir,
    osl_encoder_ready => osl_encoder_ready
  );

  -- for debugging or obtaining new codes
  gen_ir_sampler : if C_WITH_SAMPLER = 1 generate
    i_ir_sampler : entity work.ir_sampler
    generic map (
      C_BITS => C_BITS_UART,
      C_CYCLES_PER_BIT => C_CYCLES_PER_BIT
    )
    port map (
      isl_clk   => isl_clk,
      isl_data  => isl_ir,
      osl_data  => osl_uart
    );
  end generate;

  oslv_zero <= (others => '0');
end behavioral;