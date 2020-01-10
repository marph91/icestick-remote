library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity bram is
  generic (
    C_ADDR_WIDTH : integer := 9;
    C_DATA_WIDTH : integer := 8
  );
  port (
    isl_clk   : in std_logic;
    isl_we    : in std_logic;
    islv_addr : in std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    islv_data : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
    oslv_data : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
  );
end bram;

architecture rtl of bram is
  type mem_type is array (0 to 2**C_ADDR_WIDTH-1) of std_logic_vector(C_DATA_WIDTH-1 downto 0);
  signal a_mem : mem_type;

begin
  process(isl_clk)
  begin
    if rising_edge(isl_clk) then
      if isl_we = '1' then
        a_mem(to_integer(unsigned(islv_addr))) <= islv_data;
      else
        oslv_data <= a_mem(to_integer(unsigned(islv_addr)));
      end if;
    end if;
  end process;
end rtl;