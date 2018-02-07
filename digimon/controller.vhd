LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
ENTITY controller IS
   PORT(clk:IN std_logic;
      cclk:IN std_logic;--用于播放动画的延迟的时钟,1秒钟1正脉冲
      cccclk:IN std_logic;--用于减少饱食度和欢乐度的时钟,1分钟1正脉冲
      low_sw_an :OUT std_logic_vector (3 downto 0 ));
END ENTITY;

ARCHITECTURE nan OF controller IS
	--宠物状态
	SIGNAL joy:integer RANGE 0 TO 10;
	SIGNAL stomach:integer RANGE 0 TO 10;
	
	--输入
	SIGNAL reset:std_logic;
	SIGNAL play:std_logic;
	SIGNAL feed:std_logic;
	SIGNAL state:std_logic;
	
	--用于作为标志信号,防止播放动画的时候玩乐和喂食串了,或者吃到一半被中断
	--Shield='1'时按键无效,正在播放动画
	--Shield='0'时按键有效
	--一个简陋的互斥量
	SIGNAL shield:std_logic;
	
	--用于是否在查看状态的标志量
	--用于界定是否在查看状态中
	--'0'不在,'1'在
	SIGNAL isState:std_logic;
	
	--用于是否在死亡状态的标志量
	--'0'不在,'1'在
	--死亡状态直到按了reset才会重新开始游戏
	SIGNAL isDead:std_logic;
	
	--用于界定是否在吃或玩,方便用计数器做延时
	--播放一幅图不需要延时
	--但是像吃和玩需要播放动画,需要延时来放图片
	--使用for语句延时消耗资源太多
	--'0'不在,'1'在
	SIGNAL isFeed:std_logic;
	SIGNAL isPlay:std_logic;
	
	BEGIN
	
	--按键赋值
	reset <= low_sw_an(0);
	feed <= low_sw_an(1);
	play <= low_sw_an(2);
	state <= low_sw_an(3);
	
	--游戏初始化
	PROCESS(clk,reset)
		BEGIN		
		IF reset = '0' THEN 
			joy <= '10';
			stomach <= '10';
			shield <= '0';
			isState <= '0';
			isDead <= '0';
			isFeed <= '0';
	        isPlay <= '0';
			--播放初始化动画
		END IF;
	END PROCESS;
	
	--喂食
	PROCESS(clk,feed)
		BEGIN		
		IF feed = '0' and shield = '0' and isDead = '0' and isState = '0' THEN 
			shield <= '1';
			
			if stomach < '10' then
				stomach <= stomach + 1;
			end if
			
			--播放喂食动画
			isFeed = '1';
			
			--shield <= '0';
			
		END IF;
	END PROCESS;
	
	--播放喂食动画的进程
	PROCESS(clk, cclk,isFeed)
		BEGIN
		if isFeed = '1'
			isFeed = '0';
			shield <= '0';
		end if;
	END PROCESS;
	
	--陪玩
	PROCESS(clk,play)
		VARIABLE mitime:integer RANGE 0 TO 50000000;
		BEGIN		
		IF play = '0' and shield = '0' and isDead = '0' and isState = '0' THEN 
			shield <= '1';	
			
			if joy < '10' then
				joy <= joy + 1;
			end if;
			
			--播放陪玩动画
			isPlay = '1';
			
			--shield <= '0';
		END IF;
	END PROCESS;
	
	--播放陪玩动画的进程
	PROCESS(clk, cclk,isPlay)
		BEGIN		
		if isPlay = '1' then
			isPlay = '0';
			shield <= '0';
		end if;
	END PROCESS;
	
	--查看状态
	PROCESS(clk,state)
		BEGIN		
		IF state = '0' and shield = '0' and isDead = '0' THEN 
		
			shield <= '1';
			
			if isState = '0' then
				--进入状态界面
				--根据joy和stomache显示不同长度的状态条
				
			else 
				--回到主界面
				--播放主界面的动画
				
			shield <= '0';
			
		END IF;
	END PROCESS;
	
	--根据时间掉欢乐度和饱食度
	PROCESS(cccclk)
		BEGIN		
		if edge_rising(cccclk) and  isDead = '0' then
			IF joy > '0' OR stomach > '0' THEN 
				joy <= joy - 1;
				stomach <= stomach - 1;
			else 
				isDead <= '1';
				--触发死亡场景
				--等待reset
			END IF;
		END IF;
	END PROCESS;
	
END nan;
