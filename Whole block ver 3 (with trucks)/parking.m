function[lane,lane_Car_ID,temp,park_flags,steps_parked,park_signals] = parking(lane,lane_Car_ID,park_signals,change_signals,park_flags,steps_parked,last_park,e)
    d=1;
    
    %Signal indication for unparking cars
    j = 1;
    for side=d+1:d+2
        idx_unpark = find(steps_parked(side-1,:) >= 5 & lane(side,:) ~= 7);
        if(side == d+1)
            flash = 1;
        elseif(side == d+2)
            flash = -1;
        end
        while j<=length(idx_unpark)
            cond1 = (lane(1,idx_unpark(j):idx_unpark(j)+1) == -1); 
            cond2 = lane_Car_ID(side,idx_unpark(j)) == lane_Car_ID(side,idx_unpark(j)+1); 
            if(cond1 & cond2)
                change_signals(side,idx_unpark(j):idx_unpark(j)+1) = flash;
                j = j + 1;
            elseif(~cond2)
                change_signals(side,idx_unpark(j)) = flash;
            end
            j = j + 1;
        end
    end
    %Old Unparking
%     idx_unpark = find(steps_parked(1,:) >= 5 & lane(d+1,:) ~= 7);
%     change_signals(d+1,idx_unpark) = 1;
%     idx_unpark = find(steps_parked(2,:) >= 5 & lane(d+2,:) ~= 7);
%     change_signals(d+2,idx_unpark) = -1;
    
    %Increment the duration of each flag and disable flag
    idx_dur = find(lane(d+1,:) == 7);
    steps_parked(d,idx_dur) = steps_parked(d,idx_dur)+1;
    idx_dur = find(lane(d+2,:) == 7);
    steps_parked(d+1,idx_dur) = steps_parked(d+1,idx_dur)+1;
    
    idx_unflag = steps_parked(d,:) >= 5 & lane(d+1,:) == 7;
    park_flags(d,idx_unflag) = 0;
    lane(d+1,idx_unflag) = -1;
    steps_parked(d,idx_unflag) = 0;

    idx_unflag = steps_parked(d+1,:) >= 5 & lane(d+2,:) == 7;
    park_flags(d+1,idx_unflag) = 0;
    lane(d+2,idx_unflag) = -1;
    steps_parked(d+1,idx_unflag) = 0;
    
    %cars that haven't acquired the flag system
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
                %conditions in order to let some trucks steal flag pos
                cond1 = (lane_Car_ID(1,park_temp(s)) == lane_Car_ID(1,park_temp(s)+1) && lane(1,park_temp(s)+1)~=0 && lane(1,park_temp(s)+1)~=-2);
                cond2 = (lane_Car_ID(1,park_temp(s)) == lane_Car_ID(1,park_temp(s)-1) && lane(1,park_temp(s)-1)~=0 && lane(1,park_temp(s)-1)~=-2);
                cond3 = (lane_Car_ID(1,park_temp(s)) ~= lane_Car_ID(1,park_temp(s)-1) && lane_Car_ID(1,park_temp(s)) ~= lane_Car_ID(1,park_temp(s)+1));
                if(cond1)                    
                    lane(side,park_temp(s):park_temp(s)+1) = 0;
                elseif(cond2)  
                    lane(side,park_temp(s)-1:park_temp(s)) = 0;
                elseif(cond3)          
                    %Showing the spot that is taken is unavailable
                    lane(side,park_temp(s)) = 0;
                end
                for re=1:length(mask)
                    new_flag = find(lane(side,mask(re):end)==-1,1)+mask(re)-1;
                    if(new_flag<=last_park)
                        park_flags(side-1,new_flag) = moving_flags(re);
                        lane(side,new_flag) = 7;
                        if(new_flag~=mask(re))
                            side
                            e
                            fprintf ('Someone took your parking spot move to new spot:%d \n',new_flag);
                        end
                    else
                        fprintf ('Unfortunately someone took your parking spot and we cant find new pos near\n');
                    end
                end
                %Returning in it to -1 in order to park the car that stole the flag
                if(cond1)                    
                    lane(side,park_temp(s):park_temp(s)+1) = -1;
                elseif(cond2)  
                    lane(side,park_temp(s)-1:park_temp(s)) = -1;
                else                
                    %Showing the spot that is taken is unavailable
                    lane(side,park_temp(s)) = -1;
                end
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
            lane_Car_ID(i,idx_l(vac_sp_l)) = lane_Car_ID(i+1,idx_l(vac_sp_l));
            lane_Car_ID(i+1,idx_l(vac_sp_l)) = 0;
            change_signals(i+1,idx_l(vac_sp_l)) = 0;%switching off flash
            if(i<d)
                park_signals(i,idx_l(vac_sp_l)) = park_signals(i+1,idx_l(vac_sp_l));
                park_signals(i+1,idx_l(vac_sp_l)) = 0;
            end
            if(i == d)
                park_signals(i,idx_l(vac_sp_l)) = (rand(1,sum(vac_sp_l))/2)-0.3;%giving new park variables
                steps_parked(i,idx_l(vac_sp_l)) = 0;
            end
        %Parking on the top side 
        elseif(i==d+1)
            idx_l = find(change_signals(i-1,:)==1);%spots that cars want to flash left
            vac_sp_l = lane(i+1,idx_l)==-1;% checking which of these spots are occupied
            temp(i+1,idx_l(vac_sp_l)) = 8;%number 8 is flashing color for left
            lane(i+1,idx_l(vac_sp_l)) = 0;%car stops
            lane(i-1,idx_l(vac_sp_l)) = -1;
            change_signals(i-1,idx_l(vac_sp_l)) = 0;%switching off flash
            park_signals(i-1,idx_l(vac_sp_l)) = 0;
            lane_Car_ID(i+1,idx_l(vac_sp_l)) = lane_Car_ID(i-1,idx_l(vac_sp_l));
            lane_Car_ID(i-1,idx_l(vac_sp_l)) = 0;
            steps_parked(i,idx_l(vac_sp_l)) = 0;
        end
        
        %Unparking from top side
        if(i==d+2)
            idx_r = find(change_signals(i,:)==-1);
            vac_sp_r = lane(i-2,idx_r)==-1;
            temp(i-2,idx_r(vac_sp_r)) = 6;%number 6 is flashing color for right
            lane(i-2,idx_r(vac_sp_r)) = lane(i,idx_r(vac_sp_r));
            lane(i,idx_r(vac_sp_r)) = -1;
            change_signals(i,idx_r(vac_sp_r)) = 0;
            steps_parked(i-1,idx_r(vac_sp_r)) = 0;
            park_signals(i-2,idx_r(vac_sp_r)) = (rand(1,sum(vac_sp_r))/2)-0.2;
            lane_Car_ID(i-2,idx_r(vac_sp_r)) = lane_Car_ID(i,idx_r(vac_sp_r));
            lane_Car_ID(i,idx_r(vac_sp_r)) = 0;
        elseif(i>=2)
            idx_r = find(change_signals(i-1,:)==-1);%spots that cars want to flash right
            vac_sp_r = lane(i,idx_r)==-1;
            temp(i,idx_r(vac_sp_r)) = 6;%number 6 is flashing color for right
            if(i == d+1)
                park_signals(i-1,idx_r(vac_sp_r)) = 0;%make zero the desire to park after parking
                lane(i,idx_r(vac_sp_r)) = 0;%car stoped                
                steps_parked(i-1,idx_r(vac_sp_r)) = 0;
            else
                lane(i,idx_r(vac_sp_r)) = lane(i-1,idx_r(vac_sp_r));
                park_signals(i,idx_r(vac_sp_r)) = park_signals(i-1,idx_r(vac_sp_r));
                park_signals(i-1,idx_r(vac_sp_r)) = 0;
            end
            lane(i-1,idx_r(vac_sp_r)) = -1;
            lane_Car_ID(i,idx_r(vac_sp_r)) = lane_Car_ID(i-1,idx_r(vac_sp_r));
            lane_Car_ID(i-1,idx_r(vac_sp_r)) = 0;
            change_signals(i-1,idx_r(vac_sp_r)) = 0;
        end
    end
    %Putting flag
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
        s = 1;
        while (s<=length(park_temp))
            %conditions for giving trucks park_flags
            cond1 = lane_Car_ID(1,park_temp(s)) == lane_Car_ID(1,park_temp(s)+1);
            if(park_temp(s)-1>0)
                cond2 = lane_Car_ID(1,park_temp(s)-1) == lane_Car_ID(1,park_temp(s));
            else 
                cond2= 0;
            end
            temp_idx = [];
            %Park_flags for trucks
            if(cond1 || cond2)
                if cond1, value = park_temp(s);else, value = park_temp(s)-1;end
                flag_vector = value:value+1;
                fou = 0;
                for we=park_temp(s)+1:50
                    if(~fou && lane(side,we) == -1 && lane(side,we+1)==-1)
                        fou=1;
                        temp_idx=we:we+1;
                    end
                end
                if(cond1 & find(park_temp == park_temp(s)+1,1))
                    s = s + 1;
                end
            %Park_flags for cars    
            else
                search_space = 1;
                flag_vector = park_temp(s);
                temp_idx = find(lane(side,park_temp(s)+1:end) == -1,search_space)+park_temp(s);
            end
            [~,g]=size(temp_idx);
            if(g ~= 0)
                park_flags(side-1,temp_idx) =  flag_vector;%Reserving spot for the particular car
            end
            temp(side,temp_idx) = 7;
            lane(side,temp_idx) = 7;
            s = s + 1;
        end
    end
    
    %Increase time steps for each car parked
    idx_dur = find(lane(d+1,:) == 0);
    steps_parked(1,idx_dur) = steps_parked(1,idx_dur)+1;
    idx_dur = find(lane(d+2,:) == 0);
    steps_parked(2,idx_dur) = steps_parked(2,idx_dur)+1;