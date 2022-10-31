clear;
clc;
X = importdata('test_data.txt');
mymap = [0.6350 0.2 0 %-2
     1 1 1 %-1
     0 0 0 %0
     1 0 0 %1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   %1
     0 1 0 %2
     0 1 1 %3
     0 0 1 %4
     0.75, 0, 0.75 %5
     1 1 0];%6
ch_slower_lane = 0.55;%chance of flashing to the right
max_prob_ch_hispe = 0.65;%chance of flashing to the left
new_car_prob = 0.6;%new cars
dec_prob = 0.25;%chance of decreasing speed
for pub=1:5
full_road = zeros(41,60);
full_road(:,:) = -2;
lane(1:2,1:60) = -1;%initialize fast lane
if (pub<2)
    lane(2,:) = X(:,1)';%initialize slow lane
else
    index_lane1 = randsample(50,6)';%random car positions on fast lane
    index_lane2 = randsample(50,10)';%random car positions on slow lane
    lane(1,index_lane1) = randi([0 5],1,6);%random speed of the cars at fast lane
    lane(2,index_lane2) = randi([0 5],1,10);%random speed of the cars at slow lane
end
if(pub == 1)
    [d,c] = size(lane);%init
end
par_slots = zeros(1,c);
par_slots(1,:) = -2;
par_slots(1,10:c-20) = -1;
lane(3,:) = par_slots;


full_road(2,:)=lane(1,:);
full_road(3,:)=lane(2,:);
full_road(4,:) = lane(3,:);

[iter,~] = size(full_road);
full_road(iter+4,:) = -2;

for e=4:4:iter
    signals = zeros(d+1,c);
    if ((lane(2,1) == -1) && (rand(1)>1-new_car_prob))%new cars
        lane(2,1) = 1;
    end
    lane(1:2,51:60) = -1;%clear cars after 50 index
    for j=c-10:-1:1
        for i=1:d
%            if((signals(i,j)==-1))           
%            elseif((signals(i,j)==1) && lane(1,j)==-1)
%                lane(1,j) = lane(i,j);
%                lane(i,j) = -1;
%                signals(i,j) = 0;
%            end
           moved = 0;
           speed = lane(i,j); %current speed of the car
           if(speed>=0)
              if(speed<5)
                  
                  %Rule 1#acceleration
                  if(lane(i,j+1:j+speed+1)==-1)
                      lane(i,j) = -1;
                      lane(i,j+speed) = speed + 1;
                      next_speed = lane(i,j+speed);
                      moved = 1;
                  end   
              end

              if(lane(i,j+1:j+speed)==-1)
                  lane(i,j) = -1;
                  lane(i,j+speed) = speed;
                  next_speed = lane(i,j+speed);
                  moved = 1;
              end

              %Rule 2#breaking 
              if(moved)
                  if(max(lane(i,j+speed+1:j+speed+next_speed))~=-1)
                      found = 0;
                      count = 0;
                      for k=j+1+speed:j+speed+next_speed
                          count = count+1;
                          if((~found)&&(lane(i,k)>=0))
                              found = 1;
                              lane(i,j+speed) = count-1;
                          end
                      end
                  end
              else
                  if(max(lane(i,j+1:j+speed))~=-1)
                      found = 0;
                      count = 0;
                      for k=j+1:j+speed
                          count = count+1;
                          if((~found)&&(lane(i,k)>=0))
                              found = 1;
                              lane(i,j) = -1;
                              lane(i,j+count-1) = 0;
                          end
                      end
                  end
              end
           end
        end
    end
    %Rule3#random speed decrease
    decreased = 0;
    for j=c-10:-1:1      
        for i=1:d+1          
            rand_dec = lane(i,j);
            if(rand_dec>0 && rand_dec<=5)
                if ((lane(i,j) ~= -1) && (rand(1)>1-dec_prob))
                    lane(i,j) = rand_dec-1;
                    decreased = 1;
                end
            end
            if (decreased)
                rand_dec = rand_dec-1;
            end
            %Signal indication for lane change
            if((rand_dec>0)   &&((rand(1)*(rand_dec/5))>1-max_prob_ch_hispe))
                signals(i,j) = 1;%flashing to the left
             elseif((rand_dec>0)  &&(rand(1)*((6-rand_dec)/5)>1-ch_slower_lane))
                 signals(i,j) = -1;%flashing to the right
            end
        end
    end
    temp = lane;
    %flash switching and lane changing 
    for i=1:d+1
        if(i<d+1)
            idx_l = find(signals(i+1,:)==1);%spots that cars want to flash left
            vac_sp_l = lane(i,idx_l)==-1;% checking which of these spots are occupied
            temp(i,idx_l(vac_sp_l)) = 6;%number 6 is flashing color for imagesc
            lane(i,idx_l(vac_sp_l)) = lane(i+1,idx_l(vac_sp_l));%car going to the left
            lane(i+1,idx_l(vac_sp_l)) = -1;%
            signals(i+1,idx_l(vac_sp_l)) = 0;%switching off flash
        end
        if(i>=d)
            idx_r = find(signals(i-1,:)==-1);%spots that cars want to flash right
            vac_sp_r = lane(i,idx_r)==-1;
            temp(i,idx_r(vac_sp_r)) = 6;
            if(i==d+1)
                lane(i,idx_r(vac_sp_r)) = 0;%car stoped
            else
                lane(i,idx_r(vac_sp_r)) = lane(i-1,idx_r(vac_sp_r));
            end
            lane(i-1,idx_r(vac_sp_r)) = -1;
            signals(i-1,idx_r(vac_sp_r)) = 0;
        end
    end
    %copy lane to time diagram
    full_road(e+d:e+d+2,:) = temp(1:d+1,:);
%     drawnow;
%     imagesc(full_road(:,1:50));
%     colormap(mymap); axis equal;
%     colorbar
end
%plot lane-time
figure
imagesc(full_road(:,1:50));
colormap(mymap); axis equal;
colorbar
end