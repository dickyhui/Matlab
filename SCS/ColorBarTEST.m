function [ output_args ] = ColorBarTEST( input_args )
clc;clear all;
load data.txt;

row=zeros(1,13);
column=zeros(21,1);
data1=[row;data column];
%��0ֵ���⴦��
data1(data1==0)=nan;
[X,Y]=meshgrid(0:1:12, 0:1:21); 
Z=flipud(data1);
h=pcolor(X,Y,Z);
%caxis controls the mapping of data values to the colormap
%caxis([0,60]);
%ɫ��λ��
colorbar('EastOutside');
%����ɫ�����췽ʽ
colormap(jet(128));
%���ñ߿����ɫ
set(h,'EdgeColor','white')
end

