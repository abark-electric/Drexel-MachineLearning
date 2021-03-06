%% Binary Artificial Neural Network
%   Author: Haolin Hong
%   Date:   2017-Mar-13
%   Course: CS 383 - Assignment 8

%% Clean up the environment
% save all variables from the workspace
save('env_backup.mat');

% clear all variables
clear variables;

%% Reads in the data
filename = 'spambase.data';
datafile = 'spambase.mat';

if(exist(datafile, 'file'))
    % load data file if it exit
    load(datafile);
else
    % load data from csv file
    data = csvread(filename);
    
    % save the data to datafile
    save(datafile,'data');
end

% clean temp variables
clear filename datafile;

%% Get training data and testing data
% randomizes the data
rng(0);
data = data( randperm( length(data) ), : );

% selects the first 2/3 (round up) of the data for training
num = ceil( length(data) * 2 / 3 );
data_training = data(1 : num, :);

% set the remaining for testing
data_testing = data(num+1 : end, :);

% clean temp variables
clear data num;

%% Standardizes the data
% find the mean and standard deviation of the training data
mv = mean(data_training(:, 1:end-1));
sd = std(data_training(:, 1:end-1));

% standardizes data
data_training = [(data_training(:, 1:end-1) - mv) ./ sd, data_training(:, end)];
data_testing = [(data_testing(:, 1:end-1) - mv) ./ sd, data_testing(:, end)];

% clean temp variables
clear mv sd;

%% Trains an artificial neural network
% settings for traning model
eta = 0.5;
hidden_layer_size = 20;
iteration_max = 1000;

% size
size_hidden = hidden_layer_size;
size_input = size(data_training, 2);
size_output = 1;

N = length(data_training);

% initial weights
beta = rand(size_input, size_hidden) * 2 - 1;
theta = rand(size_hidden, size_output) * 2 - 1;

% data
data = [ones(N, 1), data_training(:, 1:end-1)];
correctValue = data_training(:, end);

% training error
error_training = zeros(iteration_max, 1);

% iterations
for i = 1 : iteration_max
    % forward propagation
    hidden = 1 ./ ( 1 + exp(-1 .* data * beta) );
    output = 1 ./ ( 1 + exp(-1 .* hidden * theta) );
    
    % back propagation
    delta_out = data_training(:, end) - output;
    theta = theta + (eta/N) .* (hidden' * delta_out);
    delta_hid = delta_out * theta' .* hidden .* (1 - hidden);
    beta = beta + (eta/N) .* (data' * delta_hid);
    
    % training error
    predictValue = round(output);
    error_training(i) = ...
        1 - length(correctValue(correctValue == predictValue)) / N;
end

% plot training error vs iteration number
figure;
plot(error_training);
title('Training Error for ANN');
ylabel('Training Error');

% clean temp variables
clear eta hidden_layer_size iteration_max ...
    size_hidden size_input size_output N ...
    data correctValue error_training ...
    i hidden output delta_out delta_hid predictValue;

%% Classifies the testing data
% classifies
data = [ones(length(data_testing), 1), data_testing(:, 1:end-1)];
hidden = 1 ./ ( 1 + exp(-1 .* data * beta) );
output = 1 ./ ( 1 + exp(-1 .* hidden * theta) );
predictValue = round(output);

% computes the testing error and print
error_testing = ...
    1 - length(predictValue(predictValue == data_testing(:, end))) / length(data_testing);
fprintf('Testing Error: %f\n', error_testing);

% clean temp variables
clear data hidden output predictValue;
%% Set environment back and clean
% retrieve the saving variables
load('env_backup.mat');

% remove backup file
delete('env_backup.mat');
