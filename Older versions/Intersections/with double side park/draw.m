function draw(road,intersection,e)
[row,col] = size(road);
black = imread('black2.bmp');
white = imread('white2.bmp');
red = imread('red2.bmp');
green = imread('green2.bmp');
cyan = imread('cyan2.bmp');
blue = imread('blue2.bmp');
purple = imread('purple2.bmp');
pavement = imread('pavement2.bmp');
roadd = imread('road2.bmp');
flag = imread('flag2.bmp');
down_flash = imread('flashingdown2.bmp');
up_flash = imread('flashingup2.bmp');
green_light = imread('greenlight.bmp');
red_light = imread('redlight.bmp');

%out = zeros(row,col,3);
for i=1:row
    for j=1:col
        if(road(i,j)==-2)
            out(28*i-27:28*i,28*j-27:28*j,:) = pavement;
        elseif(road(i,j)==-1)
            out(28*i-27:28*i,28*j-27:28*j,:) = roadd;           
        elseif(road(i,j)==0)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(black,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = black;
            end            
        elseif(road(i,j)==1)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(red,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = red;
            end 
        elseif(road(i,j)==2)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(green,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = green;
            end 
        elseif(road(i,j)==3)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(cyan,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = cyan;
            end 
        elseif(road(i,j)==4)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(blue,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = blue;
            end 
        elseif(road(i,j)==5)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(purple,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = purple;
            end 
        elseif(road(i,j)==6)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(down_flash,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = down_flash;
            end    
        elseif(road(i,j)==7)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(flag,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = flag;
            end    
        elseif(road(i,j)==8)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
                out(28*i-27:28*i,28*j-27:28*j,:) = imrotate(up_flash,-90,'bilinear','crop');
            else
                out(28*i-27:28*i,28*j-27:28*j,:) = up_flash;
            end 
        elseif(road(i,j)==9)
            if(j == intersection(2) || (j == intersection(2)-1 && i~=intersection(1)) || (j == intersection(2)+1 && i~=intersection(1)))
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