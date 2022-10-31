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
     0.75 0 0.75 %5
     1 1 0 %6
     0.45 0.45 0.45]; %7
ch_slower_lane = 0.55;%chance of flashing to the right
max_prob_ch_hispe = 0.65;%chance of flashing to the left
new_car_prob = 0.7;%new cars
dec_prob = 0.25;%chance of decreasing speed
rand_park = 0.15;%random chance to park
first_park = 10;
last_park = 40;
max_parked = 5;%max time step that the car is parked 

cars1 = 6;
cars2 = 12;
for pub=1:5
full_road = zeros(65,60);
full_road(:,:) = -2;
lane(1:2,1:60) = -1;%initialize all lanes
if (0)
    lane(2,:) = X(:,1)';%initialize slow lane
else
    index_lane1 = randsample(50,cars1)';%random car positions on fast lane
    index_lane2 = randsample(50,cars2)';%random car positions on slow lane
    lane(1,index_lane1) = randi([0 5],1,cars1);%random speed of the cars at fast lane
    lane(2,index_lane2) = randi([0 5],1,cars2);%random speed of the cars at slow lane
end
if(pub == 1)
    [d,c] = size(lane);%init
end
par_slots = zeros(1,c);
steps_parked = zeros(1,c);%how many time steps each car has stayed parked
par_slots(1,:) = -2;
par_slots(1,first_park:last_park) = -1;
% par_slots(1,12:15)=0;
% par_slots(1,19)=0;
% par_slots(1,30:32)=0;
lane(3,:) = par_slots;
park_signals = zeros(d,c);
park_flags = zeros(1,c);
park_flags(1,first_park:last_park) = 0; 

%desire to park 
park_signals(1,index_lane1) = rand(1,cars1)/2;
park_signals(2,index_lane2) = rand(1,cars2)/2;

full_road(2,:) = lane(1,:);
full_road(3,:) = lane(2,:);
full_road(4,:) = lane(3,:);

[iter,~] = size(full_road);
full_road(iter+d+2,:) = -2;

for e=4:4:iter
    change_signals = zeros(d+1,c);%signals for changing lanes
    if ((lane(2,1) == -1) && (rand(1)>1-new_car_prob))%new cars
        lane(2,1) = 1;
        park_signals(2,1) = rand;
    end
    
    if ((lane(1,1) == -1) && (rand(1)>1-new_car_prob))%new cars
        lane(1,1) = 3;
        park_signals(1,1) = rand;
    end
    park_signals(park_signals>1) = 1;%if desire bigger that 1
    park_signals(park_signals<0) = -0.01;%if desire bigger that 1
    park_signals(:,51:60) = 0;
    lane(1:2,51:60) = -1;%clear cars after 50 index
    for j=c-10:-1:1
        for i=1:d
           moved = 0;
           speed = lane(i,j); %current speed of the car
           if(speed>=0)
              if(speed<5)
                  next_spot = j;
                  next_speed = speed;
                  
                  %Rule 1#acceleration
                  if(lane(i,j+1:j+speed+1)==-1)
                      lane(i,j) = -1;
                      lane(i,j+speed) = speed + 1;
                      next_speed = lane(i,j+speed);
                      next_spot = j+speed;
                      moved = 1;
                  end   
              end

              if(lane(i,j+1:j+speed)==-1)
                  lane(i,j) = -1;
                  lane(i,j+speed) = speed;
                  next_speed = lane(i,j+speed);
                  next_spot = j+speed;
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
                              next_speed = count-1;
                              next_spot = j+speed;
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
                              next_speed = 0;
                              next_spot = j+count-1;
                          end
                      end
                  end
              end
              %Keeping track of the car that flagged the parking pos
              spot = find(park_flags == j);
              if(i==d & spot)
                  park_flags(spot) = next_spot;
                  %Stopping next to his flagged park spot
                  if(next_spot>=spot)
                      lane(i,spot) = 1;
                      lane(d+1,spot) = -1;
                      park_flags(spot) = 0; 
                      if(spot ~=next_spot)
                          lane(i,next_spot) = -1;
                      end
                  end
              end
              
           end
        end
    end
    %Move park values to new positions
    for i=1:d
        park_signals(i,find(lane(i,:)>=0)) = park_signals(i,find(park_signals(i,:)~=0));
        park_signals(i,find(lane(i,:)<0)) = 0;
    end

    %Rule3#random speed decrease
    decreased = 0;
    for j=c-10:-1:1      
        for i=1:d          
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

            %Change desire to park for all cars
            if(rand_dec>=0 && park_signals(i,j)<1)%<1 bec if he already want to park he should stay commited in order to park
                if(rand_dec>3)
                    park_signals(i,j) = park_signals(i,j)-(0.55/rand_dec);
                else
                    park_signals(i,j) = park_signals(i,j)+0.2;
                end
            end
            
            %Signal indication for lane change
            if((i>1) && (rand_dec>0) && ((rand(1)*(rand_dec/5))>1-max_prob_ch_hispe))
                change_signals(i,j) = 1;%flashing to the left
             elseif((i<d) && (rand_dec>0) && (rand(1)*((6-rand_dec)/5)>1-ch_slower_lane))
                change_signals(i,j) = -1;%flashing to the right
            end       
            %Signal indication for cars that want to park
            if(park_signals(i,j) >= 1)
                change_signals(i,j) = -1;
            end
        end 
        %Signal indication for unparking cars
        idx_unpark = find(steps_parked(1,:) >= 5);
        change_signals(d+1,idx_unpark) = 1;
    end
    temp = lane;
    
    %flash switching and lane changing 
    for i=1:d+1
        if(i<d+1)
            idx_l = find(change_signals(i+1,:)==1);%spots that cars want to flash left
            vac_sp_l = lane(i,idx_l)==-1;% checking which of these spots are occupied
            temp(i,idx_l(vac_sp_l)) = 6;%number 6 is flashing color for imagesc
            lane(i,idx_l(vac_sp_l)) = lane(i+1,idx_l(vac_sp_l));%car going to the left
            lane(i+1,idx_l(vac_sp_l)) = -1;
            change_signals(i+1,idx_l(vac_sp_l)) = 0;%switching off flash
            if(i<d)
                park_signals(i,idx_l(vac_sp_l)) = park_signals(i+1,idx_l(vac_sp_l));
                park_signals(i+1,idx_l(vac_sp_l)) = 0;
            end
            if(i == d)
                park_signals(i,idx_l(vac_sp_l)) = rand(1,sum(vac_sp_l))/5;%giving new park variables
                steps_parked(idx_l(vac_sp_l)) = 0;
            end
        end
        if(i>=2)
            idx_r = find(change_signals(i-1,:)==-1);%spots that cars want to flash right
            vac_sp_r = lane(i,idx_r)==-1;
            temp(i,idx_r(vac_sp_r)) = 6;
            if(i == d+1)
                park_signals(i-1,idx_r(vac_sp_r)) = 0;%make zero the desire to park after parking
                lane(i,idx_r(vac_sp_r)) = 0;%car stoped
            else
                lane(i,idx_r(vac_sp_r)) = lane(i-1,idx_r(vac_sp_r));
                park_signals(i,idx_r(vac_sp_r)) = park_signals(i-1,idx_r(vac_sp_r));
                park_signals(i-1,idx_r(vac_sp_r)) = 0;
            end
            lane(i-1,idx_r(vac_sp_r)) = -1;
            change_signals(i-1,idx_r(vac_sp_r)) = 0;
        end
    end
    
    idx_park = find(park_signals(d,1:last_park)>=1);
    exclude_already_flagged = park_flags(find(park_flags~=0));
    park_spot = lane(d+1,idx_park) == -1;
    park_temp = idx_park(~park_spot);
    park_temp = setdiff(park_temp,exclude_already_flagged);
    
    %Put flag for cars that didnt find parking right next to them
    for s=length(park_temp):-1:1
        temp_idx = find(lane(d+1,park_temp(s)+1:end) == -1,1)+park_temp(s);
        park_flags(1,temp_idx) =  park_temp(s);%Reserving spot for the particular car
        temp(d+1,temp_idx) = 7;
        lane(d+1,temp_idx) = 7;
    end
    
    %Increase time steps for each car parked
    idx_dur = find(lane(d+1,:) == 0);
    steps_parked(idx_dur) = steps_parked(idx_dur)+1;
    
    %copy lane to time diagram for testing on each step
    full_road(e+d:e+d+2,:) = temp(1:d+1,:);
    
%     drawnow;
%     figure
%     imagesc(full_road(:,1:50));
%     colormap(mymap); axis equal;
%     colorbar
%     caxis([-2 7])
end
%plot lane-time
figure
imagesc(full_road(:,1:50));
colormap(mymap); axis equal;
colorbar
caxis([-2 7])
end