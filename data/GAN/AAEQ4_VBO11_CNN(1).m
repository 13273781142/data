% 1. 准备工作
rng default; clc; close all;
% 1.1 计算次数与名字
maxObjectiveEvaluations = 60;
calName = 'CGAN-TIME8-3';
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
disp(['本次计算的文件是：',calName]);
datetime

% 2. 加载之前的4D类型的数据
XTRA = cat(2,datastra,dlXGeneratedNew);
XTRA = reshape(XTRA,lenaccelh,lenaccelw,numInputChannels,size(XTRA,2)); 
YTRA = categorical(cat(1,labeltra',dlYGeneratedNew));
XVAL = reshape(datasval,lenaccelh,lenaccelw,numInputChannels,size(datasval,2));
YVAL = categorical(labelval');
XTES = reshape(datastes,lenaccelh,lenaccelw,numInputChannels,size(datastes,2));
YTES = categorical(labeltes');
[XTRA,YTRA,XVAL,YVAL] = deal(XTRA,YTRA,XVAL,YVAL);
[XTES,YTES] = deal(XTES,YTES);
clear datastra datasval datastes labeltra labelval labeltes dlXGeneratedNew dlYGeneratedNew

% 3. 选取范围和超参数
% 3.1 定义范围和超参数
optimVars = [
    optimizableVariable('InitialLearnRate',[1e-4 1e-1],'Transform','log')
    optimizableVariable('L2Regularization',[1e-4 1e-1],'Transform','log')
    optimizableVariable('FilterSize',[2 6],'Type','integer')
    optimizableVariable('SectionDepth',[1 3],'Type','integer')
    optimizableVariable('LayersDepth',[1 5],'Type','integer')];
% 3.2 打印优化范围-optimVars
for a = 1:length(optimVars)
    disp([optimVars(a).Name ' [' num2str(optimVars(a).Range) ']']);
end

% 4. 贝叶斯优化
% 4.1 输入数据集调用
ObjFc = makeObjFcnV1(XTRA,YTRA,XVAL,YVAL,XTES,YTES,dataDir);
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
[YPredicted,probs] = classify(savedStruct.trainedNet,XTES);
testError = 1 - mean(YPredicted == YTES);
% 5.2.1 计算错误率-标准误差 (testErrorSE) 
testErrorSE = sqrt(testError*(1-testError)/numel(YTES));
% 5.2.2 计算错误率-泛化误差率的约 95% 置信区间 (testError95CI)
testError95CI = [testError - 1.96*testErrorSE, testError + 1.96*testErrorSE];
% 5.2.3 打印信息
[~,bestIdxMinEstimatedObjective] = ismember(BayesObject.XAtMinEstimatedObjective,BayesObject.XTrace);
formatSpec = ' bestIdx is %d %d\n testErrorSE is %4.2f\n testError95CI is [%4.2f %4.2f]\n Best Accuracy is %4.2f\n';
fprintf(formatSpec,bestIdxMinObjective,bestIdxMinEstimatedObjective,testErrorSE,testError95CI,(1-testError)*100);

% 6. 绘制图片
% 6.1 保存最后优化过程图
saveas(gcf, fullfile(dataDir,[calName '.png']));
close(gcf);
% 6.2 绘制混淆矩阵-2
figcm = figure('Name','Confusion Matrix','Units','centimeters','Position',[5, 5, 8.5, 8.5]);
cm = confusionchart(YTES,YPredicted);
cm.Title = ['Confusion Matrix for ' calName];
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
print(figcm,fullfile(dataDir,[calName 'CM-1' '.png']),'-dpng','-r300')
close(figcm)
% 6.2 绘制混淆矩阵-1
cm = plotconfusion(YTES,YPredicted,calName);
cm.PaperPosition = [5, 5, 8.5, 8.5];
print(cm,fullfile(dataDir,[calName 'CM-2' '.png']),'-dpng','-r300')
close(cm);

% 7. 结束工作
% 7.1 保存工作区
save(fullfile(dataDir,[calName '.mat']),'BayesObject','probs','YTES','YPredicted')
% 7.2 打印系统时间
datetime
clear figcm cm formatSpec a curPath ObjFc
% 7.3 结束保存命令行窗口内容
diary off;
movefile([calName '.txt'], fullfile(dataDir,[calName '.txt']));