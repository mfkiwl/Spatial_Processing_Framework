function [Results] = SPF_PORAT91_A_Simulate(EnvironmentCfg,ScenarioCfg)
EnvironmentCfg.SourcesCfg=...
    SPF_AssignSignalsToSources(...
    EnvironmentCfg.SourcesCfg,...
    ScenarioCfg ...
    );
EnvironmentCfg.SensorsCfg=...
    SPF_PORAT91_AssignFiltersToSensors(...
    EnvironmentCfg.SensorsCfg, ...
    [] ...FilterCfg ...
    );
Sensors_POS_VEC=cell2mat(...
    cellfun(...
    @(SensorCfg) SensorCfg.Position, ...
    EnvironmentCfg.SensorsCfg, ...
    'UniformOutput',false) ...
    );
Results=[];
persistent Response;
CalcResponseFlg=1;
% if ~isempty(Response)
%     CalcResponseFlg=~isequal(Response.SensorCfg,EnvironmentCfg.SensorsCfg);
% end
if CalcResponseFlg
    Response=SPF_CalcResponse(EnvironmentCfg,ScenarioCfg);
end
SensorsInput=SPF_GenInput(EnvironmentCfg,ScenarioCfg);
Mu4_MAT_t=zeros(...
    numel(SensorsInput)^2,...
    numel(SensorsInput)^2,...
    ScenarioCfg.nSnapshots ...
    );
Mu2_k1l1_t=zeros(...
    numel(SensorsInput)^2,...
    numel(SensorsInput)^2,...
    ScenarioCfg.nSnapshots ...
    );
Mu2_k2l2_t=zeros(...
    numel(SensorsInput)^2,...
    numel(SensorsInput)^2,...
    ScenarioCfg.nSnapshots ...
    );
Mu2_k1l2_t=zeros(...
    numel(SensorsInput)^2,...
    numel(SensorsInput)^2,...
    ScenarioCfg.nSnapshots ...
    );
Mu2_k2l1_t=zeros(...
    numel(SensorsInput)^2,...
    numel(SensorsInput)^2,...
    ScenarioCfg.nSnapshots ...
    );
OnesVec=ones([numel(SensorsInput),1]);
for SnpshotID=1:ScenarioCfg.nSnapshots
    if numel(EnvironmentCfg.SourcesCfg)
        ArrInput=...
            reshape(...
            cellfun(...
            @(SensorInput) SensorInput(SnpshotID), ...
            SensorsInput) ...
            ,[],1);
    else
        ArrInput=zeros(numel(EnvironmentCfg.SensorsCfg),1);
    end
    y=ArrInput;
    Mu4_MAT_t(:,:,SnpshotID)=(kron(y,conj(y)))*conj(transpose(kron(y,conj(y))));
    Mu2_k1l1_t(:,:,SnpshotID)=(kron(y,OnesVec))*conj(transpose(kron(y,OnesVec)));
    Mu2_k2l2_t(:,:,SnpshotID)=(kron(OnesVec,conj(y)))*conj(transpose(kron(OnesVec,conj(y))));
    Mu2_k1l2_t(:,:,SnpshotID)=(kron(y,OnesVec))*conj(transpose(kron(OnesVec,conj(y))));
    Mu2_k2l1_t(:,:,SnpshotID)=(kron(OnesVec,conj(y)))*conj(transpose(kron(y,OnesVec)));
end
Comulant4= ...
    mean(Mu4_MAT_t,3) ...
    -mean(Mu2_k1l1_t,3).*mean(Mu2_k2l2_t,3) ...
    -mean(Mu2_k1l2_t,3).*mean(Mu2_k2l1_t,3);
C=Comulant4;
[U,Sigma,V]=svd(C);
Sigma_EigenVal=log(diag(Sigma));
U2=U(:,(numel(EnvironmentCfg.SourcesCfg)+1):end);
d=zeros(size(Response.MAT,2),1);
for AngleID=1:size(Response.MAT,2)
    a=Response.MAT(:,AngleID);
    d(AngleID)=sum(abs(conj(transpose(kron(a,conj(a))))*U2).^2);
end
PhiRes=360/size(Response.MAT,2);
PhiVEC=0:PhiRes:(360-PhiRes/2);
figure;plot(PhiVEC(:),reshape(1./d(1:length(PhiVEC)),[],1));
end