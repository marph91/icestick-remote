library ieee;
  use ieee.std_logic_1164.all;
library work;
  use work.codec_pkg.all;

entity ir_encoder is
  generic (
    C_DUTY_CYCLE : integer range 1 to 2 := 2;
    -- active time:inactive time = 1:C_DUTY_CYCLE
    -- max duty cycle is 1:2, because of max ir (115 kbps = 105 cycles)
    C_CODEC : t_codec := KASEIKYO
  );
  port (
    isl_clk   : in std_logic;
    isl_valid : in std_logic;
    islv_data : in std_logic_vector(7 downto 0);
    osl_ir    : out std_logic
  );
end ir_encoder;

architecture behavioral of ir_encoder is
  constant C_CONST : t_constants := get_constants(C_CODEC);

  signal int_ir_period_cnt : integer range 0 to C_CONST.CARRIER_PERIOD := 0;
  signal int_blocking_cnt : integer range 0 to C_CONST.NEXT_WORD_PAUSE := 0;
  signal int_bit_counter : integer range 0 to C_CONST.DATA_BYTES*8-1 := 0;

  signal int_byte_cnt : integer range 0 to C_CONST.DATA_BYTES := 0;
  signal slv_data : std_logic_vector(C_CONST.DATA_BYTES*8-1 downto 0) := (others => '0');

  signal sl_data_ready,
         sl_ctr_finish_d1,
         sl_ir : std_logic := '0';

  signal slv_bits_current,
         slv_bits_previous : std_logic_vector(C_CONST.DATA_BYTES*8-1 downto 0) := (others => '0');

  type t_state is (IDLE,
                   INIT_BURST, INIT_SPACE_REPEAT, INIT_SPACE_SEND, FINISH_BURST,
                   SPACE_BIT, SEND_BIT);
  signal state : t_state;

  type t_counter is record
    sl_start : std_logic;
    int_start_cnt : integer range 0 to C_CONST.START_BIT_PULSE;
    int_current_cnt : integer range 0 to C_CONST.START_BIT_PULSE;
    sl_finish : std_logic;
  end record t_counter;
  signal r_ctr : t_counter;

begin
  -- Receive and reassemble the data to send.
  proc_receive_data : process(isl_clk)
  begin
    if rising_edge(isl_clk) then
      if isl_valid = '1' then
        if int_byte_cnt < C_CONST.DATA_BYTES then
          int_byte_cnt <= int_byte_cnt+1;
        end if;
        -- first received byte will be at lowest index
        slv_data <= islv_data & slv_data(slv_data'LEFT downto slv_data'RIGHT + islv_data'LENGTH);
      end if;

      if sl_data_ready = '1' then
        sl_data_ready <= '0';
        int_byte_cnt <= 0;
      elsif int_byte_cnt = C_CONST.DATA_BYTES and int_blocking_cnt = 0 then
        slv_bits_current <= slv_data;
        sl_data_ready <= '1';
      end if;
    end if;
  end process;

  -- Encode the data to fit the the specified protocol.
  proc_encode : process(isl_clk)
  begin
    if rising_edge(isl_clk) then
      sl_ctr_finish_d1 <= r_ctr.sl_finish;
      r_ctr.sl_start <= sl_ctr_finish_d1;

      if int_blocking_cnt > 0 then
        int_blocking_cnt <= int_blocking_cnt - 1;
      end if;

      case state is
        when IDLE =>
          if sl_data_ready = '1' then
            state <= INIT_BURST;
            r_ctr.sl_start <= '1';
            r_ctr.int_start_cnt <= C_CONST.START_BIT_PULSE;

            int_blocking_cnt <= C_CONST.NEXT_WORD_PAUSE;
          end if;

        when INIT_BURST =>
          if r_ctr.sl_finish = '1' then
            slv_bits_previous <= slv_bits_current;
            if slv_bits_previous = slv_bits_current and C_CODEC = NEC then
              state <= INIT_SPACE_REPEAT;
              r_ctr.int_start_cnt <= C_CONST.START_BIT_PAUSE_REPEAT;
            else
              state <= INIT_SPACE_SEND;
              r_ctr.int_start_cnt <= C_CONST.START_BIT_PAUSE;
            end if;
          end if;

        -- send new signal
        when INIT_SPACE_SEND =>
          if r_ctr.sl_finish = '1' then
            state <= SEND_BIT;
            r_ctr.int_start_cnt <= C_CONST.BIT_PULSE;
          end if;

        when SEND_BIT =>
          if r_ctr.sl_finish = '1' then
            state <= SPACE_BIT;
            if slv_bits_current(int_bit_counter) = '0' then
              r_ctr.int_start_cnt <= C_CONST.BIT_0_PAUSE;
            else
              r_ctr.int_start_cnt <= C_CONST.BIT_1_PAUSE;
            end if;
          end if;

        when SPACE_BIT =>
          if r_ctr.sl_finish = '1' then
            r_ctr.int_start_cnt <= C_CONST.BIT_PULSE;
            if int_bit_counter /= C_CONST.DATA_BYTES*8-1 then
              int_bit_counter <= int_bit_counter+1;
              state <= SEND_BIT;
            else
              int_bit_counter <= 0;
              state <= FINISH_BURST;
            end if;
          end if;

        -- repeat signal
        when INIT_SPACE_REPEAT =>
          if r_ctr.sl_finish = '1' then
            state <= FINISH_BURST;
            r_ctr.int_start_cnt <= C_CONST.BIT_PULSE;
          end if;

        when FINISH_BURST =>
          if r_ctr.sl_finish = '1' then
            state <= IDLE;
          end if;
      end case;
    end if;
  end process;

  -- Control the infrared LED.
  -- Only light the LED in the correct states.
  -- Provide a carrier frequency as specified in the constants.
  proc_ir_active : process(isl_clk)
  begin
    if rising_edge(isl_clk) then
      if state = INIT_BURST or
         state = SEND_BIT or
         state = FINISH_BURST then
        if int_ir_period_cnt > C_CONST.CARRIER_PERIOD / (C_DUTY_CYCLE + 1) then
          int_ir_period_cnt <= int_ir_period_cnt - 1;
          sl_ir <= '0';
        elsif int_ir_period_cnt > 0 then
          int_ir_period_cnt <= int_ir_period_cnt - 1;
          sl_ir <= '1';
        else
          int_ir_period_cnt <= C_CONST.CARRIER_PERIOD;
        end if;
      else
        int_ir_period_cnt <= C_CONST.CARRIER_PERIOD;
        sl_ir <= '0';
      end if;
    end if;
  end process;

  -- Simple counter, decrementing an integer each cycle.
  -- The counter is started by setting the start signal.
  -- When the counter counted down to 1, it send a finish signal.
  proc_cnt : process(isl_clk)
  begin
    if rising_edge(isl_clk) then
      if r_ctr.sl_start = '1' then
        r_ctr.int_current_cnt <= r_ctr.int_start_cnt;
      end if;

      if r_ctr.int_current_cnt > 0 then
        r_ctr.int_current_cnt <= r_ctr.int_current_cnt-1;
      end if;
    end if;
  end process;
  r_ctr.sl_finish <= '1' when r_ctr.int_current_cnt = 1 else '0';

  osl_ir <= sl_ir;
end behavioral;