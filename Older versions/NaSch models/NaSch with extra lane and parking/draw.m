function draw(road)
[row,col] = size(road);
black = imread('black.bmp');
white = imread('white.bmp');
red = imread('red.bmp');
green = imread('green.bmp');
cyan = imread('cyan.bmp');
blue = imread('blue.bmp');
purple = imread('purple.bmp');
pavement = imread('pavement.bmp');
roadd = imread('road.bmp');
flag = imread('flag.bmp');
down_flash= imread('downflashing.bmp');
up_flash= imread('upflashing.bmp');

%out = zeros(row,col,3);
for i=1:row
    for j=1:col
        if(road(i,j)==-2)
            out(22*i-21:22*i,28*j-27:28*j,:) = pavement;
        elseif(road(i,j)==-1)
            out(22*i-21:22*i,28*j-27:28*j,:) = roadd;           
        elseif(road(i,j)==0)
            out(22*i-21:22*i,28*j-27:28*j,:) = black;
        elseif(road(i,j)==1)
            out(22*i-21:22*i,28*j-27:28*j,:) = red;
        elseif(road(i,j)==2)
            out(22*i-21:22*i,28*j-27:28*j,:) = green;
        elseif(road(i,j)==3)
            out(22*i-21:22*i,28*j-27:28*j,:) = cyan;
        elseif(road(i,j)==4)
            out(22*i-21:22*i,28*j-27:28*j,:) = blue;
        elseif(road(i,j)==5)
            out(22*i-21:22*i,28*j-27:28*j,:) = purple;
        elseif(road(i,j)==6)
            out(22*i-21:22*i,28*j-27:28*j,:) = down_flash;     
        elseif(road(i,j)==7)
            out(22*i-21:22*i,28*j-27:28*j,:) = flag;   
        elseif(road(i,j)==8)
            out(22*i-21:22*i,28*j-27:28*j,:) = up_flash;
        elseif(road(i,j)==9)
            out(22*i-21:22*i,28*j-27:28*j,:) = white;
        end
    end
end
figure
imshow(uint8(out));
title('Single Lane Two Parking Sides')
xlabel('\leftarrowSpace\rightarrow') 
ylabel('\leftarrowTime\rightarrow') 
end