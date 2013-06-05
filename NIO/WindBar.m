function [] = WindBar(lon,lat,u,v,northOrsouth,varargin)
%  lon与lat为经纬度(或xy坐标)矩阵
%  uv为风的水平分量与竖直分量，0度角(u>0&v=0)为正北方向
%  MFILE:   WindBar.m
%  MATLAB:  7.8.0 (R2009a)
%  VERSION: 1.3 (28 November 2011)
%  AUTHOR:  Nick Siler
%  CONTACT: siler@atmos.washington.edu
%  MODIFY:  LinXianhui
%  DATE:    2012-12-22

%Argument tests (from quiverm.m)
if any([ndims(lat) ndims(lon) ...
        ndims(u)   ndims(v)  ] > 2)
    error(['map:' mfilename ':inputContainsPages'], ...
        'Input data can not contain pages.')

elseif length(lat) == 1 && size(lat,1) ~= size(u,1)
    error(['map:' mfilename ':invalidLat'], ...
        'Lat vector input must have row dimension of u.')

elseif length(lon) == 1 && size(lon,1) ~= size(u,2)
    error(['map:' mfilename ':invalidLon'], ...
        'Lon vector input must have column dimension of u.')

elseif ~isequal(size(lat),size(lon),size(u),size(v))
    error(['map:' mfilename ':inconsistentDims'], ...
        'Inconsistent dimensions for inputs.')
end

%check for scale and wind barb property specification
wbproperties = '''color'',''k'''; %default wind barb color is black.
switch length(varargin)
    case 1
        if ischar(varargin{1})
            error(['map:' mfilename ':invalidScale'], ...
            'Invalid scale factor.')
        end
        scale  = varargin{1};
        
    case 0
        scale  = .9;
        
    otherwise
        %for an odd number of arguments, the first will be the scale factor
        if rem(length(varargin),2)==1 
            if ischar(varargin{1})
                error(['map:' mfilename ':invalidScale'], ...
                'Invalid scale factor.')
            end
            scale  = varargin{1};
            nn = 2;
        else
            % for an even number of arguments, no scale factor is specified
            scale = .9;
            nn = 1;
        end
        for ii = nn:length(varargin)
            if ischar(varargin{ii})
                wbproperties = [wbproperties,',''',varargin{ii},''''];
            else
                wbproperties = [wbproperties,',',num2str(varargin{ii})];
            end                    
        end
end

umag = sqrt(u.^2+v.^2); %wind speed
scale = .6;
%find theta; add pi to atan(v/u) when u<0
%u=-u;%为了让其关于y轴对称
dummy = (u<0)*pi;
theta = atan(v./u)+dummy;%顺时针旋转角度 0角度为正北

[a,b] = size(umag);

%判断风的等级
g0 = true(a,b);% 主轴
g1 = umag < 3;%一级风
g2 = (umag >= 3 & umag < 17);%二级风（四级风五级风六级风七级风八级风）
g3 = (umag >= 5 & umag < 7);%三级风
g4 = (umag >= 7 & umag < 17);%四级风（六级风七级风八级风）
g5 = (umag >= 9 & umag < 11);%五级风
g6 = (umag >= 11 & umag < 17);%六级风（八级风）
g7 = (umag >= 13 & umag < 15);%七级风
g8 = (umag >= 15 & umag < 17);%八级风
g9 = umag >= 17;%九级及以上第一条线
g10 = umag >= 17;%九级及以上第二条线


%与风的等级相对于画线
c0 = [0 0;0 1];
c1 = [0 0.75;0.25 0.75].*[1 1;northOrsouth 1];
c2 = [0 1;0.5 1].*[1 1 ;northOrsouth 1];
c3 = [0 0.85;0.25 0.85].*[1 1 ;northOrsouth 1];
c4 = [0 0.85;0.5 0.85].*[1 1 ;northOrsouth 1];
c5 = [0 0.7;0.25 0.7].*[1 1 ;northOrsouth 1];
c6 = [0 0.7;0.5 0.7].*[1 1;northOrsouth 1];
c7 = [0 0.55;0.25 0.55].*[1 1; northOrsouth 1];
c8 = [0 0.55;0.5 0.55].*[1 1;northOrsouth 1];
c9 = [0 1;0.25 0.75].*[1 1; northOrsouth 1];
c10 = [0.25 0.75;0 0.5].*[northOrsouth 1; 1 1];

%set scale based on average latitude spacing
[m,n]=size(lat);
scale2 = scale*(max(max(lon))-min(min(lon)))/n;

%draw the barbs
for nn = 0:10
    eval(['dummy = reshape(g',int2str(nn),',1,a*b);']);
    count = sum(dummy); % number of barbs to draw
    if count == 0
        continue
    end
    
    %rotation operations顺时针旋转theta角度
    eval(['x1 = c',int2str(nn),'(1,1)*cos(theta)+c',int2str(nn),...
        '(1,2)*sin(theta);']);
    eval(['y1 = -c',int2str(nn),'(1,1)*sin(theta)+c',int2str(nn),...
        '(1,2)*cos(theta);']);
    eval(['x2 = c',int2str(nn),'(2,1)*cos(theta)+c',int2str(nn),...
        '(2,2)*sin(theta);']);
    eval(['y2 = -c',int2str(nn),'(2,1)*sin(theta)+c',int2str(nn),...
        '(2,2)*cos(theta);']);
    x1 = x1*scale2+lon;
    x2 = x2*scale2+lon;
    %multiply y1 and y2 by cos(lat) to compensate for the closer spacing of
    %meridians.原先的.*cos(lat*pi/180)会使每个风向标大小不一
%     y1 = y1*scale2.*cos(lat*pi/180)+lat;
%     y2 = y2*scale2.*cos(lat*pi/180)+lat;
    y1 = y1*scale2+lat;
    y2 = y2*scale2+lat;
    x = [reshape(x1(dummy),1,count);reshape(x2(dummy),1,count)];
    y = [reshape(y1(dummy),1,count);reshape(y2(dummy),1,count)];
    %eval(['linem(y,x,',wbproperties,')']);
    eval(['plot(x,y,',wbproperties,')']);
    hold on;
end