function [] = DrawWindBar( ec0U,ec0V,name,interval )
global L_range B_range L_matrix B_matrix MaskValue
%  �������
%  ec0U����������ˮƽ����
%  ec0V������������ֱ����
%  fullPath:��ͼ��ͼ��·���������ļ�����
%  interval�����ݼ��
%  L_range��WGS84���ȷ�Χ
%  B_range;WGS84γ�ȷ�Χ
%  L_matrix:��L_range���ȷ�Χ��ͬ��mercator�Ⱦ���ת����WGS84�еľ�������
%  B_matrix:��B_rangeγ�ȷ�Χ��ͬ��mercator��γ��ת����WGS84�е�γ������
%  MaskValue:ȱʡֵ
%  MFILE:   DrawWindBar.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE:  

hold off;
ec0U=double(ec0U);% ������ʱ����ת90��
ec0V=double(ec0V);% ������ʱ����ת90��
ec0U(ec0U(:,:)==MaskValue)=nan;% ��-9999��Ϊnan
ec0V(ec0V(:,:)==MaskValue)=nan;% ��-9999��Ϊnan
% �����ڲ� ԭʼ����ec1����ΪL_range����ΪB_range������о���L_matrix���о���B_matrix���ɵ���������ֵ
ec0U=interp2(L_range,B_range,ec0U,L_matrix,B_matrix,'linear');
ec0V=interp2(L_range,B_range,ec0V,L_matrix,B_matrix,'linear');
[x,y]=meshgrid(1:size(L_range,2),1:size(B_range,2));%��γ�ȵķ�Χ����Ҫ�����ɵȾ������
%quiver(flipud(ec0U(1:4:end,1:4:end)),flipud(ec0V(1:4:end,1:4:end))); %���ɼ�ͷ
ec0U=flipud(ec0U);
ec0V=flipud(ec0V);
ec0U1=ec0U;
ec0U1(flipud(B_matrix)<0)=0;
ec0V1=ec0V;
ec0V1(flipud(B_matrix)<0)=0;
WindBar(x(1:interval:end,1:interval:end),y(1:interval:end,1:interval:end),...
    ec0U1(1:interval:end,1:interval:end),ec0V1(1:interval:end,1:interval:end),1)%���ɷ����
hold on
ec0U1=ec0U;
ec0U1(flipud(B_matrix)>=0)=0;
ec0V1=ec0V;
ec0V1(flipud(B_matrix)>=0)=0;
WindBar(x(1:interval:end,1:interval:end),y(1:interval:end,1:interval:end),...
    ec0U1(1:interval:end,1:interval:end),ec0V1(1:interval:end,1:interval:end),-1)%���ɷ����
set(gca,'XLim',[1 size(L_range,2)],'YLim',[1 size(B_range,2)]);%�������귶Χwindbarbm������ı����귶Χ
SaveImageWind(name);%����ͼƬ
clear ec0U ec0V;
end
