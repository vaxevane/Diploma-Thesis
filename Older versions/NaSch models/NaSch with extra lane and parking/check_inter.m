function [left_is_red,top_is_red,lane,count_red_top,count_red_left] = check_inter(lane,top_is_red,left_is_red,count_red_top,count_red_left)
if(top_is_red)
    count_red_top = count_red_top+1;
elseif(left_is_red)
    count_red_left = count_red_left+1;
end

left_press = sum(lane(1,1:intersection(1)-1)>=0); 
top_press = sum(lane(2,1:intersection(2)-1)>=0);
%max_red
if(count_red_top>=max_red)
    left_is_red = 1;
    top_is_red = 0;
    lane(1,intersection(1)) = 6; %creating obstacle for cars 
    lane(2,intersection(2)) = -1; %free pass for the other lane
    count_red_top = 0;
elseif(count_red_left>=max_red)
    top_is_red = 1;
    left_is_red = 0;
    lane(2,intersection(2)) = 6;
    lane(1,intersection(1)) = -1; 
    count_red_left = 0;
else%max_pressure
    if(top_press>thr_press)
        left_is_red = 1;
        top_is_red = 0;
        lane(1,intersection(1)) = 6; %creating obstacle for cars 
        lane(2,intersection(2)) = -1; %free pass for the other lane
        count_red_top = 0;
    elseif(left_press>thr_press)
        top_is_red = 1;
        left_is_red = 0;
        lane(2,intersection(2)) = 6;
        lane(1,intersection(1)) = -1; 
        count_red_left = 0;
    else
        if(left_press>top_press)
            top_is_red = 1;
            left_is_red = 0;
            lane(2,intersection(2)) = 6; %creating obstacle for cars
            lane(1,intersection(1)) = -1; %free pass for the other lane
            count_red_left = 0;
        elseif(top_press>left_press)
            left_is_red = 1;
            top_is_red = 0;
            lane(1,intersection(1)) = 6; %creating obstacle for cars 
            lane(2,intersection(2)) = -1; %free pass for the other lane
            count_red_top = 0;
        end    
    end
end