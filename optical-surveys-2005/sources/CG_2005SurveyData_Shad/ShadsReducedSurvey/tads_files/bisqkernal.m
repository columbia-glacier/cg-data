% bisqkernal.m
% HPM 05/24/03
% this function calculates weights for nearby points as a function of their
%   distance from the desired location, using a bi-square kernal
% INPUT: depths = locations of measurements
%        depthi = location of desired estimate
%        winsize  = size of moving average window [cm]
% OUPUT: ival = indicies of nearby points used in average
%        weights = weights for each of ival points
% SNTX: [ival,weights] = bisqkernal(depths,depthi,winsize)

function [ival,weights] = bisqkernal(depths,depthi,winsize)

dist=sqrt((depths-depthi).^2); % distance from depthi to each point
%[sortd,j]=sort(dist); % sort the distances
ival=dist<winsize; % use only the points within winsize of depthi 
weights=15/16*(1-(dist(ival)/winsize).^2).^2; % bi-square kernal of weights