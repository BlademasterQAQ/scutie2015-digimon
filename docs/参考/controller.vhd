library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;

entity controller is
   port(Clk         :in std_logic;
      Second        :in std_logic;--���ڲ��Ŷ������ӳٵ�ʱ��,1����1������
	  Low_sw_an     :in std_logic_vector (2 downto 0 );
	  
	  Vga_rgb       : out std_logic_vector (7 downto 0); -- R2, R1, R0, G2, G1, G0, B1, B0
	  Vga_vsync     : out std_logic;
      Vga_hsync     : out std_logic);
end entity;

architecture nan OF controller IS

   component vga_out is
      port (
         Clk          : in std_logic;
         Rst          : in std_logic;
	     Vga_choose   : in integer range 0 to 9;
         Joy          : in integer range 0 to 10;
         Stomach      : in integer range 0 TO 10;
	  
   	     Vga_rgb      : out std_logic_vector (7 downto 0); -- R2, R1, R0, G2, G1, G0, B1, B0
	     Vga_vsync    : out std_logic;
         Vga_hsync    : out std_logic
      );
   end component;

   --����״̬
   signal Joy:integer range 0 to 10;
   signal Stomach:integer range 0 TO 10;
   
   --����ѡ�����ʲô����ͼ��
   signal Vga_choose : integer range 0 to 9;
   
   constant ACTIVE_ONE   : integer := 0;

   constant PLAY_ONE     : integer := 1;
   constant PLAY_TWO     : integer := 2;
   constant PLAY_THREE   : integer := 3;
   constant PLAY_FOUR    : integer := 4;

   constant FEED_ONE     : integer := 5;
   constant FEED_TWO     : integer := 6;
   constant FEED_THREE   : integer := 7;
   constant FEED_FOUR    : integer := 8;

   constant DEAD_ONE     : integer := 9;
   
   --����
   signal Reset:std_logic;
   signal Play:std_logic;
   signal Feed:std_logic;
   
   --������״̬
   type con_state is (con_active, con_feed, con_play, con_dead);
   signal Controller_state : con_state;
   
   begin
	
   --������ֵ
   Reset <= Low_sw_an(0);
   Feed <= Low_sw_an(1);
   Play <= Low_sw_an(2);
	
   --vga��ʾ
   vga:vga_out port map(Clk, '0', Vga_choose, Joy, Stomach, Vga_rgb, Vga_vsync, Vga_hsync);
	
   --��Ϸ��ʼ��
   process(reset, Second)
      variable minute:integer range 0 TO 59;
	  variable time:integer range 0 TO 5;
      begin		
	  if Reset = '0' then 
		 --������ʼ��
		 Joy <= 10;
	     Stomach <= 10;
		 Controller_state <= con_active;
		 
	     --���ų�ʼ������
		 Vga_choose <= ACTIVE_ONE;
		
	  
	  elsif Controller_state = con_active then

	    --ιʳ
	     if Feed = '0' then
	        if Stomach < 10 then
		       Stomach <= Stomach + 1;
		    end if;
			
		    --����ιʳ����
		    Controller_state <= con_feed;
	  
	     elsif Play = '0' then
	        if Joy < 10 then
		       Joy <= Joy + 1;
		    end if;
			
		    --�������涯��
		    Controller_state <= con_play;
		
		--����ʱ������ֶȺͱ�ʳ��
		 elsif rising_edge(Second) then
	        Minute:=Minute+1;
	
	        if Minute = 59 then
	           if Joy > 0 and Stomach > 0 then 
		          Joy <= Joy - 1;
		   	      Stomach <= Stomach - 1;
		       else 
			      Controller_state <= con_dead;
			      --������������
			      --�ȴ�reset
			      Vga_choose <= DEAD_ONE;
	           end if;
	        Minute := 0;
	        end if;  
	 
	     end if;
	
	  elsif Second = '0' and Controller_state = con_feed then
	     time:=time+1;
		 
		 if time = 1 then
		    Controller_state <= con_feed;
		    Vga_choose <= FEED_ONE;
		 elsif time = 2 then
			Controller_state <= con_feed;
			Vga_choose <= FEED_TWO;
		 elsif time = 3 then
		    Controller_state <= con_feed;
		   	Vga_choose <= FEED_THREE;
		 elsif time = 4 then
			Controller_state <= con_feed;
			Vga_choose <= FEED_FOUR;
		 else
		    Vga_choose <= ACTIVE_ONE;
		    time := 0;
	        Controller_state <= con_active;
		 end if;
	
	  elsif Second = '0' and Controller_state = con_play then
	     time:=time+1;
		 if time = 1 then
		    Controller_state <= con_play;
		    Vga_choose <= PLAY_ONE;
		 elsif time = 2 then
			Controller_state <= con_play;
			Vga_choose <= PLAY_TWO;
		 elsif time = 3 then
		    Controller_state <= con_play;
		   	Vga_choose <= PLAY_THREE;
		 elsif time = 4 then
			Controller_state <= con_play;
			Vga_choose <= PLAY_FOUR;
		 else
		    Vga_choose <= ACTIVE_ONE;
		    time := 0;
	        Controller_state <= con_active;
		 end if;
		
	  else
         Vga_choose <= DEAD_ONE;

	  end if;   
	
   end process;   
	
end nan;