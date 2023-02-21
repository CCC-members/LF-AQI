function [corelv,corelch] = corelLF( K,LFisNormal,VertNorms,VoxelCoord,Channels)
[Kn,Khomn,~,~,~,~] = computeNunezLFthetaR( K,LFisNormal,VertNorms,VoxelCoord,Channels);
zKn = zscore(Kn')';
zKhom = zscore(Khomn')';
dth =20;
[Ne, Nv] = size(Kn);
for i=1:Ne, corelch(i,1)=corr(Khomn(i,:).',Kn(i,:).'); end
for i=1:Nv, corelv(i,1)=corr(zKhom(:,i),zKn(:,i)); end
corelv(isnan(corelv))=0;
corelch(isnan(corelch))=0;
for k =1:Nv
    D=sqrt(sum((repmat(VoxelCoord(k,:),[Nv,1])-VoxelCoord).^2,2));
    D = D*1000; %for dimensions that are in mtrs
    WeiMat = zeros(length(corelv(D<dth)),2);
    WeiMat(:,1)=corelv(D<dth);
    WeiMat(:,2)=D(D<dth)+0.1;
    corelv(k) = sum(WeiMat(:,1)./WeiMat(:,2))/sum(1./WeiMat(:,2));
end
end