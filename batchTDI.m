close all;

file = 'tubes.jpg';

ResHor = 640;
ResVer = 480;

N = 8; % Number of TDI stages

litOffset = 1; % Reference image brightness tuning scaler coefficient (to reflect TDI accumulation)
ConvResN = 2; % Data converter (quantized) resolution in bits
VRefHi = 1; % Reference voltage
subtractiveDither = 0;
digDitN = 3;
nTh = 0.000624;
dtCoeff = 0.5;

gauss = 0;
plotDither = 0;
plotImgHist = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%figure;
%title('Original 2D image');
%imshow(file);

tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist);

subtractiveDither = 1;
tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist)

N = 16;
subtractiveDither = 0;
tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist)

N = 16;
subtractiveDither = 1;
tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist)


N = 64;
subtractiveDither = 0;
tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist)

N = 64;
subtractiveDither = 1;
tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist)


N = 128;
subtractiveDither = 0;
tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist)

N = 128;
subtractiveDither = 1;
tdiDitherP1C(file, ResHor, ResVer, N, litOffset, ConvResN, VRefHi, subtractiveDither, digDitN, nTh, dtCoeff, gauss, plotDither, plotImgHist)
