% 加速度计个数
numaccelerator = 6;
% 训练集
datatra1 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TRA_A1.csv", 'Range','C:IRL');
datatra2 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TRA_A2.csv", 'Range','D:IRL');
datatra3 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TRA_A3.csv", 'Range','D:IRL');
datatra4 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TRA_A4.csv", 'Range','D:IRL');
datatra5 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TRA_A5.csv", 'Range','D:IRL');
datatra6 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TRA_A6.csv", 'Range','D:IRL');

% 合并加速度计
datastra = [datatra1, datatra2, datatra3, datatra4, datatra5, datatra6];
% tradata(:, [6563, 13125, 19687, 26249, 32811]) = [];  % 6561 * x + x + 1 =  
clear datatra1 datatra2 datatra3 datatra4 datatra5 datatra6


% 验证集
dataval1 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\VAL_A1.csv", 'Range','C:IRL');
dataval2 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\VAL_A2.csv", 'Range','D:IRL');
dataval3 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\VAL_A3.csv", 'Range','D:IRL');
dataval4 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\VAL_A4.csv", 'Range','D:IRL');
dataval5 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\VAL_A5.csv", 'Range','D:IRL');
dataval6 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\VAL_A6.csv", 'Range','D:IRL');

% 合并加速度计
datasval = [dataval1, dataval2, dataval3, dataval4, dataval5, dataval6];
% valdata(:, [6563, 13125, 19687, 26249, 32811]) = [];  % 6561 * x + x + 1 =  
clear dataval1 dataval2 dataval3 dataval4 dataval5 dataval6


% 测试集
datates1 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TES_A1.csv", 'Range','C:IRL');
datates2 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TES_A2.csv", 'Range','D:IRL');
datates3 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TES_A3.csv", 'Range','D:IRL');
datates4 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TES_A4.csv", 'Range','D:IRL');
datates5 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TES_A5.csv", 'Range','D:IRL');
datates6 = readmatrix("D:\OneDrive\EDR\0AWData2\CONA\TES_A6.csv", 'Range','D:IRL');

% 合并加速度计
datastes = [datates1, datates2, datates3, datates4, datates5, datates6];
% tesdata(:, [6563, 13125, 19687, 26249, 32811]) = [];  % 6561 * x + x + 1 =  
clear datates1 datates2 datates3 datates4 datates5 datates6
