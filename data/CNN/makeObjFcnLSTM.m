% 优化的目标函数
% 1. 将优化变量的值作为输入。bayesopt 使用某个表中的优化变量的当前值调用目标函数，该表的每个列名等于变量名称。例如，网络部分深度的当前值为 optVars.SectionDepth。
% 2. 定义网络架构和训练选项。
% 3. 训练并验证网络。
% 4. 将经过训练的网络、验证误差和训练选项保存到磁盘。
% 5. 返回已保存网络的验证误差和文件名。
function ObjFcn = makeObjFcnLSTM(XTrain,YTrain,XValidation,YValidation,DATARoot)
ObjFcn = @valErrorFun;

    function [valError,cons,fileName] = valErrorFun(optVars)
        numFeatures=size(XTrain{1},1); numClasseSs = size(XTrain{1},1);
        miniBatchSize = 512; rng default;
        maxEpochs = 150; validationPatience = 80;

        layers = [
            sequenceInputLayer(numFeatures)
%             卷积核大小，卷积核数量，卷积层数量，网络层深度
            lstmBlock(optVars.HiddenUnits,optVars.DropOut,optVars.LayersDepth)
            fullyConnectedLayer(numClasseSs)
            regressionLayer];

%         指定验证数据并选择 'ValidationFrequency' 值，使 trainNetwork 每轮训练都验证一次网络。
        validationFrequency = floor(length(XTrain)/miniBatchSize); 
%         指定网络训练的选项。
        options = trainingOptions('adam', ...
            'OutputNetwork','best-validation-loss',...
            'ExecutionEnvironment','gpu',...
            'InitialLearnRate',optVars.InitialLearnRate, ...
            'LearnRateSchedule','piecewise', ...
            'LearnRateDropPeriod',4, ...
            'LearnRateDropFactor',0.90, ...
            'MaxEpochs',maxEpochs, ...
            'MiniBatchSize',miniBatchSize, ...
            'ValidationFrequency',validationFrequency, ...
            'ValidationData',{XValidation,YValidation}, ...
            'ValidationPatience',validationPatience,...
            'Shuffle','every-epoch', ...
            'Verbose',false, ...
            'Plots','training-progress',...
            'OutputFcn',{@(info)stopIfEachTimeMax(info, 25), @(info)stopIfTimeMax(info, 40*60)});

        [trainedNet,info] = trainNetwork(XTrain,YTrain,layers,options);
%         训练网络并在训练过程中绘制训练进度。训练结束后关闭所有训练图。
        close(findall(groot,'Tag','NNET_CNN_TRAININGPLOT_UIFIGURE')) 
%         计算测试集正确率
        YValPredicted = predict(trainedNet, XValidation);
        predictionValError = (cell2mat(YValidation) - cell2mat(YValPredicted)).^2;
        valError = mean( sqrt(mean(predictionValError, 2) ) );
%         创建包含验证误差的文件名，并将网络、验证误差和训练选项保存到磁盘。
        numFile = numel(dir(fullfile(DATARoot,'*.mat'))) + 1; % 读取文件夹列表
        fileName = [num2str(numFile) '_' num2str(valError) '.mat'];
        fileMat = fullfile(DATARoot,fileName);
        save(fileMat,'valError','layers','options','trainedNet','info')

%         绘制每个训练图像中验证集Loss图像
        valloss = info.ValidationLoss;
        valloss(isnan(valloss)) = [];
        if length(valloss) >= 5
            [~, minposition] = min(valloss);
            figloss = figure('Units','normalized','Position',[0.2 0.2 0.4 0.4]);
            pv = plot(valloss(:, 2:end));
            title(sprintf('%d - %.2f - %d - %d', numFile, (1-valError) * 100, length(valloss)), minposition);
            saveas(pv, fullfile(DATARoot,['LO_' num2str(numFile) '_' num2str(valError)  '.jpg']));
            close(figloss)
        end

        cons = [];

    end
end

% convBlock 函数创建 numConvLayers 卷积层块，其中每个层都有指定的filterSize和numFilters滤波器，
% 并且每个层都后接一个批量归一化层和一个 ReLU 层。
function layers = lstmBlock(numHiddenUnits,numdropoutLayer,numConvLayers)

layers = [
    lstmLayer(numHiddenUnits,'OutputMode','sequence')
    reluLayer
    dropoutLayer(numdropoutLayer)];
layers = repmat(layers,numConvLayers,1);

end

% 时间早停条件(该函数为每个Epochs执行一次);每个Epochs的训练时间不能大于
function stop = stopIfEachTimeMax(info,numSeconds)

stop = false;

% 固定初始条件
persistent logTime

% Clear the variables when training starts.
if info.State == "start"
    logTime = datetime;
    
elseif ~isempty(info.ValidationLoss)

    if info.ValidationLoss ~= -1
        dt = floor(seconds(datetime-logTime));
        logTime = datetime;
    end
        
    if dt > numSeconds
        stop = true;
    end
end
end
% 时间早停条件(该函数为每个Iteration执行一次);每个Iteration的训练时间不能大于
function stop = stopIfTimeMax(info,numSeconds)
if info.TimeSinceStart >= numSeconds
    stop = true;
end
end