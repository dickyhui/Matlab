function [ output_args ] = test( input_args )
ncid = netcdf.create('C:\Users\dicky\Desktop\temp1.nc', 'WRITE');
netcdf.close(ncid);
myVarSchema = ncinfo('C:\Users\dicky\Desktop\ecfine.I2013032512.000.F2013032512.nc','u10');
myVarSchema.Name = 'u10';
myVarSchema.Datatype = 'single';
ncwriteschema('C:\Users\dicky\Desktop\temp1.nc',myVarSchema);
peaksData   = ncread('C:\Users\dicky\Desktop\ecfine.I2013032512.000.F2013032512.nc','u10');
ncwrite('C:\Users\dicky\Desktop\temp1.nc','u10',peaksData);
info = ncinfo('C:\Users\dicky\Desktop\temp1.nc');

end

