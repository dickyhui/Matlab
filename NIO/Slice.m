function [ output_args ] = Slice(  importFile,outputDir,press, temp, salt )

try
    % 获取文件名
    [A, name, B] = fileparts(importFile);
    name = name(2:end);
    if(outputDir(end)~='\')
        outputDir(end+1)='\';
    end
    %% PT剖面图
    plot(temp,press);
    hold on;
    plot(temp,press,'.r','MarkerSize',10)
    %图形的坐标在左上角
    axis ij;
    axis([ min(temp) max(temp) min(press) max(press)]);
    xlabel('Temperature(℃)');
    ylabel('Pressure(dbar)');
    title('PT剖面图');
    sFileFullName=[outputDir,name,'_PT.png'];
    set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 600/150 450/150]);
    saveas(gcf,sFileFullName,'png');
    close all;

    %% PS剖面图  
    plot(salt,press);
    hold on;
    plot(salt,press,'.r','MarkerSize',10)
    axis ij;
    axis([ min(salt) max(salt) min(press) max(press)]);
    xlabel('Salinity(PPS-78)');
    ylabel('Pressure(dbar)');
    title('PS剖面图');
    sFileFullName=[outputDir,name,'_PS.png'];
    set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 600/150 450/150]);
    saveas(gcf,sFileFullName,'png');
    close all;
  
    %% TS剖面图  
    plot(salt,temp);
    hold on;
    plot(salt,temp,'.r','MarkerSize',10)
    axis([ min(salt) max(salt) min(temp) max(temp)]);
    xlabel('Salinity(PPS-78)');
    ylabel('Temperature(℃)');
    title('TS剖面图');
    sFileFullName=[outputDir,name,'_TS.png'];
    set(gcf,'PaperPositionMode','manual','paperunits','inches','paperposition',[0 0 600/150 450/150]);
    saveas(gcf,sFileFullName,'png');
    close all;
  
    output_args = 1;

catch ME
    output_args = strcat(ME.stack.line,'*',ME.identifier,'*',ME.message);
end

end



