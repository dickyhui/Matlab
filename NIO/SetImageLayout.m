function [  ] = SetImageLayout(  )
global Dimensions OutputDirectory Date DataType
%  ����ȫ�ֵ�ͼƬ����ĸ�ʽ
%  Dimensions�����ݲ����ĸ�ά�ȵĴ�С ���ȣ�γ�ȣ�������ʱ��
%  Date������ʱ��
%  OutputDirectory������ļ���·��
%  MFILE:   NetCDFtoImage_Wind.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE:

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
set(gcf,'visible','off');
set(gcf,'Units','pixels','Position',[0 0 Dimensions(1) Dimensions(2)]);
set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 Dimensions(1)/get(0,'ScreenPixelsPerInch') Dimensions(2)/get(0,'ScreenPixelsPerInch')]);

%set(gcf,'PaperPosition',[0 0 Dimensions(1) Dimensions(2)]*4);
%����ɫ�����췽ʽ
colormap(jet(256));
if(exist([OutputDirectory,Date],'dir')~=7)
    mkdir([OutputDirectory,Date]);% �ڵ�ǰ�ļ������½�img�ļ��У�����Ѵ��ڻ�warning����Ӱ������
end
end

