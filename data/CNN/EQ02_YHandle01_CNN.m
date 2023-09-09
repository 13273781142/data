%% 加载数据集
clear; close all; clc;
% 加载数据集
curPath = pwd; rng default; wdlevel = 0;
for a = 1:length(strsplit(curPath,'\'))
    fn = dir(fullfile(curPath, "**\Acceleratorcount1_YC.mat"));
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
% 训练集分割与处理
datastra = datastra(:, 1233:5328);
labeltra = labeltra(:, 1233:5328);
numClasses = size(labeltra, 2); % 计算标签个数
lentra = size(datastra, 1);  % 计算训练集长度

% 验证集分割与处理
datasval = datasval(:, 1233:5328);
labelval = labelval(:, 1233:5328);
lenval = size(datasval, 1);  % 计算验证集长度

% 测试集分割与处理
datastes = datastes(:, 1233:5328);
labeltes = labeltes(:, 1233:5328);
lentes = size(datastes, 1);

%% 标准化与Reshape
% 对数据进行处理（标准化）
datastra = mapminmax(datastra, 0, 1);
datasval = mapminmax(datasval, 0, 1);
datastes = mapminmax(datastes, 0, 1);

% 数据集转换成二维（4-D double）
lenaccelh = 1; lenaccelw = size(datastra, 2)/lenaccelh;
datastra = reshape(datastra', lenaccelh, lenaccelw, numaccelerator, lentra);
datasval = reshape(datasval', lenaccelh, lenaccelw, numaccelerator, lenval);
datastes = reshape(datastes', lenaccelh, lenaccelw, numaccelerator, lentes);
