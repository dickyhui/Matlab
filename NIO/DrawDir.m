function [ ] = DrawDir( fullPath,interval,varargin )
global L_range B_range L_matrix B_matrix MaskValue
%  ����ͷ
%  fullPath:��ͼ��ͼ��·���������ļ�����
%  interval�����ݼ��
%  varargin:�ɱ����ݲ�������ֻ��һ�����������޴�С�ļ�ͷ����������������������С�ļ�ͷ
%  L_range��WGS84���ȷ�Χ
%  B_range;WGS84γ�ȷ�Χ
%  L_matrix:��L_range���ȷ�Χ��ͬ��mercator�Ⱦ���ת����WGS84�еľ�������
%  B_matrix:��B_rangeγ�ȷ�Χ��ͬ��mercator��γ��ת����WGS84�е�γ������
%  MaskValue:ȱʡֵ
%  MFILE:   DrawContour.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:
%  DATE:
switch length(varargin)
    case 1  %ֻ��һ�����������޴�С�ļ�ͷ
        eci=double(varargin{1});
        eci(eci(:,:)==MaskValue)=nan;% ��-999��Ϊnan
        % �����ڲ� ԭʼ����eci����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
        eci=flipud(eci(1:interval:end,1:interval:end));
        dx=cos(eci*pi/180);
        dy=sin(eci*pi/180);
    case 2  %������������������С�ļ�ͷ
        dx=double(varargin{1});
        dy=double(varargin{2});
        dx(dx(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
        dy(dy(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
        % �����ڲ� ԭʼ����eci����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
        dx=interp2(L_range,B_range,dx,L_matrix,B_matrix,'linear');
        dy=interp2(L_range,B_range,dy,L_matrix,B_matrix,'linear');
        dx=flipud(dx(1:interval:end,1:interval:end));
        dy=flipud(dy(1:interval:end,1:interval:end));
end
hold off;
h=quiver(dx,dy,'color','k'); %���ɼ�ͷ
set(h,'autoscalefactor',0.8,'Marker','none','MaxHeadSize',0.5);
set(gca,'XLim',[1 size(dx,2)],'YLim',[1 size(dx,1)]);%�������귶Χ
SaveImage(fullPath);%����ͼƬ
clear eci dx dy;
end

