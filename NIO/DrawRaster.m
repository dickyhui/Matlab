function [maxValue,minValue] = DrawRaster( eci,fullPath )
global L_range B_range L_matrix B_matrix MaskValue
%  ����ɫͼ
%  eci����������
%  fullPath:��ͼ��ͼ��·���������ļ�����
%  L_range��WGS84���ȷ�Χ
%  B_range;WGS84γ�ȷ�Χ
%  L_matrix:��L_range���ȷ�Χ��ͬ��mercator�Ⱦ���ת����WGS84�еľ�������
%  B_matrix:��B_rangeγ�ȷ�Χ��ͬ��mercator��γ��ת����WGS84�е�γ������
%  MaskValue:ȱʡֵ
%  MFILE:   DrawRaster.m
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
% imagesc �����ͼ��ĸ�����Ԫ��λ������������ֵ��λ��һһ��Ӧ
% L_range,B_range��eci��L_matrix,B_matrix����ֵ��λ��ͳһ�����ﶼ���ó�����������λ��һ��
% �����eci������ת
eci=interp2(L_range,B_range,eci,L_matrix,B_matrix,'linear');
maxValue=max(max(eci));%���ֵ
minValue=min(min(eci));%��Сֵ
h=imagesc(eci);% ��ͼ
set(h,'alphadata',~isnan(eci));%��nanֵ��Ϊ��ɫ��Ĭ��Ϊ��ɫ��
SaveImage(fullPath);%����ͼƬ
clear eci;
end
