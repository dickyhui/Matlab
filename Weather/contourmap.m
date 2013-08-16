function [  ] = contourmap(  )
try
    importFile = 'E:\win7workspace\Weather\weather_forecast_nc\ecfine.I2013032512.000.F2013032512.nc';
    varname='t';
    %hold off
    %axesm eckert4; framem; gridm; axis off; tightmap

    figure
    subplot(2,2,1);
    drawcontourwithmap(importFile,varname,'1');
    subplot(2,2,2);
    drawcontourwithmap(importFile,varname,'2');
    subplot(2,2,3);
    drawcontourwithmap(importFile,varname,'3');
    subplot(2,2,4);
    drawcontourwithmap(importFile,varname,'4');
    
    %saveas(gcf,'default.png');
catch e
    e.message;
end

function [  ] = drawcontourwithmap(importFile,varname,maptitle)
    lon=ncread(importFile,'lon');
    lat=ncread(importFile,'lat');

    land = shaperead('bou2_4l', 'UseGeoCoords', true);%读取shp省界线
    %worldmap(double([min(min(lat)) max(max(lat))]),double([min(min(lon)) max(max(lon))]))%纬度经度范围显示
    %worldmap([-60 60],[60 150]);
    %worldmap([20 40],[110 130]);%添加底图边框（默认的大地坐标）
    %worldmap([25 35],[115 125]);
    axesm('miller','MapLatLimit',[25 35],'MapLonLimit',[115 125],...
        'Frame','on','Grid','on','MeridianLabel','on', ...
        'ParallelLabel','on','MLabelParallel','south');
    framem;tightmap;
    setm(gca,'MLabelLocation',5,'PLabelLocation',5);
    %setm(gca,'position',[0 0 0.9 0.9]);
    
    %设置参考投影与显示区域
    %axesm('eqdcylin','MapLatLimit',[25 35],'MapLonLimit',[115 125],'frame','on','grid','on','MeridianLabel','on','ParallelLabel','on');
    
    %设置数据在地图上的显示位置
    %[cells/degree northern_latitude_limit western_longitude_limit]
    geoidrefvec=double([4,min(min(lon)),max(max(lat))]);
    ec=ncread(importFile,varname);
    eci = flipud(ec(:,:,1)')-flipud(ec(:,:,2)');
    [c,h]=contourfm(eci, geoidrefvec,-120:5:100, 'k');%在地图上画二维填色等值线
    h=clabelm(c,h);
    set(h,'backgroundcolor','none');
    blueredcolormapfile=load('blueredcolormap.mat');%读取自定义色图
    blueredcolormap = blueredcolormapfile.bluered;
    colormap(blueredcolormap);
    caxis([-100,100]);%设置颜色的拉伸范围
    
    %geoshow(land);
    mapshow(land);%显示省界线
    title(maptitle);
    contourcbar%显示色标
    
end

end

