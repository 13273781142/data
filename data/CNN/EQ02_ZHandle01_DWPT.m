%% 加载数据集
clc; clear; close all;
% 加载数据集
curPath = pwd; rng default; snrs = 1; wname = 'sym6'; wdlevel = 3;
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
% 训练集分割与处理-小波包变换
labeltra = datastra(:, 1:1);
numClasses = length(unique(labeltra)); % 计算标签个数
lentra = length(labeltra);  % 计算训练集长度
labeltra = categorical(labeltra); 
datastra = datastra(:, 2:end);

datastra = num2cell(datastra, 2);
datastra = cellfun(@(x)awgn(x,snrs,'measured'),datastra,'UniformOutput',false);
datastra = cell2mat(datastra);

datastra = dwpt(datastra', wname, 'Level', wdlevel, 'Boundary', 'periodic');  % 按列取值，故需转置(变换之后是行)
datastra = cell2mat(datastra(1));

% 验证集分割与处理-小波包变换
labelval = datasval(:, 1:1);
lenval = length(labelval);  % 计算验证集长度
labelval = categorical(labelval);
datasval = datasval(:, 2:end);

datasval = num2cell(datasval, 2);
datasval = cellfun(@(x)awgn(x,snrs,'measured'),datasval,'UniformOutput',false);
datasval = cell2mat(datasval);

datasval = dwpt(datasval', wname, 'Level', wdlevel, 'Boundary', 'periodic');
datasval = cell2mat(datasval(1));

% 测试集分割与处理-小波包变换
labeltes = datastes(:, 1:1);
lentes = length(labeltes);
labeltes = categorical(labeltes);
datastes = datastes(:, 2:end);

datastes = num2cell(datastes, 2);
datastes = cellfun(@(x)awgn(x,snrs,'measured'),datastes,'UniformOutput',false);
datastes = cell2mat(datastes);

datastes = dwpt(datastes', wname, 'Level', wdlevel, 'Boundary', 'periodic');
datastes = cell2mat(datastes(1));

%% 标准化与Reshape
% 对数据进行处理（标准化）
datastra = zscore(datastra, [], 2);
datasval = zscore(datasval, [], 2);
datastes = zscore(datastes, [], 2);

% 数据集转换成二维（4-D double）
lenaccelh = 1; lenaccelw = size(datastra,2)/lenaccelh;
datastra = reshape(datastra', lenaccelh, lenaccelw, numaccelerator, lentra);
datasval = reshape(datasval', lenaccelh, lenaccelw, numaccelerator, lenval);
datastes = reshape(datastes', lenaccelh, lenaccelw, numaccelerator, lentes);
