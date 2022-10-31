function[lane,lane_Car_ID,ID_max,park_signals,park_flags,change_signals] = move(lane,lane_Car_ID,ID_max,new_car_prob,new_truck_prob,park_signals,park_flags,dec_prob,park_prob)
    [d,c] = size(lane);
    d=1;
    change_signals = zeros(d+2,c);%signals for changing lanes    
    if(lane(1,1) == -1 && lane(1,2)== -1 && (rand(1)>1-new_truck_prob))
        lane(1,1:2) = 1;
        park_signals(1,1:2) = rand-0.4;
        lane_Car_ID(1,1:2) = ID_max+1;
        ID_max = ID_max + 1;
    end
    if ((lane(1,1) == -1) && (rand(1)>1-new_car_prob))%new cars
        lane(1,1) = 1;
        park_signals(1,1) = rand-0.4;
        lane_Car_ID(1,1) = ID_max+1;
        ID_max = ID_max + 1;
        %lane_Car_ID(1,1) = lane_Car_ID(1,find(lane_Car_ID(1,:)~=0,1))+1;
    end
    park_signals(park_signals>1) = 1;%if desire bigger that 1
    park_signals(park_signals<-1) = -1;%if desire bigger that 1
    park_signals(:,c-9:c) = 0;
    lane_Car_ID(1,c-9:c) = 0;
    lane(1,c-9:c) = -1;%clear cars after 40 index
    
    j = c-10;
    next_spot = j+1;
    flag_spot = 0;
    sd = 1;
    while(j>=1)   
        for i=1:d
           moved = 0;
           found = 0;
           speed = lane(i,j); %current speed of the car
           ID = lane_Car_ID(i,j);%ID of each car
           %If truck then don't apply rules just give values 
           if(ID~=0 && ID == lane_Car_ID(i,next_spot))
               lane(i,j) = -1;
               if (lane(i,next_spot)>3)
                   lane(i,next_spot) = 3;
               end
               lane(i,next_spot-1) = lane(i,next_spot);
               lane_Car_ID(i,j) = 0;
               lane_Car_ID(i,next_spot-1) = ID;  
               next_spot = next_spot-1;
               if(flag_spot ~= 0)
                   park_flags(sd,flag_spot-1) = next_spot;
                   if(park_flags(sd,flag_spot) == 0)
                       lane(sd+1,flag_spot-1) = -1;
                       park_flags(sd,flag_spot-1) = 0;
                   end
               end
               
           elseif(speed>=0 && speed<6)              
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
              if(moved || found)
                  lane_Car_ID(i,j) = 0;
              end
              lane_Car_ID(i,next_spot) = ID;
              
              %Keeping track of the car that flagged the parking pos
              flag_spot = 0;
              for side=1:2
                  spot = find(park_flags(side,:) == j);
                  if(i==d & spot)
                      park_flags(side,spot) = next_spot;
                      if(j>1)
                          if(ID == lane_Car_ID(i,j-1))
                              flag_spot = spot;
                          else
    %                           flag_spot = 0;
                          end
                      end
                      sd = side;
                      %Stopping next to his flagged park spot
                      if(next_spot>=spot)                      
                          lane(i,spot) = 1;
                          if(rand(1)>1-park_prob)
                              lane(side+1,spot) = -1;
                              park_flags(side,spot) = 0;
                          else
                              park_flags(side,spot) = spot; 
                          end
                          if(spot ~= next_spot)
                              lane(i,next_spot) = -1;
                              lane_Car_ID(i,spot) = lane_Car_ID(i,next_spot);
                              lane_Car_ID(i,next_spot) = 0;
                          end
                          next_spot = spot;
                      elseif(next_spot<spot)
                          par_dis = spot-next_spot;
                          if(next_speed>2 && par_dis<=next_speed)
                              lane(i,next_spot) = next_speed-2;
                          end
                      end
                  end
              end
              
           end
        end
        j = j - 1;
    end
    %Move park values to new positions
    for i=1:d
        park_signals(i,find(lane(i,:)>=0 & lane(i,:)<6)) = park_signals(i,find(park_signals(i,:)~=0));
        park_signals(i,find(lane(i,:)<0)) = 0;
    end

    %Rule3#random speed decrease
    j = c-10;
    while (j>=1)          
        for i=1:d      
            same_car = 0;
            decreased = 0;
            rand_dec = lane(i,j);
            ID = lane_Car_ID(i,j);
            %give same values to trucks (random dec,park and flash)
            if(ID ~=0 && ID == lane_Car_ID(i,j+1))
                same_car = 1;
                lane(i,j) = lane(i,j+1);
                park_signals(i,j) = park_signals(i,j+1);
                %cond1 = (lane(i+1,j) == -1 && (lane(i+1,j+1) == 0 || lane(i+1,j+1) == -2));
                %cond2 = (lane(i+2,j) == -1 && (lane(i+2,j+1) == 0 || lane(i+2,j+1) == -2));
                change_signals(i,j) = change_signals(i,j+1);
            end
            
            if(~same_car)
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
                        park_signals(i,j) = park_signals(i,j)-0.2;
                    else
                        park_signals(i,j) = park_signals(i,j)+0.2;
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
                    if(rand_dec<=2)
                        if(j>2)
                            if(ID == lane_Car_ID(i,j-1))
                                %For Truck's flashing
                                if(lane(i+2,j-1:j) == -1)
                                    change_signals(i,j) = 1;
                                end
                            else
                                %for car's flashing
                                change_signals(i,j) = 1;
                            end
                        end
                    else
                        lane(i,j) =  rand_dec - 2 ;
                    end
                elseif(park_signals(i,j) <= -1)
                    if(rand_dec<=2)
                        if(j>2)
                            %For Truck's flashing
                            if(ID == lane_Car_ID(i,j-1))
                                if(lane(i+1,j-1:j) == -1)
                                    change_signals(i,j) = -1;
                                end
                            else
                                %for car's flashing
                                change_signals(i,j) = -1;
                            end
                        end
                    else
                        lane(i,j) =  rand_dec - 2 ;
                    end
                end
            end
        end  
        j = j - 1;
    end