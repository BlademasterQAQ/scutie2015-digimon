library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;

entity controller is
   port(Clk:in std_logic;
      Second:in std_logic;--用于播放动画的延迟的时钟,1秒钟1正脉冲
	  Minute:in std_logic;--用于减少饱食度和欢乐度的时钟,1分钟1正脉冲
	  Low_sw_an :in std_logic_vector (3 downto 0 ));
end entity;

architecture nan OF controller IS
   --宠物状态
   signal Joy:integer range 0 to 10;
   signal Stomach:integer range 0 TO 10;
	
   --输入
   signal Reset:std_logic;
   signal Play:std_logic;
   signal Feed:std_logic;
   signal State:std_logic;
	
   --用于作为标志信号,防止播放动画的时候玩乐和喂食串了,或者吃到一半被中断
   --Shield='1'时按键无效,正在播放动画
   --Shield='0'时按键有效
   --一个简陋的互斥量
   signal Shield:std_logic;
	
   --用于是否在查看状态的标志量
   --用于界定是否在查看状态中
   --'0'不在,'1'在
   signal Is_state:std_logic;
	
   --用于是否在死亡状态的标志量
   --'0'不在,'1'在
   --死亡状态直到按了reset才会重新开始游戏
   signal Is_dead:std_logic;
	
   --用于界定是否在吃或玩,方便用计数器做延时
   --播放一幅图不需要延时
   --但是像吃和玩需要播放动画,需要延时来放图片
   --使用for语句延时消耗资源太多
   --'0'不在,'1'在
   signal Is_feed:std_logic;
   signal Is_play:std_logic;
	
   begin
	
   --按键赋值
   Reset <= Low_sw_an(0);
   Feed <= Low_sw_an(1);
   Play <= Low_sw_an(2);
   State <= Low_sw_an(3);
	
   --游戏初始化
   process(clk,reset)
      begin		
	  if Reset = '0' then 
		 Joy <= 10;
	     Stomach <= 10;
		 Shield <= '0';
		 Is_state <= '0';
		 Is_dead <= '0';
		 Is_feed <= '0';
	     Is_play <= '0';
	     --播放初始化动画
	  end if;
   end process;
	
	--喂食
   process(Clk,Feed)
      begin		
	  if Feed = '0' and Shield = '0' and Is_dead = '0' and Is_state = '0' THEN 
	     Shield <= '1';
			
		 if Stomach < 10 then
		    Stomach <= Stomach + 1;
		 end if;
			
		 --播放喂食动画
		 Is_feed <= '1';
			
		 --Shield <= '0';
			
      end if;
   end process;
	
	--播放喂食动画的进程
   process(Clk, Second,Is_feed)
	  begin		
	  if Is_feed = '1' then
	     Is_feed <= '0';
		 Shield <= '0';
      end if;
   end process;
	
   --陪玩
   process(Clk,Play)
      variable mitime:integer range 0 to 50000000;
	  begin		
	  if Play = '0' and Shield = '0' and Is_dead = '0' and Is_state = '0' THEN 
	     Shield <= '1';	
			
		 if Joy < 10 then
		    Joy <= Joy + 1;
		 end if;
			
		 --播放陪玩动画
		 Is_play <= '1';
			
		 --shield <= '0';
	  end if;
   end process;
	
   --播放陪玩动画的进程
   process(Clk,Second,Is_play)
      begin		
	  if Is_play = '1' then
	     Is_play <= '0';
		 Shield <= '0';
	  end if;
   end process;
	
   --查看状态
   process(Clk,State)
      begin		
	  if State = '0' and Shield = '0' and Is_dead = '0' THEN 
		
	     Shield <= '1';
			
		 if Is_state = '0' then
		    --进入状态界面
		    --根据joy和stomache显示不同长度的状态条
				
		 else 
		    --回到主界面
			--播放主界面的动画
		 end if;
			
		 Shield <= '0';
      end if;
   end process;
	
   --根据时间掉欢乐度和饱食度
   process(Minute)
      begin		
	  if rising_edge(Minute) and  Is_dead = '0' then
	     if Joy > 0 or Stomach > 0 then 
		    Joy <= Joy - 1;
			Stomach <= Stomach - 1;
		 else 
			Is_dead <= '1';
			--触发死亡场景
			--等待reset
	     end if;
      end if;
   end process;
	
end nan;