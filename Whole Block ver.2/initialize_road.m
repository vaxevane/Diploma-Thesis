function [full_road,hor_lane,hor2_lane,vert_lane,vert2_lane,hor_steps_parked,hor2_steps_parked,vert_steps_parked,vert2_steps_parked,hor_park_signals,hor2_park_signals,vert_park_signals,vert2_park_signals,hor_park_flags,hor2_park_flags,vert_park_flags,vert2_park_flags] = initialize_road(full_road,cars1,cars2,cars3,cars4,intersection,intersection2,intersection3,intersection4,first_park,last_park)
hor_lane = -ones(1,50);
hor2_lane = -ones(1,50);
vert_lane = -ones(1,50);
vert2_lane = -ones(1,50);
[d,c] = size(hor_lane);

index_lane1 = randsample(40,cars1)';%random car positions on fast lane
index_lane2 = randsample(40,cars2)';%random car positions on slow lane
index_lane3 = randsample(40,cars3)';%random car positions on slow lane
index_lane4 = randsample(40,cars4)';%random car positions on slow lane
hor_lane(1,index_lane1) = randi([0 5],1,cars1);
hor2_lane(1,index_lane4) = randi([0 5],1,cars4);
vert_lane(1,index_lane2) = randi([0 5],1,cars2);%random speed of the moving cars
vert2_lane(1,index_lane3) = randi([0 5],1,cars3);

%Parking on horizontal lane
hor_par_slots = zeros(2,c);
hor_steps_parked = zeros(2,c);%how many time steps each car has stayed parked
hor_par_slots(1:2,:) = -2;
hor_par_slots(1,3:first_park+1) = -1;
hor_par_slots(1,intersection(2)+3:intersection(2)+15) = -1;
hor_par_slots(1,intersection2(2)+10:last_park) = -1;
hor_par_slots(2,3:first_park+1) = -1;
hor_par_slots(2,intersection(2)+3:intersection(2)+15) = -1;
hor_par_slots(2,intersection2(2)+10:last_park) = -1;
hor_lane(2,:) = hor_par_slots(1,:);
hor_lane(3,:) = hor_par_slots(2,:);
hor_park_signals = zeros(d,c);
hor_park_flags = zeros(2,c);

%Parking on horizontal lane2
hor2_par_slots = zeros(2,c);
hor2_steps_parked = zeros(2,c);%how many time steps each car has stayed parked
hor2_par_slots(1:2,:) = -2;
hor2_par_slots(1,4:first_park+1) = -1;
hor2_par_slots(1,intersection3(2)+5:intersection3(2)+12) = -1;
hor2_par_slots(1,intersection4(2)+12:last_park) = -1;
hor2_par_slots(2,4:first_park+1) = -1;
hor2_par_slots(2,intersection3(2)+5:intersection3(2)+12) = -1;
hor2_par_slots(2,intersection4(2)+12:last_park) = -1;
hor2_lane(2,:) = hor2_par_slots(1,:);
hor2_lane(3,:) = hor2_par_slots(2,:);
hor2_park_signals = zeros(d,c);
hor2_park_flags = zeros(2,c);

%Parking on vertical lane
vert_par_slots = zeros(2,c);
vert_steps_parked = zeros(2,c);%how many time steps each car has stayed parked
vert_par_slots(1:2,:) = -2;
vert_par_slots(1,3:first_park+1) = -1;
vert_par_slots(1,intersection(1)+4:intersection(1)+9) = -1;
vert_par_slots(2,3:first_park+1) = -1;
vert_par_slots(2,intersection(1)+4:intersection(1)+9) = -1;
vert_lane(2,:) = vert_par_slots(1,:);
vert_lane(3,:) = vert_par_slots(2,:);
vert_park_signals = zeros(d,c);
vert_park_flags = zeros(2,c);

%Parking on vertical lane2
vert2_par_slots = zeros(2,c);
vert2_steps_parked = zeros(2,c);%how many time steps each car has stayed parked
vert2_par_slots(1:2,:) = -2;
vert2_par_slots(1,3:first_park+1) = -1;
vert2_par_slots(1,intersection2(1)+4:intersection2(1)+9) = -1;
vert2_par_slots(2,3:first_park+1) = -1;
vert2_par_slots(2,intersection2(1)+4:intersection2(1)+9) = -1;
vert2_lane(2,:) = vert2_par_slots(1,:);
vert2_lane(3,:) = vert2_par_slots(2,:);
vert2_park_signals = zeros(d,c);
vert2_park_flags = zeros(2,c);

hor_park_signals(1,index_lane1) = (rand(1,cars1)/2)-0.2;
hor2_park_signals(1,index_lane4) = (rand(1,cars4)/2)-0.2;
vert_park_signals(1,index_lane2) = (rand(1,cars2)/2)-0.2;
vert2_park_signals(1,index_lane3) = (rand(1,cars3)/2)-0.2;

%bountaries
%hor bount
full_road(intersection(1)-2,:) = -2;
full_road(intersection(1)+2,:) = -2;

%hor2 bount
full_road(intersection3(1)-2,:) = -2;
full_road(intersection3(1)+2,:) = -2;


%vert bount
full_road(:,intersection(2)-2) = -2;
full_road(:,intersection(2)+2) = -2;

%vert2 bount
full_road(:,intersection2(2)-2) = -2;
full_road(:,intersection2(2)+2) = -2;

%light
full_road(intersection(1)+3,intersection(2)-3) = 11;
full_road(intersection(1)-3,intersection(2)+3) = 10;
full_road(intersection2(1)+3,intersection2(2)-3) = 11;
full_road(intersection2(1)-3,intersection2(2)+3) = 10;

full_road(intersection3(1)+3,intersection3(2)-3) = 11;
full_road(intersection3(1)-3,intersection3(2)+3) = 10;
full_road(intersection4(1)+3,intersection4(2)-3) = 11;
full_road(intersection4(1)-3,intersection4(2)+3) = 10;

%Copying to full_road
full_road(intersection(1)-1,:) = hor_lane(3,:);
full_road(intersection(1),:) = hor_lane(1,:);
full_road(intersection(1)+1,:) = hor_lane(2,:);
full_road(intersection3(1)-1,:) = hor2_lane(3,:);
full_road(intersection3(1),:) = hor2_lane(1,:);
full_road(intersection3(1)+1,:) = hor2_lane(2,:);
full_road(:,intersection(2)+1) = vert_lane(3,:)';
full_road(:,intersection(2)) = vert_lane(1,:)';
full_road(:,intersection(2)-1) = vert_lane(2,:)';
full_road(:,intersection2(2)+1) = vert2_lane(3,:)';
full_road(:,intersection2(2)) = vert2_lane(1,:)';
full_road(:,intersection2(2)-1) = vert2_lane(2,:)';
full_road(intersection(1),intersection(2)-1) = hor_lane(1,intersection(2)-1);
full_road(intersection(1),intersection(2)+1) = hor_lane(1,intersection(2)+1);
full_road(intersection2(1),intersection2(2)-1) = hor_lane(1,intersection2(2)-1);
full_road(intersection2(1),intersection2(2)+1) = hor_lane(1,intersection2(2)+1);
full_road(intersection3(1),intersection3(2)-1) = hor2_lane(1,intersection3(2)-1);
full_road(intersection3(1),intersection3(2)+1) = hor2_lane(1,intersection3(2)+1);
full_road(intersection4(1),intersection4(2)-1) = hor2_lane(1,intersection4(2)-1);
full_road(intersection4(1),intersection4(2)+1) = hor2_lane(1,intersection4(2)+1);

draw(full_road,intersection,intersection2,intersection3,intersection4);
%hor lane 
if (vert_lane(1,intersection(1))~=-1)
    vert_lane(1,intersection(1)) = 6;
    vert_park_signals(intersection(1)) = 0;
else
    vert_lane(1,intersection(1)) = 6;
end
if (vert2_lane(1,intersection2(1))~=-1)
    vert2_lane(1,intersection2(1)) = 6;
    vert2_park_signals(intersection2(1)) = 0;
else
    vert2_lane(1,intersection2(1)) = 6;
end
%hor2 lane 
if (vert_lane(1,intersection3(1))~=-1)
    vert_lane(1,intersection3(1)) = 6;
    vert_park_signals(intersection3(1)) = 0;
else
    vert_lane(1,intersection3(1)) = 6;
end
if (vert2_lane(1,intersection4(1))~=-1)
    vert2_lane(1,intersection4(1)) = 6;
    vert2_park_signals(intersection4(1)) = 0;
else
    vert2_lane(1,intersection4(1)) = 6;
end