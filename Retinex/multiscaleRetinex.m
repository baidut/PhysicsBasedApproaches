function [OUT] = multiscaleRetinex(I, method, varargin)

if nargin == 0
    I = imread('office_1.jpg');
    J = multiscaleRetinex(I, 'MSRCR');
    ezFig I J
    return;
end

I = im2double(I).*255;

switch (method)
    case {'SSR' 'single scale retinex'}, f = @SSR;
    case {'MSR' 'multi scale retinex'}, f = @MSR;
    case 'MSRCR', f = @MSRCR;
    %case 'MSRCP', f = @MSRCP;
    otherwise
        f = str2func(method);
end

OUT = f(I, varargin{:});

end

function OUT = SSR(I, varargin)
T = imgaussfilt(I, varargin{:});
OUT = I./(T+1); % avoid NaN
end

function OUT = MSR(I, varargin)
if numel(varargin) == 0
    varargin = {25 100 240};
end
OUT = 0; N = numel(varargin);
for n = 1:N
    OUT = OUT + (1/N)*multiscaleRetinex(I,'SSR',varargin{n});
end
end

function OUT = MSRCR(I, lowScale, medScale, highScale, leftChop, rightChop)
if ~exist('lowScale', 'var'), lowScale = 15; end
if ~exist('MedScale', 'var'), medScale = 80; end
if ~exist('HighScale', 'var'), highScale = 250; end
if ~exist('s1', 'var'), leftChop = 1; end
if ~exist('s2', 'var'), rightChop = 1; end

for c = 1:3
    Ic = I(:,:,c);
    MSR = multiscaleRetinex(Ic, 'MSR', lowScale, medScale, highScale);
    CR = (log(125*Ic+1)-log(I(:,:,1)+I(:,:,2)+I(:,:,3)+1));
    OUT(:,:,c) = colorBalance(CR.*MSR./255, 'simplest', leftChop, rightChop);
end
%OUT = max(0, min(1, OUT));
end
