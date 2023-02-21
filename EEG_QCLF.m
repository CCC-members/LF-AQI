function [K,Kn,Khomn,Khom,corelv,corelch,ChannelPos] = EEG_QCLF(cortex,LF,Loc)
% this function computes CSP and SSP
% between homogeneous and test LFs
% Input:
%       K= lead field gain plot
%       cortex= cortex information from test LF
%       Channels= EEG channels coordinate information
% Output:
%       Khomn = Normalised Homogeneous LF
%       Khom = Homogenous LF
%       Kr = projected to normal test LF 
%       corelv = voxel-wise correlations for all LF voxels
%       corelch = channels-wise correlations for all LF channels
% Authors: Usama Riaz, Fuleah A Razzaq, Pedro A Valdes
Loc = Loc.Channel; % accessing channel information
ChannelPos=zeros(length(Loc),3);
for i=1:length(Loc), ChannelPos(i,:)=Loc(i).Loc; end
K=LF.Gain;%% accessing lead field
Cortex = cortex;
LFisNormal=0;
VoxelCoord=Cortex.Vertices'; % accessing voxel coordinates
VertNorms=Cortex.VertNormals';
% computing homogeneous lead field
[Kn,Khomn,Khom] = computeNunezLF(K,LFisNormal,VertNorms, VoxelCoord, ChannelPos);
[Ne, Nv] = size(K);
% computing channel-wise correlation
for i=1:Ne, corelch(i,1)=corr(Khomn(i,:).',Kn(i,:).'); end
zKhom = zscore(Khomn')';
zK = zscore(Kn')';
% computing voxel-wise correlation
for i=1:Nv/3, corelv(i,1)=corr(zKhom(:,i),zK(:,i)); end
corelv(isnan(corelv))=0;
end