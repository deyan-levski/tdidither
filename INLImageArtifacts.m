%% A short function aiming to give a rough overview of INL and column
%% mismatch effects on images in a column-parallel data acquisition case.
%%
%% Usage: see the comments below
%%
%% Initial version P1A - 24/01/2013 - Deyan Dimitrov
%%

clc;
clear all;

% Create a uniformly distributed random INL (probably not the best model, since uniform distribution is not the case in reality)

a = 0;
b = 64; % Input INL in 2*(+-LSB)
r = 0;

r = a + (b-a).*rand(1,255)-b/2;

figure(1);
plot(r);
title('Random uniform INL distribution.');
xlabel('Code');
ylabel('Dev in LSB');
axis([0 255 -15 15]);
grid on;

img = imread('testcat.bmp'); % Input image (must be 8 bit grayscale bitmap + 640x480 - else code editing is required)

imgdoub = double(img);

res_img = zeros(480,640);

for z = 1:480
for k = 1:640
    pixval = imgdoub(z,k);
    res_img(z,k) = r(pixval) + pixval;
end
end

res_img = uint8(res_img);

figure(2); % Display image processed through INL
imshow(res_img);
hold on;

% Create random column variations

c = 0;
d = 32;  % Input Column Mismatch in 2*(+-LSBs)
r_pix_pixffset = zeros(480,640);

r_pix_pixffset(1,:) = c + (d-c).*rand(1,640)-d/2;

for v = 2:480
   r_pix_pixffset(v,:) = r_pix_pixffset(v,:) + r_pix_pixffset(1,:);
end


res_mm_img = zeros(480,640);
res_mm_img = imgdoub + r_pix_pixffset;

res_mm_img = uint8(res_mm_img);

figure(3); % Display image with column variations
imshow(res_mm_img);
hold on;
