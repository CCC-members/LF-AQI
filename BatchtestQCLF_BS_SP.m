% This script computes the AQI for files saved in BrainStorm format
% In this case there will be multiple BrainStorm Protocols
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
path='/data3_260T/data/CCLAB_DATASETS/CMI/CMI_encrypted/Run_2/First_process/Missing_Subs_788/';
%% Access anatomy and data folder for each protocol
    protocol_anat=strcat(path,'/anat');
    protocol_data=strcat(path,'/data');
%% For each protocol 
%get all the subject for iProtocol
subject_names=dir(char(protocol_anat));
subject_filenames={subject_names(1:length(subject_names)).name};
%delete empty files or not relevant file names
for i=length(subject_filenames):-1:1
    tmp=subject_filenames{i};
    if strcmp(tmp(1),'.') || strcmp(tmp(1),'i') || contains(tmp,'default') || contains(tmp,'.mat')
        subject_filenames(i)=[];     % delete files starting with '.' or '@'
        subject_names(i)=[];
    end
end
%% FOR EACH SUBJECT
 for iSubject=1:length(subject_filenames)
     iTotal=iTotal+1;
     SubjectAnat = strcat(protocol_anat,'/',subject_filenames{iSubject});
     SubjectData= strcat(protocol_data,'/',subject_filenames{iSubject},'/@raw',subject_filenames{iSubject});
     %%load Data
     FnameLF=char(strcat(SubjectData,'/headmodel_surf_openmeeg.mat'));
     FnameCh=char(strcat(SubjectData,'/channel.mat'));
     FnameSurf=char(strcat(SubjectAnat,'/tess_cortex_concat.mat'));
     if isfile(FnameLF) && isfile(FnameCh) && isfile(FnameSurf)
         LF = load(FnameLF);
         Loc=load(FnameCh);
         Loc=Loc.Channel;
         Cortex=load(FnameSurf);
         %assign relavant names
         K=LF.Gain;
         ChannelPos=zeros(length(Loc),3);
         for i=1:length(Loc), ChannelPos(i,:)=Loc(i).Loc; end
         LFisNormal=0;
         VoxelCoord=Cortex.Vertices;
         VertNorms=Cortex.VertNormals;
         [Ne, Nv]=size(K); if ~LFisNormal, Nv=Nv/3;end;
         [corelv,corelch, corr2D, simCorr] = corelLF( K,LFisNormal,VertNorms,VoxelCoord,ChannelPos);
         minCh = min(corelch);
         minV = min(corelv);
         subAll.Subject(iTotal) = subject_filenames(iSubject);
         subAll.Ch(iTotal) = minCh;
         subAll.V(iTotal) = minV;
     else
          EmptyLF{iEmpty+1}.Subject=subject_names(iSubject);
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