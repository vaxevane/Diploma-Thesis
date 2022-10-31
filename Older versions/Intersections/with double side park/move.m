function[lane,park_signals,park_flags,change_signals] = move(lane,new_car_prob,park_signals,park_flags,dec_prob)
    [d,c] = size(lane);
    d=1;
    change_signals = zeros(d+2,c);%signals for changing lanes    
    
    if ((lane(1,1) == -1) && (rand(1)>1-new_car_prob))%new cars
        lane(1,1) = 1;
        park_signals(1,1) = rand-0.4;
    end
    park_signals(park_signals>1) = 1;%if desire bigger that 1
    park_signals(park_signals<-1) = -1;%if desire bigger that 1
    park_signals(:,c-9:c) = 0;
    lane(1,c-9:c) = -1;%clear cars after 20 index
    for j=c-10:-1:1
        for i=1:d
           moved = 0;
           speed = lane(i,j); %current speed of the car
           if(speed>=0 && speed<6)
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
        park_signals(i,find(lane(i,:)>=0 & lane(i,:)<6)) = park_signals(i,find(park_signals(i,:)~=0));
        park_signals(i,find(lane(i,:)<0)) = 0;
    end

    %Rule3#random speed decrease
    for j=c-10:-1:1    
        decreased = 0;
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
            if(rand_dec>=0 && rand_dec<6 && (park_signals(i,j)<1 && park_signals(i,j)>-1))%<1 bec if he already want to park he should stay commited in order to park
                if(park_signals(i,j)<0)
                    park_signals(i,j) = park_signals(i,j)-0.1;%was 0.3
                else
                    park_signals(i,j) = park_signals(i,j)+0.1;%was 0.3
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