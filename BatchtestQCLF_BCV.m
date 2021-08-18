% This script computes the AQI for files saved in BC-VARETA format
% Folders contain files  for LF, Channel Coordinates, BEM cortex 
% and Head 

% Authors: Usama Riaz, Fuleah A Razzaq, Pedro A Valdes
clear all;close all;clc;
%% Flags
iGood=0;
iBad=0;
iEmpty=0;
iTotal=0;
ThC = 0.7; % threshold value for Channels
ThV = 0.4; % threshold value for Voxels
%% Absolute path variable
path='/data3_260T/data/CCLAB_DATASETS/CMI/CMI_encrypted/Run_2/155_CMI_distance_corrected/BC-VARETA_Structure';
%% list all the folder in the given path.
% in this case there will be BC-VARETA format folder structure
bcv_dir=dir(path);
sub_names={bcv_dir(1:length(bcv_dir)).name};
%% Clear the first two names as it have null value
for i=length(sub_names):-1:1
    tmp=sub_names{i};
    if strcmp((tmp(1)),'.') || strcmp((tmp(1)),'i')
        sub_names(i)=[];     % delete files starting with '.'
        bcv_dir(i)=[];
    end
end
%% Access leadfield,eeg,scalp and surf folder for each subject
for i=length(sub_names):-1:1
    tmp=sub_names{i};
    FnameLF(i)=strcat(path,'/', sub_names(i),'/leadfield/om_leadfield.mat');
    FnameCh(i)=strcat(path,'/', sub_names(i),'/eeg/eeg_info.mat');
    FnameScalp(i)=strcat(path,'/', sub_names(i),'/scalp/scalp.mat');
    FnameSurf(i)=strcat(path,'/', sub_names(i),'/surf/surf.mat');
end
%% FOR EACH SUBJECT
 for i=1:length(sub_names)
     %%load Data
     if isfile(FnameLF(i)) && isfile(FnameScalp(i)) && isfile(FnameSurf(i))
         LF = load(FnameLF{i});
         Loc=load(FnameScalp{i});
         Loc=Loc.Cdata;
         Loc=Loc.Channel;
         Loc=Loc.Loc;
         Cortex=load(FnameSurf{i});
         Cortex = Cortex.Sc8k;
         %assign relavant names
         K=LF.Ke;
         ChannelPos=zeros(length(Loc),3);
         for i=1:length(Loc), ChannelPos(i,:)=Loc(i).Loc; end
         LFisNormal=0;
         VoxelCoord=Cortex.Vertices;
         VertNorms=Cortex.VertNormals;
         [Ne, Nv]=size(K); 
         if ~LFisNormal, Nv=Nv/3;end
         [corelv,corelch, corr2D, simCorr] = corelLF( K,LFisNormal,VertNorms,VoxelCoord,ChannelPos);
         minCh = min(corelch);
         minV = min(corelv);
         subAll.Subject(iTotal) = sub_names(i);
         subAll.Ch(iTotal) = minCh;
         subAll.V(iTotal) = minV;
     else
          EmptyLF{iEmpty+1}.Subject=sub_names(i);
             iEmpty=iEmpty+1;
     end
 end
%% Compute and visualize AQI
gSub.Ch=chAll(subAll.Ch>ThC);
gSub.V=VAll(subAll.V>ThV);
gCent=[median(gSub.Ch) median(gSub.V)];
aqiParam = [chAll;VAll];
for i=1:1251
AQI(i)=sqrt(sum((aqiParam(i)-gCent)).^2);
end
figure;
scatter(subAll.Ch,subAll.V);
yline(ThC, 'r--', 'LineWidth', 1.2);
xline(ThV, 'r--', 'LineWidth', 1.2);
xlabel('Minimum channel correlation');
ylabel('Minimum voxel correlation');
figure;hist(AQI,100);xlabel('QC metric')