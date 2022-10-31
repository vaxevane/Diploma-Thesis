function draw(road,intersection,intersection2,intersection3,intersection4)
[row,col] = size(road);
black = imread('images/black.bmp');
white = imread('images/white.bmp');
red = imread('images/red.bmp');
green = imread('images/green.bmp');
cyan = imread('images/cyan.bmp');
blue = imread('images/blue.bmp');
purple = imread('images/purple.bmp');
pavement = imread('images/pavement2.bmp');
roadd = imread('images/road2.bmp');
flag = imread('images/flag2.bmp');
down_flash = imread('images/flashingdown2.bmp');
up_flash = imread('images/flashingup2.bmp');
green_light = imread('images/greenlight.bmp');
red_light = imread('images/redlight.bmp');

for i=1:row
    for j=1:col
        in1 = i~=intersection(1);
        in2 = i~=intersection2(1);
        in3 = i~=intersection3(1);
        in4 = i~=intersection4(1);
        vert1 = (j == intersection(2) || (j == intersection(2)-1 && in1 && in3) || (j == intersection(2)+1 && in1 && in3));
        vert2 = (j == intersection2(2) || (j == intersection2(2)-1 && in2 && in4) || (j == intersection2(2)+1 && in2 && in4));
        
        if(road(i,j)==-2)
            out(28*i-27:28*i,28*j-27:28*j,:) = pavement;
        elseif(road(i,j)==-1)
            out(28*i-27:28*i,28*j-27:28*j,:) = roadd;           
        elseif(road(i,j)==0)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(black,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = black;
            end            
        elseif(road(i,j)==1)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(red,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = red;
            end 
        elseif(road(i,j)==2)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(green,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = green;
            end 
        elseif(road(i,j)==3)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(cyan,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = cyan;
            end 
        elseif(road(i,j)==4)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(blue,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = blue;
            end 
        elseif(road(i,j)==5)
            if(vert1 || vert2)
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(purple,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = purple;
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
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(white,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = white;
            end 
        elseif(road(i,j)==10)
            out(28*i-27:28*i,28*j-27:28*j,:) = red_light;
        elseif(road(i,j)==11)
            out(28*i-27:28*i,28*j-27:28*j,:) = green_light;
        end
    end
end
%subplot(4,4,e); 
figure
imshow(uint8(out));
% title('Single Lane Two Parking Sides')
% xlabel('\leftarrowSpace\rightarrow') 
% ylabel('\leftarrowTime\rightarrow') 
end