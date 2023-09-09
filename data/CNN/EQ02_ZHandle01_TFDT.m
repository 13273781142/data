%% 加载数据集
clc; clear; close all;
% 加载数据集
curPath = pwd; rng default; fs = 200; snrs = 1;
for a = 1:length(strsplit(curPath,'\'))
    fn = dir(fullfile(curPath, "**\Acceleratorcount1.mat"));
    if isempty(fn)
        curPath = cd('..\');
    else
        fileName = fullfile(fn.folder, fn.name);
        load(fileName);
        break
    end
end
cd(fileparts(matlab.desktop.editor.getActiveFilename))

% 打乱提取的数据
% datastra = datastra(randperm(size(tradata, 1)), :);  % size中1获得行数，randperm打乱各行的顺序
% datasval = datasval(randperm(size(valdata, 1)), :);  % size中1获得行数，randperm打乱各行的顺序
clear a fn fileName

%% 分割与处理
% 训练集分割与处理-时频矩
labeltra = datastra(:, 1:1);
numClasses = length(unique(labeltra)); % 计算标签个数
lentra = length(labeltra);  % 计算训练集长度
labeltra = categorical(labeltra); 
datastra = datastra(:, 2:end);

datastra = num2cell(datastra, 2);
datastra = cell2mat(cellfun(@(x)awgn(x,snrs,'measured'),datastra,'UniformOutput',false));

datastra = num2cell(datastra, 2);
ainstfreq = cellfun(@(x)instfreq(x,fs)',datastra,'UniformOutput',false);
apentropy = cellfun(@(x)pentropy(x,fs)',datastra,'UniformOutput',false);

datastra = cellfun(@(x,y)[x;y],ainstfreq,apentropy,'UniformOutput',false);
XV = [datastra{:}]; mu = mean(XV,2); sg = std(XV,[],2);
datastra = cellfun(@(x)(x-mu)./sg,datastra,'UniformOutput',false);

% 验证集分割与处理-时频矩
labelval = datasval(:, 1:1);
lenval = length(labelval);  % 计算验证集长度
labelval = categorical(labelval);
datasval = datasval(:, 2:end);

datasval = num2cell(datasval, 2);
datasval = cell2mat(cellfun(@(x)awgn(x,snrs,'measured'),datasval,'UniformOutput',false));

datasval = num2cell(datasval, 2);
ainstfreq = cellfun(@(x)instfreq(x,fs)',datasval,'UniformOutput',false);
apentropy = cellfun(@(x)pentropy(x,fs)',datasval,'UniformOutput',false);

datasval = cellfun(@(x,y)[x;y],ainstfreq,apentropy,'UniformOutput',false);
XV = [datasval{:}]; mu = mean(XV,2); sg = std(XV,[],2);
datasval = cellfun(@(x)(x-mu)./sg,datasval,'UniformOutput',false);
% 查看均值
% instFreqNSD = mean(ainstfreq{1}(1,:));
% pentropyNSD = mean(apentropy{1}(1,:));
% instFreqNSD = mean(datasval{1}(1,:));
% pentropyNSD = mean(datasval{1}(2,:));

% 测试集分割与处理-时频矩
labeltes = datastes(:, 1:1);
lentes = length(labeltes);
labeltes = categorical(labeltes);
datastes = datastes(:, 2:end);

datastes = num2cell(datastes, 2);
datastes = cell2mat(cellfun(@(x)awgn(x,snrs,'measured'),datastes,'UniformOutput',false));

datastes = num2cell(datastes, 2);
ainstfreq = cellfun(@(x)instfreq(x,fs)',datastes,'UniformOutput',false);
apentropy = cellfun(@(x)pentropy(x,fs)',datastes,'UniformOutput',false);

datastes = cellfun(@(x,y)[x;y],ainstfreq,apentropy,'UniformOutput',false);
XV = [datastes{:}]; mu = mean(XV,2); sg = std(XV,[],2);
datastes = cellfun(@(x)(x-mu)./sg,datastes,'UniformOutput',false);
clear XV mu sg fs ainstfreq apentropy
%% 标准化与Reshape
% 对数据进行处理（标准化）
% datastra = zscore(datastra, [], 2);
% datasval = zscore(datasval, [], 2);
% datastes = zscore(datastes, [], 2);

% 数据集转换成二维（4-D double）
lenaccelh = size(datastra{1},1); lenaccelw = size(datastra{1},2);
datastra = reshape(cat(3,datastra{:}), lenaccelh, lenaccelw, numaccelerator, lentra);
datasval = reshape(cat(3,datasval{:}), lenaccelh, lenaccelw, numaccelerator, lenval);
datastes = reshape(cat(3,datastes{:}), lenaccelh, lenaccelw, numaccelerator, lentes);
