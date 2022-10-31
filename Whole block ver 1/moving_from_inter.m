function [vert_lane,hor_lane,vert_park_signals,hor_park_signals,vert_park_flags,hor_park_flags,delay_signal] = moving_from_inter(left_is_red,top_is_red,vert_lane,hor_lane,vert_park_signals,hor_park_signals,vert_park_flags,hor_park_flags,intersection)
%if car is at the center of the intersection move it +1
delay_signal = 0;
    if(left_is_red && vert_lane(1,intersection(1)+1)==-1)
        vert_lane(1,intersection(1)+1) = vert_lane(1,intersection(1));%if car stayed at the 
        vert_lane(1,intersection(1)) = -1;
        vert_park_signals(1,intersection(1)+1) = vert_park_signals(1,intersection(1));
        vert_park_signals(1,intersection(1)) = 0;
        vert_park_flags(find(vert_park_flags==intersection(1))) = intersection(1)+1;
    elseif(left_is_red && vert_lane(1,intersection(1)+1)~=-1 &&vert_lane(1,intersection(1)+2)~=-1)
        delay_signal = -1;
    end
    if(top_is_red && hor_lane(1,intersection(2)+1)==-1)
        hor_lane(1,intersection(2)+1) = hor_lane(1,intersection(2));%if car stayed at the 
        hor_lane(1,intersection(2)) = -1;
        hor_park_signals(1,intersection(2)+1) = hor_park_signals(1,intersection(2));
        hor_park_signals(1,intersection(2)) = 0;
        hor_park_flags(find(hor_park_flags==intersection(2))) = intersection(2)+1;
    elseif(top_is_red && hor_lane(1,intersection(2)+1)~=-1 && hor_lane(1,intersection(2)+2)~=-1)
        delay_signal = 1;
    end   