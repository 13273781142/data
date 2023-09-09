% 1. 准备工作
rng default; clc; close all;
% 1.1 计算次数与名字
maxObjectiveEvaluations = 60;
calName = 'YCCNN-DWT';
% 1.2 开始保存命令行窗口内容
if exist('snrs', 'var')
    if length(snrs) < 1
        calName = ['01BOAWGN-' calName '-0' num2str(snrs)];
    else
        calName = ['01BOAWGN-' calName '-' num2str(snrs)];
    end
    diary([calName, '.txt'])
    disp(['本次计算的信噪比为：',num2str(snrs)]);
else
    calName = ['01BONORM-' calName];
    diary([calName, '.txt'])
    disp('本次没有计算信噪比');
end
% 1.3 计算地址
dataDir = calName;
if ~exist(dataDir,'dir')
	mkdir(dataDir);
end
% 1.4 打印开始计算的系统时间
disp(['本次计算的文件是：',calName,'    贝叶斯优化开始时间：' datestr(datetime)]);

% 2. 加载之前的4D类型的数据
[XTRA,YTRA,XVAL,YVAL,XTES,YTES] = deal(datastra,labeltra,datasval,labelval,datastes,labeltes);
clear datastra labeltra datasval labelval datastes labeltes

% 3. 选取范围和超参数
% 3.1 定义范围和超参数
optimVars = [
    optimizableVariable('InitialLearnRate',[1e-4 1e-1],'Transform','log')
    optimizableVariable('FilterSize',[2 6],'Type','integer')
    optimizableVariable('SectionDepth',[1 3],'Type','integer')
    optimizableVariable('LayersDepth',[1 5],'Type','integer')];
% 3.2 打印优化范围-optimVars
for a = 1:length(optimVars)
    disp([optimVars(a).Name ' [' num2str(optimVars(a).Range) ']']);
end

% 4. 贝叶斯优化
% 4.1 输入数据集调用
ObjFc = makeObjFcnCNN(XTRA,YTRA,XVAL,YVAL,dataDir);
% 4.2 运行贝叶斯优化
BayesObject = bayesopt(ObjFc,optimVars, ...
    'MaxObjectiveEvaluations',maxObjectiveEvaluations);

% 5. 对测试集进行评估
% 5.1 加载最佳网络
bestIdxMinObjective = BayesObject.IndexOfMinimumTrace(end);
fileName = BayesObject.UserDataTrace{bestIdxMinObjective};
savedStruct = load(fullfile(dataDir,fileName));
valError = savedStruct.valError;
% 5.2 计算错误率
YPredicted = predict(savedStruct.trainedNet, XTES);
testError = (YTES - YPredicted).^2;
rmseError = sum( sqrt(sum(testError, 2) / numClasses) );
% 5.2.3 打印信息
[~,bestIdxMinEstimatedObjective] = ismember(BayesObject.XAtMinEstimatedObjective, BayesObject.XTrace);
formatSpec = ' bestIdx is %d %d\n Best Accuracy is %5.6f\n';
fprintf(formatSpec,bestIdxMinObjective, bestIdxMinEstimatedObjective, rmseError);

% 6. 绘制图片
% 6.1 保存最后优化过程图
saveas(gcf, fullfile(dataDir,[calName '.png']));
close(gcf);

% 6.2 保存预测图
for yRows = 6:99
    figcm = figure('Name','Confusion Matrix','Units','centimeters','Position',[5, 5, 17, 8.5]);
    YPredPlot = plot( YPredicted(yRows,:), '--');
    hold on
    YLabelPlot = plot( YTES(yRows,:) );
    legend('YPredPlot','YLabelPlot')
    print(figcm,fullfile(dataDir,[calName 'AYC-' num2str(yRows) '.png']),'-dpng','-r300')
    close(figcm);
end

% 7. 结束工作
% 7.1 保存工作区
save(fullfile(dataDir,[calName '.mat']),'BayesObject','YTES','savedStruct','YPredicted')
% 7.2 打印系统时间
disp(['贝叶斯优化结束时间：' datestr(datetime)]);
clear figcm cm formatSpec a curPath ObjFc
% 7.3 结束保存命令行窗口内容
diary off;
movefile([calName '.txt'], fullfile(dataDir,[calName '.txt']));