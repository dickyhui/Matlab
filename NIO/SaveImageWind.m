function [  ] = SaveImageWind( fullPath )
global OutputDirectory Date Time_Start
%  ����ͼƬ
%  fullPath:��ͼ��ͼ��·���������ļ�����
%  OutputDirectory����ͼ��Ŀ���ļ���
%  Date:����ʱ��
%  MFILE:   SaveImage.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE: 

axis off;% �ر�������
%delete('img\default.png');
dpi=get(0,'ScreenPixelsPerInch');
print(gcf,'-dpng',['-r',num2str(dpi)],[OutputDirectory,Date,'\default_',num2str(Time_Start),'.png']);% ���ͼƬ
%saveas(gcf,'img\default.png','png');
img = imread([OutputDirectory,Date,'\default_',num2str(Time_Start),'.png']);% ��ȡͼƬ
siz=size(img);
alpha=ones(siz(1),siz(2));
alpha((img(:,:,1)==255)&(img(:,:,2)==255)&(img(:,:,3)==255))=0;% ��ɫ��Ϊ͸��
imwrite(img,fullPath,'alpha',alpha);% �����͸��������ͼƬ
end