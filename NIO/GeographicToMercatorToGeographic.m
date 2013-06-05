function [ L_matrix,B_matrix ] = GeographicToMercatorToGeographic( L_range,B_range )
%  L_range为WGS84经度范围
%  B_range为WGS84纬度范围
%  L_range,B_range都是一维矢量
%  L_matrix为与L_range经度范围相同的mercator等经度转换到WGS84中的经度坐标
%  B_matrix为与B_range纬度范围相同的mercator等纬度转换到WGS84中的纬度坐标
%  L_matrix,B_matrix为二维矩阵，矩阵的值分布与地理坐标一一对应
%  MFILE:   GeographicToMercatorToGeographic.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-12

% mercator经过转换的等分的xy坐标范围
X_range = GeographicToMercator_X(L_range);
Y_range = GeographicToMercator_Y(B_range);
% wgs84从mercator等分xy坐标范围转换过来的经纬度坐标范围
Lx_range = MercatorToGeographic_L(X_range);
By_range = MercatorToGeographic_B(Y_range);
% 构造插值运算需要输入的经纬度矩阵参数
[L_matrix B_matrix] = meshgrid(Lx_range,By_range);
end

function [ output_args ] = MercatorToGeographic_L( input_args )
%从墨卡托到WGS84 经度
num1 = input_args / 6378137.0;
num2 = num1 * 57.295779513082323;
num3 = floor((num2 + 180.0) / 360.0);
output_args = num2 - (num3 * 360.0);
end
function [ output_args ] = MercatorToGeographic_B( input_args )
%从墨卡托到WGS84 纬度
output_args = (1.5707963267948966 - (2.0 * atan(exp((-1.0 * input_args) / 6378137.0))))*57.295779513082323;
end
function [ output_args ] = GeographicToMercator_X( input_args )
%从WGS84到mercator转换 经度 取第一点和最后一点，中间等分
firstL = 6378137.0 * input_args(1)/57.29577951;
lastL = 6378137.0 * input_args(end)/57.29577951;
output_args = linspace(firstL,lastL,size(input_args,2));
end
function [ output_args ] = GeographicToMercator_Y( input_args )
%从WGS84到mercator转换 纬度 取第一点和最后一点，中间等分
firstR = 6378137.0 * log( tan((180.0/4.0+input_args(1)/2.0)*pi/180.0 ));
lastR = 6378137.0 * log( tan((180.0/4.0+input_args(end)/2.0)*pi/180.0 ));
output_args = linspace(firstR,lastR,size(input_args,2));
end