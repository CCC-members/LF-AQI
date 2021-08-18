function [] = view3D_K(Ke,cortex,channels,head,elecIndex)
% this function computes the 3D gain plot of a specfic channel
% from EEG lead field. The lead field should not be projected to normal
% Input:
%       Ke = LF in XYZ coordinates
%       cortex = BEM cortex file
%       channels = channel information and coordinates
%       head = BEM head 
%       elecIndex = elctrode number for which gain plots is plotted
% Output: 3D gain plot for desired electrode

% Authors: Eduardo Martinez Montes, José Enrique Alvarez Iglesias
%% initial computations
mS = 60; % define electrode to show and Marker size
XYZ = cortex.Vertices;
[Ne, Ng] = size(Ke);
Kq = reshape(Ke, [Ne 3 Ng/3]);
Kq = permute(Kq, [3 2 1]);
Kqm = sqrt(dot(Kq,Kq,2));
Kqme = Kqm(:,:,elecIndex);

%% plot 3D gain plot of LF channel
hold on;
rotate3d on;
scatter3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kqme/max(Kqme)*mS,'b','filled');
patch('Vertices',head.Vertices,'Faces',head.Faces,'EdgeColor','none','FaceAlpha',.2,'FaceColor',[202 189 38]/255);
quiver3(XYZ(:,1),XYZ(:,2),XYZ(:,3),Kq(:,1,elecIndex),Kq(:,2,elecIndex),Kq(:,3,elecIndex),'LineWidth',1,'Color','k','AutoScaleFactor',5);
scatter3(channels(:,1),channels(:,2),channels(:,3),mS,'r','filled');
scatter3(channels(elecIndex,1),channels(elecIndex,2),channels(elecIndex,3),mS*3,[0 0.75 0],'filled');
axis equal off;
whitebg('w');
end