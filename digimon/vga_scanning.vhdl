------------------------------------------------------------------------------
-- @name: VGA Display Module 800 * 600 @75Hz (50MHz)
-- @description: Fetch data from SDRAM using Qsys SDRAM IP in certain address,
--               and then cast them on the screen through VGA Display Module
--               that we write.
------------------------------------------------------------------------------
-- The standard we are using: 
-- Clock frequencies   : 50MHz
-- Horizonal timing information
--    sync pluse       : 80
--    back porch       : 160
--    active           : 800
--    front porch      : 16
--    all lines        : 1056
-- Vertical timing information
--    sync pluse       : 3
--    back porch       : 21
------------------------------------------------------------------------------
-- @name: VGA Display Module 800 * 600 @75Hz (50MHz)
-- @description: Fetch data from SDRAM using Qsys SDRAM IP in certain address,
--               and then cast them on the screen through VGA Display Module
--               that we write.
------------------------------------------------------------------------------
-- The standard we are using: 
-- Clock frequencies   : 50MHz
-- Horizonal timing information
--    sync pluse       : 80
--    back porch       : 160
--    active           : 800
--    front porch      : 16
--    all lines        : 1056
-- Vertical timing information
--    sync pluse       : 3
--    back porch       : 21
--    active           : 600
--    front porch      : 1
--    all lines        : 625
------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vga_scanning is
   port(
      Clk          : in std_logic;
      Rst          : in std_logic;
	  
	  Vga_vsync    : out std_logic;
      Vga_hsync    : out std_logic;
	  Vga_hsync_cnt_o    : out integer range 0 to 1056;
      Vga_vsync_cnt_o    :out integer range 0 to 625);
end entity;

architecture behave of vga_scanning is

   constant H_SYNC_PULSE_MAX   : integer := 80;
   constant H_ACTIVE_MIN       : integer := 240;
   constant H_ACTIVE_MAX       : integer := 1040;
   constant H_MAX              : integer := 1056;

   constant V_SYNC_PULSE_MAX   : integer := 3;
   constant V_ACTIVE_MIN       : integer := 24;
   constant V_ACTIVE_MAX       : integer := 624;
   constant V_MAX              : integer := 625;
 
   signal Vga_hsync_cnt    : integer range 0 to 1056;
   signal Vga_vsync_cnt    : integer range 0 to 625;
   signal Vga_hsync_cnt_n  : integer range 0 to 1056;
   signal Vga_vsync_cnt_n  : integer range 0 to 625;
   
   
   signal Vga_vsync_n  : std_logic;
   signal Vga_hsync_n  : std_logic;
begin

-- ʱ���·,������hsync_cnt,vsync_cnt,vga_vsync,vga_hsync,vga_rgb�Ĵ�����ֵ
process(Clk, Rst)
begin
	if rising_edge(clk) then
		if rst = '0' then
			Vga_hsync <= '0';
			Vga_vsync <= '0';
		   Vga_hsync_cnt <= 0;
		   Vga_vsync_cnt <= 0;
		else
		   Vga_hsync <= Vga_hsync_n;
		   Vga_vsync <= Vga_vsync_n;
		   Vga_hsync_cnt <= Vga_hsync_cnt_n;
		   Vga_vsync_cnt <= Vga_vsync_cnt_n;
		end if;
	end if;
end process;

Vga_hsync_cnt_o  <= Vga_hsync_cnt;
Vga_vsync_cnt_o  <= Vga_vsync_cnt;

-- ��ϵ�·,ˮƽɨ��
process(Vga_hsync_cnt)
begin
	if(Vga_hsync_cnt = H_MAX) then			--�ж�ˮƽɨ��ʱ��    80+160+800+16 = 1056
		Vga_hsync_cnt_n <= 0;	--���ˮƽɨ�����,���������ᱻ����
	else
		Vga_hsync_cnt_n <= Vga_hsync_cnt + 1;		--���ˮƽû��ɨ�����,�����������ۼ�
	end if;
end process;


-- ��ϵ�·,��ֱɨ��
process(Vga_vsync_cnt)
begin
	if((Vga_vsync_cnt = V_MAX) and (Vga_hsync_cnt = H_MAX)) then --�жϴ�ֱɨ��ʱ�� 3+21+600+1=625
		Vga_vsync_cnt_n <= 0;					--�����ֱɨ�����,���������ᱻ����
	elsif(Vga_hsync_cnt = H_MAX)	then	--�ж�ˮƽɨ��ʱ��
	   Vga_vsync_cnt_n <= Vga_vsync_cnt + 1;	--���ˮƽɨ�����,�����������ۼ�
	else
      Vga_vsync_cnt_n <= Vga_vsync_cnt;			--����,�����������ֲ���
	end if;
end process;

--��ϵ�·����HSYNC_A������0,HSYNC_B+HSYNC_C+HSYNC_D��1
process(Vga_hsync_cnt)
begin
	if(Vga_hsync_cnt < H_SYNC_PULSE_MAX)	then			--�ж�ˮƽɨ��ʱ��
		Vga_hsync_n <= '0';						--�����HSYNC_A����,��ô��0
	else
		Vga_hsync_n <= '1';						--�������HSYNC_A����,��ô��1
	end if;
end process;

--��ϵ�·����VSYNC_A������0,VSYNC_P+VSYNC_Q+VSYNC_R��1
process(Vga_vsync_cnt)
begin
	if(Vga_vsync_cnt < V_SYNC_PULSE_MAX)	then			--�ж�ˮƽɨ��ʱ��
		Vga_vsync_n <= '0';						--�����VSYNC_O����,��ô��0
	else
		Vga_vsync_n <= '1';						--�������VSYNC_O����,��ô��1
	end if;
end process;


end behave;