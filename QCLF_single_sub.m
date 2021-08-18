% This script uses different functions for QCLF to compute and plot
% correlations for channels and voxels. It also plots 3D gain for a 
% specific channel
% File paths for LF, Channel Coordinates, BEM cortex and Head are given
% at specified locations

% Authors: Usama Riaz, Fuleah A Razzaq, Pedro A Valdes
clear all;close all;clc;
%% Setting parameters
ThC = 0.7; % threshold value for Channels
ThV = 0.4; % threshold value for Voxels
ch = 78; %channel number to plot 3D gain for

%% Access leadfield,eeg,scalp and surf folder for each subject
% LF: OpenMEEG output file for lead field
LF =load('D:\Usama\PhD\Frontiers\QCLF\Templates\ICBMpool\ICBM152\headmodel_surf_openmeeg.mat');
% Loc: EEG chanel file from BrainStorm
Loc =load('D:\Usama\PhD\Frontiers\QCLF\Templates\ICBMpool\ICBM152\channel.mat');
% head: BEM head
head =load('D:\Usama\PhD\Frontiers\QCLF\Templates\ICBMpool\ICBM152\tess_head_bem_1922V.mat');
% cortex: BEM cortex
cortex = load('D:\Usama\PhD\Frontiers\QCLF\Templates\ICBMpool\ICBM152\tess_cortex_concat.mat');
%% Computing and plotting QC parameters 
% Computing
[K,Kn,Khomn,Khom,corelv,corelch,ChannelPos] = EEG_QCLF(cortex,LF,Loc);
% plotting channel-wise correlation
figure;
plot(corelch(:), 'LineWidth', 1.2);
xlabel('Channels'), ylabel('Correlation');
ylim([0 1]); yticks(0:0.2:1); yline(ThC, 'r--', 'LineWidth', 1.2);
% plotting voxel-wise correlation
figure;
plot(corelv,'.');
xlabel('Voxels'), ylabel('Correlation');
ylim([0 1]); yticks(0:0.2:1); yline(ThV, 'r--', 'LineWidth', 1.2);
% plotting 3D Gain 
figure;
view3D_K(K,cortex,ChannelPos,head,ch);