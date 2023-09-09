%% 加载数据集
clc; clear; close all;
curPath = pwd; rng default;
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
cd(fileparts(matlab.desktop.editor.getActiveFilename));

% 打乱提取的数据
% datastra = datastra(randperm(size(tradata, 1)), :);  % size中1获得行数，randperm打乱各行的顺序
% datasval = datasval(randperm(size(valdata, 1)), :);  % size中1获得行数，randperm打乱各行的顺序

%% 分割与处理
% 训练集分割与处理-DFT变换
labeltra = datastra(:, 1:1);
numtralabel = length(unique(labeltra)); % 计算标签个数
lentra = length(labeltra);  % 计算训练集长度
labeltra = categorical(labeltra); 
datastra = datastra(:, 2:end);

Fs = 200; L = floor(size(datastra,2)/Fs)*Fs;
datastra = abs(fft(datastra, L, 2)/L);
datastra = datastra(:, 1:L/2 + 1);
datastra(:,2:end-1) = 2 * datastra(:,2:end-1);

% 验证集分割与处理-DFT变换
labelval = datasval(:, 1:1);
lenval = length(labelval);  % 计算验证集长度
labelval = categorical(labelval);
datasval = datasval(:, 2:end);

datasval = abs(fft(datasval, L, 2)/L);
datasval = datasval(:, 1:L/2 + 1);
datasval(:,2:end-1) = 2*datasval(:,2:end-1);

% 测试集分割与处理-DFT变换
labeltes = datastes(:, 1:1);
lentes = length(labeltes);
labeltes = categorical(labeltes);
datastes = datastes(:, 2:end);

datastes = abs(fft(datastes, L, 2)/L);
datastes = datastes(:, 1:L/2 + 1);
datastes(:,2:end-1) = 2*datastes(:,2:end-1);

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
clear a fn fileName Fs L