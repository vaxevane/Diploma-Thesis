function draw(road,intersection,intersection2,intersection3,intersection4,tp,hor_ID,vert_ID,hor2_ID,vert2_ID)
[row,col] = size(road);
black_car = imread('images/car/black.bmp');
white_car = imread('images/car/white.bmp');
red_car = imread('images/car/red.bmp');
green_car = imread('images/car/green.bmp');
cyan_car = imread('images/car/cyan.bmp');
blue_car = imread('images/car/blue.bmp');
purple_car = imread('images/car/purple.bmp');
bblack_truck = imread('images/truck/truck back black.bmp');
bwhite_truck = imread('images/truck/truck back white.bmp');
bred_truck = imread('images/truck/truck back red.bmp');
bgreen_truck = imread('images/truck/truck back green.bmp');
bcyan_truck = imread('images/truck/truck back cyan.bmp');
fblack_truck = imread('images/truck/truck front black.bmp');
fwhite_truck = imread('images/truck/truck front white.bmp');
fred_truck = imread('images/truck/truck front red.bmp');
fgreen_truck = imread('images/truck/truck front green.bmp');
fcyan_truck = imread('images/truck/truck front cyan.bmp');
pavement = imread('images/pavement2.bmp');
roadd = imread('images/road2.bmp');
flag = imread('images/flag2.bmp');
down_flash = imread('images/flashingdown2.bmp');
up_flash = imread('images/flashingup2.bmp');
green_light = imread('images/greenlight.bmp');
red_light = imread('images/redlight.bmp');

road_ID = zeros(row,col);
road_ID(intersection(1):intersection(1)+1,:) = hor_ID(1:2,:);
road_ID(intersection(1)-1,:) = hor_ID(3,:);
road_ID(intersection3(1):intersection3(1)+1,:) = hor2_ID(1:2,:);
road_ID(intersection3(1)-1,:) = hor2_ID(3,:);
road_ID(:,intersection(2)) = vert_ID(1,:)';
road_ID(:,intersection(2)-1) = vert_ID(2,:)';
road_ID(:,intersection(2)+1) = vert_ID(3,:)';
road_ID(:,intersection4(2)) = vert2_ID(1,:)';
road_ID(:,intersection4(2)-1) = vert2_ID(2,:)';
road_ID(:,intersection4(2)+1) = vert2_ID(3,:)';

road_ID(intersection(1),intersection(2)-1) = hor_ID(1,intersection(2)-1);
road_ID(intersection(1),intersection(2)+1) = hor_ID(1,intersection(2)+1);
road_ID(intersection2(1),intersection2(2)-1) = hor_ID(1,intersection2(2)-1);
road_ID(intersection2(1),intersection2(2)+1) = hor_ID(1,intersection2(2)+1);
road_ID(intersection3(1),intersection3(2)-1) = hor2_ID(1,intersection3(2)-1);
road_ID(intersection3(1),intersection3(2)+1) = hor2_ID(1,intersection3(2)+1);
road_ID(intersection4(1),intersection4(2)-1) = hor2_ID(1,intersection4(2)-1);
road_ID(intersection4(1),intersection4(2)+1) = hor2_ID(1,intersection4(2)+1);


if tp(1);road_ID(intersection(1),intersection(2)) =hor_ID(1,intersection(2));else, road_ID(intersection(1),intersection(2)) =vert_ID(1,intersection(1)); end
if tp(2);road_ID(intersection2(1),intersection2(2)) =hor_ID(1,intersection2(2));else, road_ID(intersection2(1),intersection2(2)) =vert2_ID(1,intersection2(1)); end
if tp(3);road_ID(intersection3(1),intersection3(2)) =hor2_ID(1,intersection3(2));else, road_ID(intersection3(1),intersection3(2)) =vert_ID(1,intersection3(1)); end
if tp(4);road_ID(intersection4(1),intersection4(2)) =hor2_ID(1,intersection4(2));else, road_ID(intersection4(1),intersection4(2)) =vert2_ID(1,intersection4(1)); end
% road_ID
for i=1:row
    j = 1;
    while (j<=col)     
        %logical conditions
        ID = road_ID(i,j);
        if (j<col)
            front = (ID ~= 0 && ID == road_ID(i,j+1));
        end
        if (i<row)
            bellow = (ID ~= 0 && ID == road_ID(i+1,j));
        end       
        tp1 = ~(tp(1) && i == intersection(1) && j == intersection(2));
        tp2 = ~(tp(2) && i == intersection2(1) && j == intersection2(2));
        tp3 = ~(tp(3) && i == intersection3(1) && j == intersection3(2));
        tp4 = ~(tp(4) && i == intersection4(1) && j == intersection4(2));
        in1 = i~=intersection(1);
        in2 = i~=intersection2(1);
        in3 = i~=intersection3(1);
        in4 = i~=intersection4(1);
        vert1 = (j == intersection(2) || (j == intersection(2)-1 && in1 && in3) || (j == intersection(2)+1 && in1 && in3));
        vert2 = (j == intersection2(2) || (j == intersection2(2)-1 && in2 && in4) || (j == intersection2(2)+1 && in2 && in4));
        if(i>1 && i<row && j>1 && j<col)
            flashfront = (road(i+1,j) == 6 && road(i+1,j+1) == 6 && road_ID(i+1,j) == road_ID(i+1,j+1)) || (road(i-1,j) == 8 && road(i-1,j+1) == 8 && road_ID(i-1,j) == road_ID(i-1,j+1));
            flashbellow = (road(i,j-1) == 6 && road(i+1,j-1) == 6 && road_ID(i,j-1) == road_ID(i+1,j-1)) || (road(i,j+1) == 8 && road(i+1,j+1) == 8 && road_ID(i,j+1) == road_ID(i+1,j+1));
        else
            flashfront = 0;
            flashbellow = 0;
        end
        if(road(i,j)==-2)
            out(28*i-27:28*i,28*j-27:28*j,:) = pavement;
        elseif(road(i,j)==-1)
            out(28*i-27:28*i,28*j-27:28*j,:) = roadd;           
        elseif(road(i,j)==0)
            if((vert1 || vert2) && tp1 && tp2 && tp3 && tp4)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(black_car,-90,'bilinear','crop');
                if(bellow || flashbellow)
                    out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(bblack_truck,-90,'bilinear','crop');
                    out(28*(i+1)-27:28*(i+1),28*j-27:28*j,:) = imrotate(fblack_truck,-90,'bilinear','crop');
                    road(i+1,j) = 100;
                end
            else
                if(front || flashfront)
                    out(28*i-27:28*i,28*j-27:28*j,:) = bblack_truck;
                    j = j + 1;
                    out(28*i-27:28*i,28*j-27:28*j,:) = fblack_truck;
                else
                    out(28*i-27:28*i,28*j-27:28*j,:) = black_car;
                end
            end            
        elseif(road(i,j)==1)
            if((vert1 || vert2) && tp1 && tp2 && tp3 && tp4)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(red_car,-90,'bilinear','crop');
                if(bellow || flashbellow)
                    out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(bred_truck,-90,'bilinear','crop');                    
                    out(28*(i+1)-27:28*(i+1),28*j-27:28*j,:) = imrotate(fred_truck,-90,'bilinear','crop');
                    road(i+1,j) = 100;
                end
            else
                if(front || flashfront)
                    out(28*i-27:28*i,28*j-27:28*j,:) = bred_truck;
                    j = j + 1;
                    out(28*i-27:28*i,28*j-27:28*j,:) = fred_truck;
                else
                    out(28*i-27:28*i,28*j-27:28*j,:) = red_car;
                end
            end 
        elseif(road(i,j)==2)
            if((vert1 || vert2) && tp1 && tp2 && tp3 && tp4)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(green_car,-90,'bilinear','crop');
                if(bellow || flashbellow)
                    out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(bgreen_truck,-90,'bilinear','crop');
                    out(28*(i+1)-27:28*(i+1),28*j-27:28*j,:) = imrotate(fgreen_truck,-90,'bilinear','crop');
                    road(i+1,j) = 100;
                end
            else
                if(front || flashfront)
                    out(28*i-27:28*i,28*j-27:28*j,:) = bgreen_truck;
                    j = j + 1;
                    out(28*i-27:28*i,28*j-27:28*j,:) = fgreen_truck;
                else
                    out(28*i-27:28*i,28*j-27:28*j,:) = green_car;
                end
            end 
        elseif(road(i,j)==3)
            if((vert1 || vert2) && tp1 && tp2 && tp3 && tp4)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(cyan_car,-90,'bilinear','crop');
                if(bellow || flashbellow)
                    out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(bcyan_truck,-90,'bilinear','crop');
                    out(28*(i+1)-27:28*(i+1),28*j-27:28*j,:) = imrotate(fcyan_truck,-90,'bilinear','crop');
                    road(i+1,j) = 100;
                end
            else
                if(front || flashfront)
                    out(28*i-27:28*i,28*j-27:28*j,:) = bcyan_truck;
                    j = j + 1;
                    out(28*i-27:28*i,28*j-27:28*j,:) = fcyan_truck;
                else
                    out(28*i-27:28*i,28*j-27:28*j,:) = cyan_car;
                end
            end 
        elseif(road(i,j)==4)
            if((vert1 || vert2) && tp1 && tp2 && tp3 && tp4)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(blue_car,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = blue_car;
            end 
        elseif(road(i,j)==5)
            if((vert1 || vert2) && tp1 && tp2 && tp3 && tp4)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(purple_car,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = purple_car;
            end 
        elseif(road(i,j)==6)
            if(vert1 || vert2) 
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(down_flash,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = down_flash;
            end    
        elseif(road(i,j)==7)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(flag,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = flag;
            end    
        elseif(road(i,j)==8)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(up_flash,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = up_flash;
            end 
        elseif(road(i,j)==9)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(white_car,-90,'bilinear','crop');
                if(bellow || flashbellow)
                    out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(bwhite_truck,-90,'bilinear','crop');
                    out(28*(i+1)-27:28*(i+1),28*j-27:28*j,:) = imrotate(fwhite_truck,-90,'bilinear','crop');
                    road(i+1,j) = 100;
                end
            else
                if(front || flashfront)
                    out(28*i-27:28*i,28*j-27:28*j,:) = bwhite_truck;
                    j = j + 1;
                    out(28*i-27:28*i,28*j-27:28*j,:) = fwhite_truck;
                else
                    out(28*i-27:28*i,28*j-27:28*j,:) = white_car;
                end
            end 
        elseif(road(i,j)==10)
            out(28*i-27:28*i,28*j-27:28*j,:) = red_light;
        elseif(road(i,j)==11)
            out(28*i-27:28*i,28*j-27:28*j,:) = green_light;
        end
        j = j +1;
    end
end
%subplot(4,4,e); 
figure
imshow(uint8(out));
% title('Single Lane Two Parking Sides')
% xlabel('\leftarrowSpace\rightarrow') 
% ylabel('\leftarrowTime\rightarrow') 
end