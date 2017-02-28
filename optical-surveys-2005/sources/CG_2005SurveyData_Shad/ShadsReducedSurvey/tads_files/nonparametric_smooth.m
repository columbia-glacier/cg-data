% nonparametric_smooth.m
% HPM  05/13/03, updated 11/04/03
% this function smooths a data set of 1 variable using a bisquare kernal
% INPUT: x = independent variable
%        y = dependent variable
%        xmin = min value where non-parametric estimate is calulated
%        xmax = max value
%        stepsize = delta(x) step size
%        winsize = +/- number of steps away used
% OUTPUT: xmod = x-value where estimate calculated
%         ymod = non-parametric density estimate

function [xmod,ymod] = nonparametric_smooth(x,y,xmin,xmax,stepsize,winsize)

% Define smoothing parameters and estimate points at even intervals for all
% measurements

% depthmod=0:5:100;  % depths for each estimate [cm]
% ndepth=length(depthmod); % number of modeled points
% winsize=5; % bi-square window of 10 cm

xmod=xmin:stepsize:xmax; % define location of estimates (x-values)

for i=1:length(xmod)
    [ival,weights] = bisqkernal(x,xmod(i),winsize);  % weights for measurement
    ymod(i)=sum(weights.*y(ival))/sum(weights); % non-param estimate 
 %   sSWE_meas(i)=sum(weights.*cSWEm(ival))/sum(weights); % cum SWE
 %   [ival,weights] = bisqkernal(depth_sf,depthmod(i),winsize); % weights for snowfork meas
 %   srho_sf(i)=sum(weights.*rho_sf(ival))/sum(weights); % rho
 %   sSWE_sf(i)=sum(weights.*cSWEmod(ival))/sum(weights); % cumSWE
 %   se1_sf(i)=sum(weights.*e1_sf(ival))/sum(weights); % e1
 %   se2_sf(i)=sum(weights.*e2_sf(ival))/sum(weights); % e2
 %   [ival,weights] = bisqkernal(depth_de1,depthmod(i),winsize);  % weights for change in del const
 %   sde1_sf(i)=sum(weights.*de1_sf(ival))/sum(weights); % de1
 %   sde2_sf(i)=sum(weights.*de2_sf(ival))/sum(weights); % de2
 %   [ival,weights] = bisqkernal(depth_sig,depthmod(i),winsize);  % weights for radar signal
 %   sradar_sig(i)=sum(weights'.*radar_sig(ival))/sum(weights); % radar signal (cumradar is so smooth already!)
end
