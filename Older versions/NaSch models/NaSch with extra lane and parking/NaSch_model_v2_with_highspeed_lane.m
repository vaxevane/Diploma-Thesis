clear;
clc;
X = importdata('test_data.txt');
mymap = [0.6350 0.2 0 %-2
     1 1 1 %-1
     0 0 0 %0
     1 0 0 %1
     0 1 0 %2
     0 1 1 %3
     0 0 1 %4
     0.75, 0, 0.75 %5
     1 1 0];%6
max_prob_ch_hispe = 0.65;
new_car_prob = 0.6; 
dec_prob = 0.25;
full_road = zeros(61,60);
full_road(:,:) = -2;
lane(2,:) = X(:,2)';%initialize slow lane
lane(1,:) = -1;%initialize fast lane
[d,c] = size(lane);
index_lane1 = randsample(50,6)';%random car positions on fast lane
index_lane2 = randsample(50,10)';%random car positions on slow lane
lane(1,index_lane1) = randi([0 5],1,6);
%lane(2,index_lane2) = randi([0 5],1,10);%random speed of the moving cars
[iter,~] = size(full_road);
%lane = [-1 3 -1 -1 -1 5 -1 -1 -1 -1 -1 2 -1 -1 0 2 5 -1 -1 -1 -1 -1 4 -1 -1 -1 -1 -1 -1 -1 0 0 0 -1 -1 -1 -1 5 -1 3 -1 -1 -1 -1 -1 2 -1 -1 -1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];
%lane = [-1 -1 -1 4 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 5 -1 -1 -1 -1 -1 5 -1 -1 -1 -1 -1 -1 0 0 -1 1 -1 -1 -1 -1 -1 -1 -1 4 -1 -1 -1 -1 5 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];
full_road(2,:)=lane(1,:);
full_road(3,:)=lane(2,:);
full_road(iter+3,:) = -2;
signals = zeros(2,60);
drawnow;
imagesc(full_road(:,1:50));
colormap(mymap); axis equal;
colorbar
for e=4:3:iter
    signals = zeros(2,60);
    if ((lane(2,1) == -1) && (rand(1)>1-new_car_prob))%new cars
        lane(2,1) = 1;
    end
    lane(1:2,51:60) = -1;%clear cars after 50 index
    for j=c-10:-1:1
        for i=1:d
%            if((signals(i,j)==-1))
%                
%            elseif((signals(i,j)==1) && lane(1,j)==-1)
%                lane(1,j) = lane(i,j);
%                lane(i,j) = -1;
%                signals(i,j) = 0;
%            end
           moved = 0;
           speed = lane(i,j); %current speed of the car
           if(speed>=0)
              if(speed<5)
                  %Rule 1#acceleration
                  if(lane(i,j+1:j+speed+1)==-1)
                      lane(i,j) = -1;
                      lane(i,j+speed) = speed + 1;
                      next_speed = lane(i,j+speed);
                      moved = 1;
                  end   
              end

    %          pause(0.4)
    %          drawnow;
    %          imagesc(road(:,1:50));
    %          colormap(mymap); axis equal;

              if(lane(i,j+1:j+speed)==-1)
                  lane(i,j) = -1;
                  lane(i,j+speed) = speed;
                  next_speed = lane(i,j+speed);
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
                          end
                      end
                  end
              end

    %         pause(0.4)
    %         drawnow;
    %         imagesc(road(:,1:50));
    %         colormap(mymap); axis equal;
           end
        end
    end

    %Rule3#random speed decrease
    decreased = 0;
    for j=c-10:-1:1      
        for i=1:d          
            rand_dec = lane(i,j);
            if(rand_dec>0 && rand_dec<=5)
                if ((lane(i,j) ~= -1) && (rand(1)>1-dec_prob))
                    lane(i,j) = rand_dec-1;
                    decreased = 1;
                end
            end
            if (decreased)
                rand_dec = rand_dec-1;
            end
            %Signal indication for lane change
            if((rand_dec>0)   &&((rand(1)*(rand_dec/5))>1-max_prob_ch_hispe))
                signals(i,j) = 1;
             elseif((rand_dec>0)  &&(rand(1)*((6-rand_dec)/5)>1-0.55))
                 signals(i,j) = -1;
            end
        end
    end
        
    %flash
    for i=1:d
        if(i<d)
            idx_l = find(signals(i+1,:)==1);
            vac_sp_l = lane(i,idx_l)==-1;
            lane(i,idx_l(vac_sp_l)) = 6;
        end
        if(i>=2)
            idx_r = find(signals(i-1,:)==-1);
            vac_sp_r = lane(i,idx_r)==-1;
            lane(i,idx_r(vac_sp_r)) = 6;
        end
    end

    %copy lane to time diagram
    %full_road(e,:) = -2;
    full_road(e+1,:) = lane(1,:);
    full_road(e+2,:) = lane(2,:);
    
    %plot lane-time
    drawnow;
    imagesc(full_road(:,1:50));
    colormap(mymap); axis equal;
    colorbar
    for i=1:d
        if(i<d)
            lane(i,idx_l(vac_sp_l)) = lane(i+1,idx_l(vac_sp_l));
            lane(i+1,idx_l(vac_sp_l)) = -1;
            signals(i+1,idx_l(vac_sp_l)) = 0;
        end
        if(i>=2)
            lane(i,idx_r(vac_sp_r)) = lane(i-1,idx_r(vac_sp_r));
            lane(i-1,idx_r(vac_sp_r)) = -1;
            signals(i-1,idx_r(vac_sp_r)) = 0;
        end
    end
end