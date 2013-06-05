function [ output_args ] = DATtoImage( importFile,outputDir,timeInterval )
%  ��ȡDAT��ʽ��ֵԤ����Ʒ����������ת�����ڲ壬�������ͼƬ
%  importFileΪ�����ļ�
%  outputDirΪ����ļ���
%  output_args����1Ϊ�������У�0Ϊ����
%  ��ͼ���ݸ�ʽ��
%  �˸ߣ�Wave_��Ʒ_ʱ��_ʱ��
%  Wave_HS_0_20121121
%  �˸�7����ֵ����ɫͼ��Wave_��Ʒ_ʱ��_ʱ��
%  Wave_HSContour_0_20121121
%  ����Wave_��Ʒ_ʱ��_ʱ��_����
%  Wave_DIR_0_20121121_L3
%  MFILE:   DATtoImage.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-13

%% main init
% importFile = 'E:\win7workspace\SCS\ϵͳ����\20121201\target\fstdata\dirjinhai620130121.dat';%hsjinhai620130121%dirjinhai620130121
% outputDir = 'E:\win7workspace\SCS\ϵͳ����\20121201\target\fstdata\';
% timeInterval = 12;

global Dimensions L_range B_range L_matrix B_matrix Time_interval VectorPicSize yesterday outputDirectory
% ����ά�ȵĴ�С ���ȣ�γ�ȣ�ʱ��
Dimensions = [751,1201,121];
%ʸ��ͼ�γ�ͼ��С�������㣩
VectorPicSize = [143,259];
% ����ͼ���ʱ����������Դ����6Сʱ���������Ҫ��6�ı���
Time_interval = timeInterval;
% ��ȡ�ļ����е����ڣ�����
[~, name, ~] = fileparts(importFile);
yesterday=name(end-7:end);
if(outputDir(end)~='\')
    outputDir(end+1)='\';
end
outputDirectory=outputDir;
% wgs84��ʼ�ĵȷֵľ�γ�����귶Χ
L_range = linspace(105,130,Dimensions(1));
B_range = linspace(45,5,Dimensions(2));
% �����ֵ������Ҫ����ľ�γ�Ⱦ������
[L_matrix B_matrix] = GeographicToMercatorToGeographic(L_range,B_range);
%% main do
try
    % �жϴ�����ļ�����
    if(size(strfind(name,'hsjinhai'),1) == 1)
        output_args = HStoImage(importFile);
    elseif(size(strfind(name,'dirjinhai'),1) == 1)
        output_args = DIRtoImage(importFile);
    end
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
end

%% HStoImage
% HS�ļ�����ͼƬ���˸���ɫͼ
function [ output_args ] = HStoImage( input_args )
global Dimensions Time_interval yesterday outputDirectory
try
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    SetImageLayout();
    %fid = fopen(input_args, 'r');% ���ļ�
    dat = load(input_args);% ���ļ�
    docNode=com.mathworks.xml.XMLUtils.createDocument('MaxMinValue');%����xml����¼��ɫͼ�������Сֵ
    docRootNode = docNode.getDocumentElement;%��ȡxml���ڵ�
    docRootNode.setAttribute('date',yesterday);%����ʱ������
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);
    %��ʼ����ͼƬ
    i=0;
    while i<Dimensions(3)
        %ec=fscanf(fid,'%f',[1201,inf]); % ��ȡ����
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        name=['Wave_HS_',num2str(i), '_',yesterday];
        [maxValue,minValue]=DrawHS(ec,[outputDirectory,yesterday,'\',name, '.png']);
        %DrawHS(ec,[outputDirectory,yesterday,'\',name, '.png']);
        
        newSlide=docNode.createElement(name);%�½�newSlide�ڵ�
        newSlide.setAttribute('Max',sprintf('%f',maxValue));%����Max����
        newSlide.setAttribute('Min',sprintf('%f',minValue));%����Min����
        docRootNode.appendChild(newSlide);%��newSlide����docRootNode��ĩβ
        
        i=i+Time_interval;
        clear ec;
    end
    output_args = 1;
    xmlwrite([outputDirectory,'wave.xml'],docNode);%����xml
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
clear dat;
end

%% DIRtoImage
% DIR�ļ����������ͷ
function [ output_args ] = DIRtoImage( input_args )
global Dimensions Time_interval VectorPicSize yesterday outputDirectory
try
    %����ȫ�ֵ�ͼƬ����ĸ�ʽ
    SetImageLayout();
    %fid = fopen(input_args, 'r');% ���ļ�
    dat = load(input_args);% ���ļ�
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hold off;
    set(gcf,'paperposition',[0 0 VectorPicSize(1)/get(0,'ScreenPixelsPerInch') VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    %��ʼ����ͼƬ
    i=0;
    while i<Dimensions(3)
        %ec=fscanf(fid,'%f',[1201,inf]); % ��ȡ����
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        DrawDIR(ec,[outputDirectory,yesterday,'\Wave_DIR_',num2str(i),'_',yesterday , '_L3.png'],100);
        i=i+Time_interval;
        clear ec;
    end
    set(gcf,'paperposition',[0 0 2*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 2*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    %��ʼ����ͼƬ
    i=0;
    while i<Dimensions(3)
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        DrawDIR(ec,[outputDirectory,yesterday,'\Wave_DIR_',num2str(i) ,'_',yesterday , '_L4.png'],50);
        i=i+Time_interval;
        clear ec;
    end
     set(gcf,'paperposition',[0 0 4*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 4*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    %��ʼ����ͼƬ
    i=0;
    while i<Dimensions(3)
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        DrawDIR(ec,[outputDirectory,yesterday,'\Wave_DIR_',num2str(i) ,'_',yesterday , '_L5.png'],25);
        i=i+Time_interval;
        clear ec;
    end
    set(gcf,'paperposition',[0 0 8*VectorPicSize(1)/get(0,'ScreenPixelsPerInch') 8*VectorPicSize(2)/get(0,'ScreenPixelsPerInch')]);
    %��ʼ����ͼƬ
    i=0;
    while i<Dimensions(3)
        %ec=fscanf(fid,'%f',[1201,inf]); % ��ȡ����
        row=(Dimensions(2)*i/6+1):(Dimensions(2)*(i/6+1));
        ec=dat(row,:);
        DrawDIR(ec,[outputDirectory,yesterday,'\Wave_DIR_',num2str(i) ,'_',yesterday , '_L6.png'],15);
        i=i+Time_interval;
        clear ec;
    end
    output_args = 1;
catch ME
    output_args = strcat(ME.identifier,'*',ME.message);
end
clear dat;
end

%% DrawHS
%����ɫͼ
function [maxValue,minValue] = DrawHS( eci,name )
global B_range L_range B_matrix L_matrix
hold off;
%eci=flipud(eci');% ������ʱ����ת90��
eci(eci(:,:)==-9)=nan;% ��-9999��Ϊnan
% �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
% imagesc �����ͼ��ĸ�����Ԫ��λ������������ֵ��λ��һһ��Ӧ
% L_range,B_range��eci��L_matrix,B_matrix����ֵ��λ��ͳһ�����ﶼ���ó�����������λ��һ��
% �����eci������ת
eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
maxValue=max(max(eci));%���ֵ
minValue=min(min(eci));%��Сֵ
h=imagesc(eci);% ��ͼ
% eci=flipud(eci);
% [~,h]=contourf(eci(1:end,1:end),[0 0.5 1 1.5 2 2.5 3 3.5 100],'LineColor','blue');
% ch=get(h,'children');
% set(ch(1),'FaceColor','yellow','FaceAlpha',1);
% set(ch(2),'FaceColor','yellow','FaceAlpha',1);
% set(ch(3),'FaceColor','yellow','FaceAlpha',1);
% set(ch(4),'FaceColor','yellow','FaceAlpha',1);
% set(ch(5),'FaceColor','yellow','FaceAlpha',1);
% set(ch(6),'FaceColor','yellow','FaceAlpha',1);
% set(ch(7),'FaceColor','yellow','FaceAlpha',1);
% set(ch(8),'FaceColor','yellow','FaceAlpha',1);

set(h,'alphadata',~isnan(eci));%��nanֵ��Ϊ��ɫ��Ĭ��Ϊ��ɫ��
SaveImage(name);%����ͼƬ
clear eci;
end

%% DrawDIR
%�������ͷ��intervalΪ�����ļ��
function [] = DrawDIR( ec,name,interval )
global B_range L_range B_matrix L_matrix
hold off;
ec(ec(:,:)==-999)=nan;% ��-999��Ϊnan
% �����ڲ� ԭʼ����ec����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
ec=interp2(L_range,B_range,ec,L_matrix,B_matrix,'linear');
ec=flipud(ec(1:interval:end,1:interval:end));
dx=cos(ec*pi/180);
dy=sin(ec*pi/180);
h=quiver(dx,dy,'color','k'); %���ɼ�ͷ
set(h,'autoscalefactor',0.5,'Marker','none','MaxHeadSize',0.8);
set(gca,'XLim',[1 size(ec,2)],'YLim',[1 size(ec,1)]);%�������귶Χ
% for i=1:size(ec,1)
%     for j=1:size(ec,2)
%      if (isnan(ec(i,j)))
%         continue;
%      else
%         h=quiver(j,i,-sin(ec(i,j)),-cos(ec(i,j)));
%         hold on
%     end
%     end
% end
%set(h,'autoscalefactor',0.5,'Marker','none','color','b');
SaveImage(name);%����ͼƬ
clear ec ecx ecy;
end

%% SaveImage
%����ͼƬ,input_argsΪͼ����
function [  ] = SaveImage( input_args )
global outputDirectory yesterday
axis off;% �ر�������
%delete('img\default.png');
dpi=get(0,'ScreenPixelsPerInch');
print(gcf,'-dpng',['-r',num2str(dpi)],[outputDirectory,yesterday,'\default.png']);% ���ͼƬ
%saveas(gcf,'img\default.png','png');
img = imread([outputDirectory,yesterday,'\default.png']);% ��ȡͼƬ
siz=size(img);
alpha=ones(siz(1),siz(2));
alpha((img(:,:,1)==255)&(img(:,:,2)==255)&(img(:,:,3)==255))=0;% ��ɫ��Ϊ͸��
imwrite(img,input_args,'alpha',alpha);% �����͸��������ͼƬ
end

%% SetImageLayout
%����ȫ�ֵ�ͼƬ����ĸ�ʽ
function [  ] = SetImageLayout(  )
global Dimensions outputDirectory yesterday
%set(gcf,'visible','off');%����ʾfigure
% ͼ��ȥ�������׿� axes��figure�е���߽磬�±߽磬��ȣ��߶�
set(gca,'position',[0 0 1 1] );
% ����ɫ�������ᱳ������Ϊ͸��
%set(gcf,'color','nan');
%set(gca,'color','nan');
%set(gcf,'InvertHardCopy','off');
% ����gcf���ڵĴ�СΪDimensions��print��saveas���ͼƬ�Ĵ�СҪ����dpi����print��dpi��Ϊ��Ļdpi��
%   paperposition�ĳ��Ϳ���ΪDimensions����Ļdpi��������ӡ�����Ĵ�СΪDimensions��С
%   Position�Ĵ�С�Ǵ��ڵĴ�С��paperposition��С�����ͼ��Ĵ�С
%set(gcf,'Units','pixels','Position',[0 0 Dimensions(1) Dimensions(2)]);
set(gcf,'visible','off');
set(gcf,'Units','pixels','Position',[0 0 250 250]);
set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);%get(0,'ScreenPixelsPerInch')

%set(gcf,'PaperPosition',[0 0 Dimensions(1) Dimensions(2)]*4);
%����ɫ�����췽ʽ
colormap(jet(256));
if(exist([outputDirectory,yesterday],'dir')~=7)
    mkdir([outputDirectory,yesterday]);% �ڵ�ǰ�ļ������½�img�ļ��У�����Ѵ��ڻ�warning����Ӱ������
end
end