function [ ] = DrawUVContour(ncid,variables,dimLon,dimLat,levels,times)
global Time_interval Date OutputDirectory DataType Time_Start L_range B_range L_matrix B_matrix  MaskValue
%  生成NetCDF的风向标
%  ncid：NetCDF的ID
%  variables:风向标的数据参数
%  start:nc文件数据的起点位置
%  count:向后计数 二维为经度和纬度，三维加层数或时间
%  levels:该参数数据的层数
%  times:该参数数据的时间数
%  piclevels：生成图片的级别（3,4,5,6）
%  picinterval：根据图片的不同级别设置数据间隔（32,16,8,4）
%  Time_interval：数据时间间隔
%  Level_interval：数据层数间隔
%  Date：数据时间
%  OutputDirectory：输出文件夹路径
%  VectorPicSize：输出图片大小，大小对应于piclevels的最小级别的图片
%  DataType:数据类型（Wind/Wave/..）
%  MFILE:   NetCDFtoImageWindBar.m
%  MATLAB:  7.13.0.564 (R2011b)
%  VERSION: 1.0 (2013-3-27)
%  AUTHOR:  LinXianhui
%  CONTACT: linxianhui_zju@163.com
%  MODIFY:
%  DATE:
colormap(jet(256));
variable=variables;
vidU=netcdf.inqVarID(ncid,variable{1}); % 获取U变量名的ID
vidV=netcdf.inqVarID(ncid,variable{2}); % 获取V变量名的ID
if(levels==1&&times~=1)   %三维，经度纬度时间
    levelist(1) = 0;
else
    levelval = netcdf.getAtt(ncid,vidU, 'level_hpa');
    m = 1;
    for n=1:length(levelval)
        if(levelval(n) == 850 || levelval(n) == 500 || levelval(n) == 200)
            levelist(m) = n-1;
            m = m + 1;
        end
    end
end
i=0;j=Time_Start;p=0;
for i = levelist
    while j<times
        fullPath = [OutputDirectory,Date,'\',DataType,'-', variable{1},variable{2},'Contour-',num2str(j) ,'-',num2str(p) ,'-',Date , '.png'];%出图的图层路径（包括文件名）
        
        if(levels==1&&times~=1)   %三维，经度纬度时间
            ecU=netcdf.getVar(ncid,vidU,[0,0,j],[dimLon,dimLat,1]); % 读取U变量
            ecV=netcdf.getVar(ncid,vidV,[0,0,j],[dimLon,dimLat,1]); % 读取V变量
            ecU=flipud(ecU(:,:,1)');
            ecV=flipud(ecV(:,:,1)');
        elseif(levels~=1&&times==1)%三维，经度纬度层数
            ecU=netcdf.getVar(ncid,vidU,[0,0,i],[dimLon,dimLat,1]); % 读取U变量
            ecV=netcdf.getVar(ncid,vidV,[0,0,i],[dimLon,dimLat,1]); % 读取V变量
            ecU=flipud(ecU(:,:,1)');
            ecV=flipud(ecV(:,:,1)');
        else
            ecU=netcdf.getVar(ncid,vidU,[0,0,i,j],[dimLon,dimLat,1,1]); % 读取U变量
            ecV=netcdf.getVar(ncid,vidV,[0,0,i,j],[dimLon,dimLat,1,1]); % 读取V变量
            ecU=flipud(ecU(:,:,1,1)');
            ecV=flipud(ecV(:,:,1,1)');
        end
        
        ecU(ecU(:,:)==MaskValue)=nan;% 将MaskValue设为nan
        ecV(ecV(:,:)==MaskValue)=nan;% 将MaskValue设为nan
        % 矩阵内插 原始矩阵ec1的列为L_range，行为B_range，输出列矩阵L_matrix与行矩阵B_matrix构成的坐标矩阵的值
        ecU=interp2(L_range,B_range,ecU,L_matrix,B_matrix,'linear');
        ecV=interp2(L_range,B_range,ecV,L_matrix,B_matrix,'linear');
        
        eci=sqrt(ecU.^2+ecV.^2);
        %画蓝色六级风(11)
        %         [~,h]=contourf(eci(1:end,1:end),[11 11],'LineColor','blue');
        %         ch=get(h,'children');
        %         for k=ch
        %             set(k,'FaceColor','blue','FaceAlpha',1);
        %         end
        %         %画黄色七级风(13)
        %         hold on;
        %         [~,h2]=contourf(eci(1:end,1:end),[13 13],'LineColor','yellow');
        %         ch2=get(h2,'children');
        %         for k2=ch2
        %             set(k2,'FaceColor','yellow','FaceAlpha',1);
        %         end
        minValue=min(min(eci));%最小值
        %eci(isnan(eci))=minValue;% 把nan值设为最小值
        h=imagesc(eci);% 画图
        set(h,'alphadata',~isnan(eci));%将nan值设为白色（默认为蓝色）
        SaveImageWind(fullPath);%保存图片
        
        j=j+Time_interval;
    end
    j = Time_Start;
    p = p + 1;
end
clear ecU ecV eci;
end

