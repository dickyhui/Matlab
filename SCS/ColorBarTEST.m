function [ output_args ] = ColorBarTEST( input_args )
clc;clear all;
load data.txt;

row=zeros(1,13);
column=zeros(21,1);
data1=[row;data column];
%对0值特殊处理
data1(data1==0)=nan;
[X,Y]=meshgrid(0:1:12, 0:1:21); 
Z=flipud(data1);
h=pcolor(X,Y,Z);
%caxis controls the mapping of data values to the colormap
%caxis([0,60]);
%色带位置
colorbar('EastOutside');
%设置色带拉伸方式
colormap(jet(128));
%设置边框的颜色
set(h,'EdgeColor','white')
end

