package codec_pkg is
  type t_codec is (NEC, KAS);
  type t_constants is record
    DATA_BYTES_IN          : integer;
    DATA_BYTES_OUT         : integer;
    CARRIER_PERIOD         : integer;
    START_BIT_PULSE        : integer;
    START_BIT_PAUSE        : integer;
    START_BIT_PAUSE_REPEAT : integer;
    BIT_PULSE              : integer;
    BIT_0_PAUSE            : integer;
    BIT_1_PAUSE            : integer;
    NEXT_WORD_PAUSE        : integer;
  end record t_constants;
  constant C_CONSTANTS_NEC : t_constants;
  constant C_CONSTANTS_KASEIKYO : t_constants;

  function get_constants(sl_codec : t_codec) return t_constants;
end codec_pkg;

package body codec_pkg is
  constant C_CLK_PERIOD : time := 83.333 ns; -- 83.333 ns = 12 MHz

  constant C_CONSTANTS_NEC : t_constants := (
    DATA_BYTES_IN          => 2,
    DATA_BYTES_OUT         => 4,
    CARRIER_PERIOD         => 26.316 us / C_CLK_PERIOD, -- 38 kHz
    START_BIT_PULSE        => 9 ms / C_CLK_PERIOD,
    START_BIT_PAUSE        => 4.5 ms / C_CLK_PERIOD,
    START_BIT_PAUSE_REPEAT => 2.25 ms / C_CLK_PERIOD,
    BIT_PULSE              => 0.5625 ms / C_CLK_PERIOD,
    BIT_0_PAUSE            => 0.5625 ms / C_CLK_PERIOD,
    BIT_1_PAUSE            => 1.6875 ms / C_CLK_PERIOD,
    NEXT_WORD_PAUSE        => 108 ms / C_CLK_PERIOD
  );

  constant C_CONSTANTS_KASEIKYO : t_constants := (
    DATA_BYTES_IN          => 6,
    DATA_BYTES_OUT         => 6,
    CARRIER_PERIOD         => 27.777 us / C_CLK_PERIOD, -- 36 kHz
    START_BIT_PULSE        => 3.4 ms / C_CLK_PERIOD,
    START_BIT_PAUSE        => 1.7 ms / C_CLK_PERIOD,
    START_BIT_PAUSE_REPEAT => 0, -- not needed
    BIT_PULSE              => 0.5 ms / C_CLK_PERIOD,
    BIT_0_PAUSE            => 0.5 ms / C_CLK_PERIOD,
    BIT_1_PAUSE            => 1.2 ms / C_CLK_PERIOD,
    NEXT_WORD_PAUSE        => 74.4 ms / C_CLK_PERIOD
  );

  function get_constants(sl_codec : t_codec) return t_constants is
    variable v_const : t_constants;
  begin
    if sl_codec = NEC then
      v_const := C_CONSTANTS_NEC;
    elsif sl_codec = KAS then
      v_const := C_CONSTANTS_KASEIKYO;
    end if;
    return v_const;
  end function get_constants;
end codec_pkg;