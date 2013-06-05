function [  ] = SaveImageWind( fullPath )
global OutputDirectory Date Time_Start
%  保存图片
%  fullPath:出图的图层路径（包括文件名）
%  OutputDirectory：出图的目标文件夹
%  Date:数据时间
%  MFILE:   SaveImage.m
%  MATLAB:  7.13.0.564 (R2011b)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-03-20
%  MODIFY:  
%  DATE: 

axis off;% 关闭坐标轴
%delete('img\default.png');
dpi=get(0,'ScreenPixelsPerInch');
print(gcf,'-dpng',['-r',num2str(dpi)],[OutputDirectory,Date,'\default_',num2str(Time_Start),'.png']);% 输出图片
%saveas(gcf,'img\default.png','png');
img = imread([OutputDirectory,Date,'\default_',num2str(Time_Start),'.png']);% 读取图片
siz=size(img);
alpha=ones(siz(1),siz(2));
alpha((img(:,:,1)==255)&(img(:,:,2)==255)&(img(:,:,3)==255))=0;% 白色设为透明
imwrite(img,fullPath,'alpha',alpha);% 输出有透明背景的图片
end