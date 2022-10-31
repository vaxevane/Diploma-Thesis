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
%road (1,: )= [-1 3 -1 -1 -1 5 -1 -1 -1 -1 -1 2 -1 -1 0 2 5 -1 -1 -1 -1 -1
%4 -1 -1 -1 -1 -1 -1 -1 0 0 0 -1 -1 -1 -1 5 -1 3 -1 -1 -1 -1 -1 2 -1 -1 -1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];
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
        acc = road(i-1,j);
        if(acc>=0)
            csp = acc;
            %Rule 1#
            if((csp==0)|(road(i-1,j+1:j+csp)==-1))
                road(i,j+csp) = csp;
                index = csp;
%                 pause(0.2)
%                 drawnow;
%                 imagesc(road(:,1:50));
%                 colormap(mymap); axis equal;
                if(road(i-1,j+1:j+csp+1)==-1)
                    if(csp<5)
                        road(i,j+csp) = csp+1;
                        index = csp;%check
%                         pause(0.2)
%                         drawnow;
%                         imagesc(road(:,1:50));
%                         colormap(mymap); axis equal;
                    end
                end
            end
            %Rule 2#
            
            if(sum(road(i-1,j+1:j+csp))>=-1*csp)
                nearest = 0;
                count = 0;%check it
                for k=j+1:j+csp
                    if((~nearest) && road(i-1,k)>=0)
                        nearest = 1;
                        if (count-1<0)
                            road(i,j+count) = 0;
                            index = count;
%                             pause(0.2)
%                             drawnow;
%                             imagesc(road(:,1:50));
%                             colormap(mymap); axis equal;
                        else
                            road(i,j+count) = count-1;
                            index = count;
%                             pause(0.2)
%                             drawnow;
%                             imagesc(road(:,1:50));
%                             colormap(mymap); axis equal;
                        end
                    end
                    count = count + 1;
                end
            end
        end
    end
    for j=c-6:-1:1            
        %Rule3#
        rand_dec = road(i,j);
        if(rand_dec>0 && rand_dec<=4)
            if ((road(i,1) ~= -1) && (randi([0 1],1,1)))
                road(i,j) = rand_dec-1;
            end
        end
    end
    
end

imagesc(road(:,1:50));
colormap(mymap); axis equal;
colorbar