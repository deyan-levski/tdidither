%% A short model of noise influence to TDI CMOS imaging and their effects.
%%
%% Usage: see comments below
%%
%% Initial version P1A - Basic TDI mode model 01/12/2014 - Deyan Levski
%% Version P2A - Added analog dithering 01/12/2014 - Deyan Levski
%% Version P1B - Added digital subtractive dithering 02/12/2014 - Deyan Levski
%% Version P1C - Clean up and wrap around a function - 02/12/2014 - Deyan Levski
%% Version P2C - Added some histogram plotting functionality - 08/12/2014 - Deyan Levski
%%\

%%%%% Some Global Variables %%%%%
%close all;
%clc;
%clear all;

function [] = tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist)

%ResHor = 640;
%ResVer = 480;

%N = 32; % Number of TDI stages

%litOffset = 1; % Reference image brightness tuning scaler coefficient (to reflect TDI accumulation)

%ConvResN = 2; % Data converter (quantized) resolution in bits
ConvResOS = round(ConvResN+(N^0.25)); % Effective bits from oversampling ratio calculation based on Nr of TDI stages
%VRefHi = 1; % Reference voltage

nCodes = 2^ConvResN; % Number of quantizer codes
nCodesOvsmpl = 2^ConvResOS; % Number of effective (oversampled) codes
vLSB = VRefHi/nCodes; % LSB magnitude

ntScale = nTh/(1/sqrt(2)); % Thermal ADC input referred noise in Volts RMS

dtScale = dtCoeff*vLSB; % Max analog dither magnitude 0.5LSB = 1LSB peak to peak
%subtractiveDither = 0;
%digDitN = 3; % Digital dither floating point wordlength, i.e. coarseness of digital dither subtraction

digDitCLSB = vLSB/2^digDitN;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read input image 

img = imread(file);
img = imresize(img, [ResVer ResHor]);

img = im2double(img);

imgGray = .299*img(:,:,1) + .587*img(:,:,2) + .114*img(:,:,3);  % convert to grayscale, no need for loops

%imgGray = rgb2gray(imgResizedRGB);
%imgGray = double(imgGray);

%figure(1);
%title('Original 2D image');
%imshow(imgGray);
%imtool(imgGray);

% Do TDI accumulation with random noise

imgGrayTDI = double(zeros(size(imgGray))); % Create zero image

imgGray = imgGray/litOffset; % Reduce reference image brightness (to reflect TDI accumulation)
imgGray = imgGray/(max(max(imgGray))/1); % Scale to fit 1 Volt swing (i.e. high conversion gain)

%figure(2);
%title('Offset original');
%imshow(imgGray);


ditHist = [];

for j = 1:length(imgGray(:,1)) % Foreach row

	for i = 1:N % Foreach TDI stage

		for k = 1:length(imgGray(1,:)) % Foreach column
	
			if gauss == 1 
				r = 1+(-1-1).*randn(1);
				d = 1+(-1-1).*randn(1);	
			else
				r = 1+(-1-1).*rand(1);
				d = 1+(-1-1).*rand(1);
			end

		noise = double(ntScale*r); % Generate new random uniform noise ([-1 1] x scale coefficient)
		dither = double(dtScale*d); % Generate random analog dither ([-1 1] x scale coefficient)
		
		ditHist = [ditHist dither];

		anaSigToConvert = imgGray(j,k) + noise + dither; % Inject thermal noise and analog dither

		conv = round(anaSigToConvert/vLSB); % A/D Convert with noise and dither
		
		if conv < 0 % if conv negative then saturate
		conv = 0;
		end
		
		digDitDig = 1/(round(dither/digDitCLSB)); % Digital subtractive dither, from 0 to 1 in steps of digDitN

			if digDitDig == -Inf 
			   digDitDig = -1;
			elseif digDitDig == +Inf
			   digDitDig = +1;
			end

			if subtractiveDither == 1

			convVect(i,j,k) = conv + digDitDig; % Conversion vector foreach TDI to be used for plotting and subtractive dither

			imgGrayTDI(j,k) = imgGrayTDI(j,k) + conv - digDitDig; % Digital accumulation N times with subtractive dither

			else

			convVect(i,j,k) = conv; % Conversion vector foreach TDI to be used for plotting

			imgGrayTDI(j,k) = imgGrayTDI(j,k) + conv; % Digital accumulation N times 
			
			end
		
		end

	end
end


AccCap = N*2^ConvResN; % Digital accumulator capacity

tmp = imgGrayTDI;

%imgGrayTDI = round(imgGrayTDI/(N/4)); % LP filter (average) values
imgGrayTDI = round(imgGrayTDI*(nCodesOvsmpl/(nCodes*N)));

%imgGrayTDI = round(imgGrayTDI*(nCodesOvsmpl/nCodes)); % Uncompress to OS A/D converter word

convVect = round(convVect(:,[2 3])*(nCodesOvsmpl/nCodes));

figure
subplot(1,2,1);
plot(convVect(:,1,1)); % Plot first pixel conversion vector after scaling
line([1 N],[imgGrayTDI(1,1), imgGrayTDI(1,1)], 'Color','red'); % Scale converted OS value back to non-OS nCodes
str = sprintf('Pixel conversion for each TDI stage and final averaged value, TDI = %d', N);
grid on;

title(str);


subplot(1,2,2);
imshow(imgGrayTDI, [0 nCodesOvsmpl]);
truesize;
	if subtractiveDither == 0
	str = sprintf('Analog additive dither %d LSB avg and thermal noise %d V, TDI = %d', dtCoeff, nTh, N);
	title(str);
	elseif subtractiveDither == 1
	str = sprintf('Digital subtractive dither %d LSB avg and thermal noise %d V, TDI = %d', dtCoeff, nTh, N);
	title(str);
	elseif dtCoeff == 0
	str = sprintf('No dither (%d LSB) and thermal noise %d V, TDI = %d', dtCoeff, nTh, N);
	title(str);
	end

%imtool(imgGrayTDI, [0 nCodesOvsmpl]);
	if plotDither == 1
	figure;
	hist(ditHist,150);
	title('Dither distribution');
	end

	if plotImgHist == 1
	figure;
	hist(abs(imgGrayTDI), nCodesOvsmpl);
	title('Image Histogram')
	end


end

%%%%%%%%
% JUNK %
%%%%%%%%

% imgGrayTDI1V = imgGrayTDI/(max(max(imgGrayTDI))/1); % Scale to fit max swing of 1 Volt

%figure(3);
%title('N TDI accumulated image with thermal noise')
%imshow(imgGrayTDI1V);


%conv = uint16(imgGrayTDI1V/vLSB);

%figure(3);
%imshow(conv, [0 nCodes]);


%maxAcc = max(max(imgGrayTDI));


%% Generate multiple level signals with random uniform noise
%%
%N = 32;
%sigmaScale = 0.1;
%lines = 10;
%
%for i = 1:lines
%
%tmp = i + (sigmaScale*rand(1,N));
%tdi(i,:) = tmp;
%
%end
%tdi = tdi';
%
%plot(tdi);




