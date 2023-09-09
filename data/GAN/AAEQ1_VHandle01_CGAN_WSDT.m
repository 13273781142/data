%% 加载数据集
clear; close all; clc;
% 加载数据集
curPath = pwd; rng default;
for a = 1:length(strsplit(curPath,'\'))
    fn = dir(fullfile(curPath, "**\Acceleratorcount1_EA.mat"));
    if isempty(fn)
        curPath = cd('..\');
    else
        fileName = fullfile(fn.folder, fn.name);
        load(fileName);
        break
    end
end
cd(fileparts(matlab.desktop.editor.getActiveFilename))

IDXdata = []; LastName = [2, 4, 6, 9, 10, 12, 14, 16]; 
for idxLN = LastName

    IDXtemp = find(datastra(:,1) == idxLN);
    IDXdata = cat(1,IDXdata,IDXtemp);
    clear IDXtemp

end

% 小波散射框架
sf = waveletScattering('SignalLength',6561,'SamplingFrequency',200);
clear a fn fileName curPath idxLN

%% 分割与处理
% 训练集分割与处理
labeltra = datastra(IDXdata, 2);
datastra = datastra(IDXdata, 3:end);

datastra = sf.featureMatrix(datastra');
datastra = datastra(3:end-1,:,:);
datastra(:,end+1,:) = mean(datastra, 2);

% 验证集分割与处理
labelval = datasval(:, 2);
datasval = datasval(:, 3:end);

datasval = sf.featureMatrix(datasval');
datasval = datasval(3:end-1,:,:);
datasval(:,end+1,:) = mean(datasval, 2);

% 测试集分割与处理
labeltes = datastes(:, 2);
datastes = datastes(:, 3:end);

datastes = sf.featureMatrix(datastes');
datastes = datastes(3:end-1,:,:);
datastes(:,end+1,:) = mean(datastes, 2);

%% Reshape
% 数据形状
datastra = reshape(datastra,[],size(datastra,3));
datasval = reshape(datasval,[],size(datasval,3));
datastes = reshape(datastes,[],size(datastes,3));
lenaccelh = 1; lenaccelw = size(datastra,1)/(numInputChannels * lenaccelh);
numClasses = numel(categories(categorical(labeltra)));