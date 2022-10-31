function [full_road,count_red_top,count_red_left] = copying_roads(full_road,hor_temp,hor2_temp,vert_temp,vert2_temp,intersection,intersection2,intersection3,intersection4,count_red_top,count_red_left,top_is_red,left_is_red)
    
    full_road(intersection(1)-1,:) = hor_temp(3,:);
    full_road(intersection(1),:) = hor_temp(1,:);
    full_road(intersection(1)+1,:) = hor_temp(2,:);
    full_road(intersection3(1)-1,:) = hor2_temp(3,:);
    full_road(intersection3(1),:) = hor2_temp(1,:);
    full_road(intersection3(1)+1,:) = hor2_temp(2,:);
    full_road(:,intersection(2)+1) = vert_temp(3,:)';
    full_road(:,intersection(2)) = vert_temp(1,:)';
    full_road(:,intersection(2)-1) = vert_temp(2,:)';
    full_road(:,intersection2(2)+1) = vert2_temp(3,:)';
    full_road(:,intersection2(2)) = vert2_temp(1,:)';
    full_road(:,intersection2(2)-1) = vert2_temp(2,:)';
    
    full_road(intersection(1),intersection(2)-1) = hor_temp(1,intersection(2)-1);
    full_road(intersection(1),intersection(2)+1) = hor_temp(1,intersection(2)+1);
    full_road(intersection2(1),intersection2(2)-1) = hor_temp(1,intersection2(2)-1);
    full_road(intersection2(1),intersection2(2)+1) = hor_temp(1,intersection2(2)+1);
    full_road(intersection3(1),intersection3(2)-1) = hor2_temp(1,intersection3(2)-1);
    full_road(intersection3(1),intersection3(2)+1) = hor2_temp(1,intersection3(2)+1);
    full_road(intersection4(1),intersection4(2)-1) = hor2_temp(1,intersection4(2)-1);
    full_road(intersection4(1),intersection4(2)+1) = hor2_temp(1,intersection4(2)+1);
    
    if top_is_red(1), full_road(intersection(1),intersection(2)) = hor_temp(1,intersection(2));else, full_road(intersection(1),intersection(2)) = vert_temp(1,intersection(1));end
    if top_is_red(2), full_road(intersection2(1),intersection2(2)) = hor_temp(1,intersection2(2));else, full_road(intersection2(1),intersection2(2)) = vert2_temp(1,intersection2(1));end
    if top_is_red(3), full_road(intersection3(1),intersection3(2)) = hor2_temp(1,intersection3(2));else, full_road(intersection3(1),intersection3(2)) = vert_temp(1,intersection3(1));end
    if top_is_red(4), full_road(intersection4(1),intersection4(2)) = hor2_temp(1,intersection4(2));else, full_road(intersection4(1),intersection4(2)) = vert2_temp(1,intersection4(1));end
%     full_road(intersection(1),intersection(2)) = -1;
%     full_road(intersection2(1),intersection2(2)) = -1;
%     full_road(intersection3(1),intersection3(2)) = -1;
%     full_road(intersection4(1),intersection4(2)) = -1;
   
    %counting red lights and visualizing full road
    [~,s] = size(top_is_red);
    for i=1:s
        if (top_is_red(i))
            count_red_top(i) = count_red_top(i)+1;
        elseif(left_is_red(i))
            count_red_left(i) = count_red_left(i)+1;
        end
    end