function [] = DrawContourf( eci,fullPath,vector)
global L_range B_range L_matrix B_matrix MaskValue
%  ����ֵ��
%  eci����������
%  fullPath:��ͼ��ͼ��·���������ļ�����
%  vector:ָ����ֵ�ߵĻ��Ƹ߶�
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

hold off;

[C,h] = contourf(flipud(eci),[-1000,vector],'k');% ��ͼ
clabel(C,h);
caxis([min(vector),max(vector)]);
%set(text_handle,'BackgroundColor',[1 1 .6],'Edgecolor',[.7 .7 .7]);
SaveImageWind(fullPath);%����ͼƬ
clear eci;
end