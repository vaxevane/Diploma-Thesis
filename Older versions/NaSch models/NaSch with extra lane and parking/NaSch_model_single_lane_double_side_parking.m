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
     0.45 0.45 0.45 %7
     1 1 0 %8
     0 0 0]; %9
ch_slower_lane = 0.55;%chance of flashing to the right
max_prob_ch_hispe = 0.65;%chance of flashing to the left
new_car_prob = 0.8;%new cars
dec_prob = 0.25;%chance of decreasing speed
rand_park = 0.15;%random chance to park
first_park = 5;
last_park = 45;
chance_of_not_having_flag = 0.15;
max_parked = 5;%max time step that the car is parked 

cars1 = 12;

for pub=1:5
full_road = zeros(65,60);
full_road(:,:) = -2;
lane(1,1:60) = -1;%initialize all lanes
if (0)
    lane(2,:) = X(:,1)';%initialize slow lane
else
    index_lane1 = randsample(50,cars1)';%random car positions on fast lane
    lane(1,index_lane1) = randi([0 5],1,cars1);%random speed of the cars at fast lane
end
if(pub == 1)
    [d,c] = size(lane);%init
end
par_slots = zeros(2,c);
steps_parked = zeros(2,c);%how many time steps each car has stayed parked
par_slots(1:2,:) = -2;
par_slots(1,first_park:last_park) = -1;
par_slots(2,5:first_park+10) = -1;
par_slots(2,first_park+15:last_park-5) = -1;
par_slots(1,13:14) = 0;
par_slots(1,21:22) = 0;
par_slots(1,32:33) = 0;
par_slots(2,10:12) = 0;
par_slots(2,24:25) = 0;
lane(2,:) = par_slots(1,:);
lane(3,:) = par_slots(2,:);
park_signals = zeros(d,c);
park_flags = zeros(2,c);
park_flags(2,first_park:last_park) = 0; 

%desire to park 
park_signals(1,index_lane1) = (rand(1,cars1)/2)-0.2;
full_road(2,:) = lane(3,:);
full_road(3,:) = lane(1,:);
full_road(4,:) = lane(2,:);
full_road(4,find(lane(2,:)==0)) = 9;
full_road(2,find(lane(3,:)==0)) = 9;

[iter,~] = size(full_road);
full_road(1,:) = -2;
full_road(iter+d+3,:) = -2;

for e=4:4:iter
    change_signals = zeros(d+2,c);%signals for changing lanes    
    
    if ((lane(1,1) == -1) && (rand(1)>1-new_car_prob))%new cars
        lane(1,1) = 1;
        park_signals(1,1) = rand-0.4;
    end
    park_signals(park_signals>1) = 1;%if desire bigger that 1
    park_signals(park_signals<-1) = -1;%if desire bigger that 1
    park_signals(:,51:60) = 0;
    lane(1,51:60) = -1;%clear cars after 50 index
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
              for side=1:2
                  spot = find(park_flags(side,:) == j);
                  if(i==d & spot)
                      park_flags(side,spot) = next_spot;
                      %Stopping next to his flagged park spot
                      if(next_spot>=spot)
                          lane(i,spot) = 1;
                          lane(side+1,spot) = -1;
                          park_flags(side,spot) = 0; 
                          if(spot ~=next_spot)
                              lane(i,next_spot) = -1;
                          end
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
                if(park_signals(i,j)<0)
                    park_signals(i,j) = park_signals(i,j)-0.4;%was 0.3
                else
                    park_signals(i,j) = park_signals(i,j)+0.4;%was 0.3
                end
            end
%Not needed in this simulation cause we only have a single lane            
            %Signal indication for lane change
%             if((i>1) && (rand_dec>0) && ((rand(1)*(rand_dec/5))>1-max_prob_ch_hispe))
%                 change_signals(i,j) = 1;%flashing to the left
%              elseif((i<d) && (rand_dec>0) && (rand(1)*((6-rand_dec)/5)>1-ch_slower_lane))
%                 change_signals(i,j) = -1;%flashing to the right
%             end       

            %Signal indication for cars that want to park
            if(park_signals(i,j) >= 1)
                change_signals(i,j) = 1;
            elseif(park_signals(i,j) <= -1)
                change_signals(i,j) = -1;
            end
        end       
    end
    
    %Signal indication for unparking cars
    idx_unpark = find(steps_parked(1,:) >= 5);
    change_signals(d+1,idx_unpark) = 1;
    
    idx_unpark = find(steps_parked(2,:) >= 5);
    change_signals(d+2,idx_unpark) = -1;
    
    %     %cars that haven't acquired the flag system
    for side=d+1:d+2
        if (side == d+1)
            idx_park = find(park_signals(d,1:last_park)<=-1);
        else
            idx_park = find(park_signals(d,1:last_park)>=1);
        end 
        exclude_already_flagged = park_flags(side-1,find(park_flags(side-1,:)~=0));
        park_spot = lane(side,idx_park) == 7;
        park_temp = idx_park(park_spot);
        park_temp = setdiff(park_temp,exclude_already_flagged);
        for s=1:length(park_temp)
        %if it's true the car steals the flagged position
            if(1)
                %find the new indexes for the cars who had already flagged
                mask = find(park_flags(side-1,:)~=0);
                mask = mask(find(mask==park_temp(s)):end);
                %taking the flags of the car and after
                moving_flags = exclude_already_flagged(find(exclude_already_flagged==park_flags(side-1,park_temp(s))):end);
                park_flags(side-1,mask) = 0;
                lane(side,mask) = -1;
                %Showing the spot that is taken is unavailable
                lane(side,park_temp(s)) = 0;
                for re=1:length(mask)
                    new_flag = find(lane(side,mask(re):end)==-1,1)+mask(re)-1;
                    if(new_flag<=last_park)
                        park_flags(side-1,new_flag) = moving_flags(re);
                        lane(side,new_flag) = 7;
                        if(new_flag~=mask(re))
                            side
                            e
                            moving_flags(re)
                            fprintf ('Someone took your parking spot at:%d ',park_temp(s));
                            fprintf (' move to new spot:%d \n',new_flag);
                        end
                    else
                        fprintf ('Unfortunately someone took your parking spot and we cant find new pos near\n');
                    end
                end
                %Returning in it to -1 in order to park the car that stole the flag
                lane(side,park_temp(s)) = -1;
            end
        end
    end
    
    temp = lane;
    temp(d+1,find(lane(d+1,:)==0)) = 9;%parked cars value
    temp(d+2,find(lane(d+2,:)==0)) = 9;
    %flash switching and lane changing 
    for i=1:d+2
        if(i<d+1)
            idx_l = find(change_signals(i+1,:)==1);%spots that cars want to flash left
            vac_sp_l = lane(i,idx_l)==-1;% checking which of these spots are occupied
            temp(i,idx_l(vac_sp_l)) = 8;%number 8 is flashing color for left
            lane(i,idx_l(vac_sp_l)) = lane(i+1,idx_l(vac_sp_l));%car going to the left
            lane(i+1,idx_l(vac_sp_l)) = -1;
            change_signals(i+1,idx_l(vac_sp_l)) = 0;%switching off flash
            if(i<d)
                park_signals(i,idx_l(vac_sp_l)) = park_signals(i+1,idx_l(vac_sp_l));
                park_signals(i+1,idx_l(vac_sp_l)) = 0;
            end
            if(i == d)
                park_signals(i,idx_l(vac_sp_l)) = (rand(1,sum(vac_sp_l))/2)-0.3;%giving new park variables
                steps_parked(1,idx_l(vac_sp_l)) = 0;
            end
        %parking on the top side 
        elseif(i==d+1)
            idx_l = find(change_signals(i-1,:)==1);%spots that cars want to flash left
            vac_sp_l = lane(i+1,idx_l)==-1;% checking which of these spots are occupied
            temp(i+1,idx_l(vac_sp_l)) = 8;%number 8 is flashing color for left
            lane(i+1,idx_l(vac_sp_l)) = 0;%car stops
            lane(i-1,idx_l(vac_sp_l)) = -1;
            change_signals(i-1,idx_l(vac_sp_l)) = 0;%switching off flash
            park_signals(i-1,idx_l(vac_sp_l)) = 0;
        end
        %Unparking from top side
        if(i==d+2)
            idx_r = find(change_signals(i,:)==-1);
            vac_sp_r = lane(i-2,idx_r)==-1;
            temp(i-2,idx_r(vac_sp_r)) = 6;%number 6 is flashing color for right
            lane(i-2,idx_r(vac_sp_r)) = lane(i,idx_r(vac_sp_r));
            lane(i,idx_r(vac_sp_r)) = -1;
            change_signals(i,idx_r(vac_sp_r)) = 0;
            steps_parked(2,idx_r(vac_sp_r)) = 0;
            park_signals(i-2,idx_r(vac_sp_r)) = (rand(1,sum(vac_sp_r))/2)-0.2;
        elseif(i>=2)
            idx_r = find(change_signals(i-1,:)==-1);%spots that cars want to flash right
            vac_sp_r = lane(i,idx_r)==-1;
            temp(i,idx_r(vac_sp_r)) = 6;%number 6 is flashing color for right
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
    for side=d+1:d+2
        if (side == d+1)
            idx_park = find(park_signals(d,1:last_park)<=-1);
        else
            idx_park = find(park_signals(d,1:last_park)>=1);
        end        
        exclude_already_flagged = park_flags(side-1,find(park_flags(side-1,:)~=0));
        park_spot = lane(side,idx_park) == -1;
        park_temp = idx_park(~park_spot);
        park_temp = setdiff(park_temp,exclude_already_flagged);

        %Put flag for cars that didnt find parking right next to them
        for s=1:length(park_temp)
            temp_idx = find(lane(side,park_temp(s)+1:end) == -1,1)+park_temp(s);
            park_flags(side-1,temp_idx) =  park_temp(s);%Reserving spot for the particular car
            temp(side,temp_idx) = 7;
            lane(side,temp_idx) = 7;
        end
    end
    %Increase time steps for each car parked
    idx_dur = find(lane(d+1,:) == 0);
    steps_parked(1,idx_dur) = steps_parked(1,idx_dur)+1;
    idx_dur = find(lane(d+2,:) == 0);
    steps_parked(2,idx_dur) =steps_parked(2,idx_dur)+1;
    
    %copy lane to time diagram for testing on each step
    full_road(e+d+1,:) = temp(3,:);
    full_road(e+d+2:e+d+3,:) = temp(1:d+1,:);
    
%     draw(full_road);

%     drawnow;
%     figure
%     imagesc(full_road(:,1:50));
%     colormap(mymap); axis equal;
%     colorbar
%     caxis([-2 9])
end

%plot lane-time
draw(full_road);
% figure
% imagesc(full_road(:,1:50));
% colormap(mymap); axis equal;
% colorbar
% caxis([-2 9])
end