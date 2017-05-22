function [RsTOA,zenith_angle_deg,azimuth_angle_deg,sunrise,sunset,solar_decl,hour_angle]...
    =TOA_incoming_solar(DOY,UTC,time_zone_shift,lat_deg,lon_deg)
% -------------------------------------------------------------------------
% [RsTOA,zenith_angle_deg,azimuth_angle_deg,sunrise,sunset,solar_decl,hour_angle]...
%     =TOA_incoming_solar(DOY,UTC,time_zone_shift,lat_deg,lon_deg)
% 
% Description:
% Function to compute TOA incident solar radiation
%
% Modified by Steve Margulis, Fall 2011
%
% Inputs:
% DOY: Day of Year (integer): Jan. 1 = 1, Dec. 31 = 365
% UTC: Universal Time (Greenwich Mean Time) in decimal hours: 0.0=midnight, 23.0=11pm
% time_zone_shift (hours): Time shift relative to UTC (i.e. California, -8 (hours)
% lat_deg: Latitude (in degrees)
% lon_deg: Longitude (in degrees), negative to West of UTC line
% 
% Outputs:
% RsTOA: TOA solar flux (W/m^2)
% zenith_angle_deg: solar zenith angle in degrees
% azimuth_angle_deg: solar azimuth angle in degrees
% sunrise: Local hour of sunrise
% sunset: Local hour of sunset
% solar_decl: Solar declination angle in radians
% hour_angle: Hour angle in radians
%
% NOTE: Can run for multiple hours (i.e. vector inputs), but setup for a single
% day (DOY) and lat/lon
%
% Example
% DOY= 115;% April 25
% UTC= 16;
% time_zone_shift= -8;
% lat_deg= 34.05; lon_deg= -118.25; % Los Angeles
% 
% [RsTOA,zenith_angle_deg,azimuth_angle_deg,sunrise,sunset]...
%     =TOA_incoming_solar(DOY,UTC,time_zone_shift,lat_deg,lon_deg)
% 
% RsTOA =
%   751.4631
% zenith_angle_deg =
%    56.2121
% azimuth_angle_deg =
%    97.3170
% sunrise =
%     5.2555
% sunset =
%    18.4450
% solar_decl =
%     0.2256
% hour_angle =
%    -1.0080

%%% Disclaimer:
%%% This program and all related codes that are part of the "MOdular 
%%% Distributed Watershed Educational Toolbox" (hereafter "MOD-WET" or 
%%% "software") is designed for instructional and educational use. 
%%% Commercial use is prohibited. The software is provided 'as is' without 
%%% warranty of any kind, either express or implied. MOD-WET could include 
%%% technical or other mistakes, inaccuracies or typographical errors. The 
%%% use of the software is done at your own discretion and risk and with 
%%% agreement that you will be solely responsible for any damage and that 
%%% the authors and their affiliate institutions accept no responsibility 
%%% for errors or omissions in the software or documentation. In no event 
%%% shall the authors or their affiliate institutions be liable to you or 
%%% any third parties for any special, indirect or consequential damages of 
%%% any kind, or any damages whatsoever.
%%%
%%% Any bugs that are found can be reported to: Steve Margulis
%%% (margulis@seas.ucla.edu) where we will make every effort to fix them 
%%% for future releases.

% Solar constant
S0=1367.; % W/m^2

% Compute solar geometry (mainly need zenith angle)
[zenith_angle_deg,azimuth_angle_deg,sunrise,sunset,solar_decl,hour_angle]=solar_geometry(DOY,UTC,time_zone_shift,lat_deg,lon_deg);
            
% Compute ratio of actual to mean Earth-Sun distance
r=1.0 + 0.017*cos(2*pi/365*(186-DOY));
% Calculate the TOA Solar Radiation [top of the atmosphere solar incident flux]
zenith_angle_deg(zenith_angle_deg>90)=90; % This sets any values below horizon to the horizon
theta=zenith_angle_deg*pi/180;

RsTOA=S0*cos(theta)./r^2;

return