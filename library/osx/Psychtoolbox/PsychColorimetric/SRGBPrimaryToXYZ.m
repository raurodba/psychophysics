function XYZ = SRGBPrimaryToXYZ(rgb)
% XYZ = SRGBPrimaryToXYZ(rgb)
%
% Convert between sRGB primaries and CIE XYZ.
% The rgb are linear device
% coordinates for the primaries of the sRGB
% standard.  One would expect these to be in
% the range 0-1, although any scaling will simply
% propogate through to the XYZ coordinates.
%
% Conversion matrix as speciedi at:
% http://www.srgb.com/basicsofsrgb.htm
%
% 5/1/04	dhb				Wrote it.

M = [3.2406 -1.5372 -0.4986 ; -0.9689 1.8758 0.0415 ; 0.0557 -0.2040 1.0570];
XYZ = inv(M)*rgb;

