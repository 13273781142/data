% 加速度计个数
numInputChannels = 1;
% 训练集
datastra = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TRA_EA6.csv", 'Range','C:IRM');

% 验证集
datasval = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\VAL_EA6.csv", 'Range','C:IRM');

% 测试集
datastes = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TES_EA6.csv", 'Range','C:IRM');
