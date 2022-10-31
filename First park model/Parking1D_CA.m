clear;
clc;
 mymap = [1 1 1
    1 0 0
    0 1 0
    0 0 1
    0 0 0];
parslots = zeros(1,20);%initialize parking spots
road = zeros(1,20);%initialize road
indexr = randsample(20,10)';%random car positions on the road
indexp = randsample(20,8)';%parking spots taken by cars
road(indexr) = randi([1 3],1,10);%random speed of the moving cars
parslots(indexp) = 4;%val of parked cars (4 cause it's displayed as black)
parslots(20) = 4;
matrix(1,:) = parslots;
matrix(2,:) = road;

imagesc(matrix);
colormap(mymap);axis off; axis equal;

for i=1:20
    
    leavingpark = zeros(1,19);
    
    if (road(20) > 0)%end of road
        road(20) = 0;
    end
    
    if ((road(1) == 0) && (randi([0 1],1,1)))%new cars
        road(1) = 1;
    end
    for j=19:-1:1
        if (parslots(j) == 4)%checking for parked cars
            leavingpark(j) = randi([0 1],1,1);
        end
        
        if ((leavingpark(j) == 1) && (road(j) == 0))
            road(j) = 1;%leave parking if there are no cars
            parslots(j) = 0;%freed up slot
        end 
        matrix(1,:) = parslots;
        pause(0.1)
        drawnow;
        imagesc(matrix);
        colormap(mymap);axis off; axis equal;
        
        if (road(j)==1) && (randi([0 1],1,1) && (parslots(j) ~=4))%if the car want to park
            road(j) = 0;
            parslots(j) = 4;
        end
        matrix(2,:) = road;
        pause(0.1)
        drawnow;
        imagesc(matrix);
        colormap(mymap);axis off; axis equal;
        
        if (road(j) == 1)%moving cars with slow speed(1)
            road(j) = 0;%reset prev pos
            if (road(j+1) == 0)
                road(j+1) = 2;%accelerating 
            else 
                road(j+1) = 1;%moving with the same speed
            end
        end 
        matrix(2,:) = road;
        pause(0.2)
        drawnow;
        imagesc(matrix);
        colormap(mymap);axis off; axis equal;
        
        if (road(j) == 2)
            road(j) = 0;%reset prev pos
            if((j<18) && (road(j+1) == 0) && (road(j+2) == 0) && road(j+3) == 0)
                road(j+2) = 3;%accelerating (max. speed 3)
            elseif((j<19) && (road(j+1) == 0) &&(road(j+2) == 0)) 
                road(j+2) = 2;%moving with the same speed
            elseif((j<19) && road(j+2) > 0)
                road(j+1) = 1;%decreasing speed (slow at 1) bec cant move 2 blocks
            end
        end
        matrix(2,:) = road;
        pause(0.2)
        drawnow;
        imagesc(matrix);
        colormap(mymap);axis off; axis equal;
        
        if (road(j) == 3)
            road(j) = 0;%reset prev pos
            if((j<18) && (road(j+1) == 0) && (road(j+2) == 0) && (road(j+3) == 0))
                road(j+3) = 3;%move with the same speed
            elseif((j<18) && (road(j+1) == 0) && (road(j+2) == 0) && (road(j+3) > 0))
                road(j+2) = 1;%decrease speed 
            elseif((j<19) && (road(j+1) == 0) && (road(j+2) > 0))
                road(j+1) = 1;%decrease speed 
            end
        end
        matrix(2,:) = road;
        pause(0.2)
        drawnow;
        imagesc(matrix);
        colormap(mymap);axis off; axis equal;
        
    end
end