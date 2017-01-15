function [Results] = SPF_NESTED_P2_Simulate(EnvironmentCfg,ScenarioCfg)
EnvironmentCfg.SourcesCfg=...
    SPF_AssignSignalsToSources(...
    EnvironmentCfg.SourcesCfg,...
    ScenarioCfg ...
    );
[InputSig_CellArr_Noised] = SPF_GenInput(EnvironmentCfg,ScenarioCfg);
%% Implementation of the paper "NESTED ARRAYS IN TWO DIMENSIONS, PARTII"
[coArray_POS_VEC,z1]=SPF_NESTED_P2_get_CoArray_InputSig(EnvironmentCfg,ScenarioCfg,InputSig_CellArr_Noised);
assert(...
    [...
    'further implementation (2D spatial smoothing and MUSIC spectra) '...
    'is not implemented yet. The main goal was to implement the extraction of z1 ' ...
    'which is the input of the virtual coArray for further processing via cumulants'...
    ] ...
    );
end