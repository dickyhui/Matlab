function [] = DrawContour( eci,fullPath,vector )
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
eci=double(eci);
eci(eci(:,:)==MaskValue)=nan;% ��MaskValue��Ϊnan
% �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');

[C,h] = contour(flipud(eci),vector,'b');% ��ͼ
clabel(C,h);
%set(text_handle,'BackgroundColor',[1 1 .6],'Edgecolor',[.7 .7 .7]);
SaveImage(fullPath);%����ͼƬ
clear eci;
end
