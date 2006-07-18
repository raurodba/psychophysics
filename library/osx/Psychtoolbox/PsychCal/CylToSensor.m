function sensor = CylToSensor(cal,cyl)
% sensor = CylToSensor(cal,cyl)
%
% Convert from sensor to cylindrical coordinates.
% We use the conventions of the CIE Lxx color spaces
% for angle
%
% 10/17/93    dhb   Wrote it by converting CAP C code.
% 2/20/94     jms   Added single argument case to allow avoiding cData
% 4/5/02      dhb, ly  Change name.

if (nargin==1)
  cyl=cal;
end

sensor(1,:) = cyl(1,:);
sensor(2,:) = cyl(2,:) .* cos( cyl(3,:) );
sensor(3,:) = cyl(2,:) .* sin( cyl(3,:) );