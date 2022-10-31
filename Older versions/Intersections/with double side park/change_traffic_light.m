function[hor_lane,vert_lane,left_red,top_red,count_red_left,count_red_top] = change_traffic_light(vert_lane,hor_lane,max_red,thr_press,count_red_left,count_red_top,intersection)
%pressure of each approach
    left_press = sum(hor_lane(1,1:intersection(2)-1)>=0); 
    top_press = sum(vert_lane(1,1:intersection(1)-1)>=0);
    if hor_lane(1,intersection(2)) == 6, left_red = 1;top_red = 0;else, left_red = 0;top_red = 1; end
    %max_red
    if(count_red_top>=max_red)
        left_red = 1;
        top_red = 0;
        hor_lane(1,intersection(2)) = 6; %creating obstacle for cars 
        vert_lane(1,intersection(1)) = -1; %free pass for the other lane
        count_red_top = 0;
    elseif(count_red_left>=max_red)
        top_red = 1;
        left_red = 0;
        vert_lane(1,intersection(1)) = 6;
        hor_lane(1,intersection(2)) = -1; 
        count_red_left = 0;
    else%max_pressure
        if(top_press>=thr_press)
            left_red = 1;
            top_red = 0;
            hor_lane(1,intersection(2)) = 6; %creating obstacle for cars 
            vert_lane(1,intersection(1)) = -1; %free pass for the other lane
            count_red_top = 0;
        elseif(left_press>=thr_press)
            top_red = 1;
            left_red = 0;
            vert_lane(1,intersection(1)) = 6;
            hor_lane(1,intersection(2)) = -1; 
            count_red_left = 0;
        else %biggest pressusre of the 2
            if(top_press>left_press)
                left_red = 1;
                top_red = 0;
                hor_lane(1,intersection(2)) = 6;  
                vert_lane(1,intersection(1)) = -1; 
                count_red_top = 0;
            elseif(left_press>top_press)
                top_red = 1;
                left_red = 0;
                vert_lane(1,intersection(1)) = 6; 
                hor_lane(1,intersection(2)) = -1;
                count_red_left = 0;
            end    
        end
    end