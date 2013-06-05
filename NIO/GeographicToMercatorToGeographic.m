function [ L_matrix,B_matrix ] = GeographicToMercatorToGeographic( L_range,B_range )
%  L_rangeΪWGS84���ȷ�Χ
%  B_rangeΪWGS84γ�ȷ�Χ
%  L_range,B_range����һάʸ��
%  L_matrixΪ��L_range���ȷ�Χ��ͬ��mercator�Ⱦ���ת����WGS84�еľ�������
%  B_matrixΪ��B_rangeγ�ȷ�Χ��ͬ��mercator��γ��ת����WGS84�е�γ������
%  L_matrix,B_matrixΪ��ά���󣬾����ֵ�ֲ����������һһ��Ӧ
%  MFILE:   GeographicToMercatorToGeographic.m
%  MATLAB:  7.8.0 (R2009a)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  DATE:    2013-01-12

% mercator����ת���ĵȷֵ�xy���귶Χ
X_range = GeographicToMercator_X(L_range);
Y_range = GeographicToMercator_Y(B_range);
% wgs84��mercator�ȷ�xy���귶Χת�������ľ�γ�����귶Χ
Lx_range = MercatorToGeographic_L(X_range);
By_range = MercatorToGeographic_B(Y_range);
% �����ֵ������Ҫ����ľ�γ�Ⱦ������
[L_matrix B_matrix] = meshgrid(Lx_range,By_range);
end

function [ output_args ] = MercatorToGeographic_L( input_args )
%��ī���е�WGS84 ����
num1 = input_args / 6378137.0;
num2 = num1 * 57.295779513082323;
num3 = floor((num2 + 180.0) / 360.0);
output_args = num2 - (num3 * 360.0);
end
function [ output_args ] = MercatorToGeographic_B( input_args )
%��ī���е�WGS84 γ��
output_args = (1.5707963267948966 - (2.0 * atan(exp((-1.0 * input_args) / 6378137.0))))*57.295779513082323;
end
function [ output_args ] = GeographicToMercator_X( input_args )
%��WGS84��mercatorת�� ���� ȡ��һ������һ�㣬�м�ȷ�
firstL = 6378137.0 * input_args(1)/57.29577951;
lastL = 6378137.0 * input_args(end)/57.29577951;
output_args = linspace(firstL,lastL,size(input_args,2));
end
function [ output_args ] = GeographicToMercator_Y( input_args )
%��WGS84��mercatorת�� γ�� ȡ��һ������һ�㣬�м�ȷ�
firstR = 6378137.0 * log( tan((180.0/4.0+input_args(1)/2.0)*pi/180.0 ));
lastR = 6378137.0 * log( tan((180.0/4.0+input_args(end)/2.0)*pi/180.0 ));
output_args = linspace(firstR,lastR,size(input_args,2));
end