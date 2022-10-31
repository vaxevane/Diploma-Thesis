clear;
clc;
 mymap = [1 1 1
     0 0 0
     1 0 0
     1 1 0
     0 1 0
     0 1 1
     0 0 1];

road = zeros(35,60);%initialize road
[r,c] = size(road);
road(:,:) = - 1;
indexr = randsample(50,15)';%random car positions on the road
road(1,indexr) = randi([0 5],1,15);%random speed of the moving cars
road (1,: )= [-1 3 -1 -1 -1 5 -1 -1 -1 -1 -1 2 -1 -1 0 2 5 -1 -1 -1 -1 -1 4 -1 -1 -1 -1 -1 -1 -1 0 0 0 -1 -1 -1 -1 5 -1 3 -1 -1 -1 -1 -1 2 -1 -1 -1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];
for i=2:r
    index=0;
    if ((road(i,1) == -1) && (randi([0 1],1,1)))%new cars
        road(i,1) = 1;
        pause(0.2)
        drawnow;
        imagesc(road(:,1:50));
        colormap(mymap); axis equal;
    end
    for j=c-6:-1:1
        moved = 0;
        acc = road(i-1,j);
        if(acc>=0)
            %Rule 1#
            if((acc==0)|(road(i,j+1:j+acc)==-1))
                road(i,j+acc) = acc;
                index = j+acc;
                pause(0.2)
                drawnow;
                imagesc(road(:,1:50));
                colormap(mymap); axis equal;
                if(road(i,j+1:j+acc+1)==-1)
                    if(acc<5)
                        road(i,j+acc) = acc+1;
                        index = j+acc;%check
                        pause(0.2)
                        drawnow;
                        imagesc(road(:,1:50));
                        colormap(mymap); axis equal;
                    end
                end
            end
            %Rule 2#
            csp = road(i-1,j);
            if(sum(road(i,j+1:csp))>=-1*csp)
                nearest = 0;
                count = 0;%check it
                for k=j+1:j+csp
                    if((~nearest) && road(i,k)>=0)
                        nearest = 1;
                        if (count-1<0)
                            road(i,j+index) = 0;
                            index = j+count;
                            pause(0.2)
                            drawnow;
                            imagesc(road(:,1:50));
                            colormap(mymap); axis equal;
                        else
                            road(i,j+index) = count-1;
                            index = j+count;
                            pause(0.2)
                            drawnow;
                            imagesc(road(:,1:50));
                            colormap(mymap); axis equal;
                        end
                    end
                    count = count + 1;
                end
            end
            
        end
    end
    
    
end

imagesc(road(:,1:50));
colormap(mymap); axis equal;