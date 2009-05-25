library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adsr is
  port(
    reset    : in  std_logic;
    clk      : in  std_logic;
    attack   : in  std_logic_vector(7 downto 0);
    decay    : in  std_logic_vector(7 downto 0);
    sustain  : in  std_logic_vector(7 downto 0);
    release  : in  std_logic_vector(7 downto 0);
    velocity : in  std_logic_vector(7 downto 0);
    input    : in  std_logic_vector(7 downto 0);
    output   : out std_logic_vector(7 downto 0)
    );
end adsr;

architecture rtl of adsr is
  signal result        : std_logic_vector(15 downto 0);
  signal level         : std_logic_vector(7 downto 0);
  type   state_type is (s_attack, s_decay, s_sustain, s_release);
  signal state         : state_type;
  signal step_divider  : std_logic_vector(7 downto 0);
  signal step_pulse    : std_logic;
  signal phase_counter : std_logic_vector(7 downto 0);
begin

  output <= result(15 downto 8);

  -- Generate the output by multiplying the input with the current level
  -- generated by the ADSR envelope generate.
  my_process_input : process(clk)
  begin
    if rising_edge(clk) then
      result <= input * level;
    end if;
  end process;

  -- Generate the time constant pulse for the adsr, step_pulse.  The ADSR
  -- parameter values are based on this pulse.
  my_step_counter : process(clk, reset)
  begin
    if reset = '1' then
      step_divider <= (others => '0');
      step_pulse   <= '0';
    elsif rising_edge(clk) then
      step_divider <= step_divider + 1;
      step_pulse   <= '0';
      if step_divider = 0 then
        step_pulse <= '1';
      end if;
    end if;
  end process;

  -- Generate the ADSR envelope.
  my_adsr : process(clk, reset)
  begin
    if reset = '1' then
      state         <= s_release;
      level         <= (others => '0');
      phase_counter <= '0';
    elsif rising_edge(clk) then

      if step_pulse = '1' then
        case state is

          when s_attack =>
            if velocity = 0 then
              state <= s_release;
            else
              phase_counter <= phase_counter + 1;
              if phase_counter = attack then
                level         <= level + 1;
                phase_counter <= (others => '0');
                if level = velocity then
                  state <= s_decay;
                end if;
              end if;
            end if;

          when s_decay =>
            if velocity = 0 then
              state <= s_release;
            else
              phase_counter <= phase_counter + 1;
              if phase_counter = decay then
                level         <= level - 1;
                phase_counter <= (others => '0');
                if level = sustain then
                  state <= s_sustain;
                end if;
              end if;
            end if;

          when s_sustain =>
            if velocity = 0 then
              state <= s_release;
            end if;

          when s_release =>
            if velocity /= 0 then
              state <= s_attack;
              phase_counter <= (others => '0');
            elsif level /= 0 then
              phase_counter <= phase_counter + 1;
              if phase_counter = release then
                level <= level - 1;
                phase_counter <= (others => '0');
              end if;
            end if;

        end case;
      end if;
    end if;
  end process;
end;
