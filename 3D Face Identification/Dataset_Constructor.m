%% CREAZIONE DATASET
clear all, close all, clc;
features_dir = 'C:\Users\erric\Politecnico di Torino\Cevoli Elisa - Lab SG3D condiviso\progetto\Bosphorus\features_neW'; % cartella con i .mat
files = dir(fullfile(features_dir, 'features_*.mat'));

dataset = table; % tabella vuota

for k = 1:length(files)
    % Carica il file
    file_path = fullfile(features_dir, files(k).name);
    S = load(file_path); % carica la variabile Features
    
    % Estrai nomepz e posa dal nome file
    fname = files(k).name;
    fname = erase(fname, 'features_');
    fname = erase(fname, '.mat');
    parts = split(fname, '_');
    nomepz = parts{1};
    posa = strjoin(parts(2:end), '_');
    
    % Trasforma la tabella Features in struct
    T = S.Features;
    feature_row = table;
    feature_row.nomepz = {nomepz};
    feature_row.posa = {posa};
    
    for i = 1:height(T)
        colname = T.Feature{i};
        feature_row.(colname) = T.Value(i);
    end
    
    % Aggiungi la riga alla tabella finale
    dataset = [dataset; feature_row];
end

% Visualizza le prime righe
disp(dataset(1:5,:));

writetable(dataset, 'dataset_finale_Bosphorus_new.csv');
% Leggi il file CSV in una tabella
T = readtable('dataset_finale_Bosphorus_new.csv');

% Rinomina le colonne
T = renamevars(T, {'nomepz', 'posa'}, {'name', 'emotion'});

% (Opzionale) Salva la tabella modificata
writetable(T, 'dataset_finale_Bosphorus_new.csv');

%% Creazione dataset acquisito - FEATURE DERIVATE
% --- Impostazioni percorso ---
dataDir = 'C:\Users\erric\Politecnico di Torino\Cevoli Elisa - Lab SG3D condiviso\progetto\surfaceZ_racccolti';
csvFile = 'C:\Users\erric\Politecnico di Torino\Cevoli Elisa - Lab SG3D condiviso\progetto\acquisizioni_realsense\data_rilevazione.csv';

% --- Leggi il CSV delle distanze euclidee ---
distances = readtable(csvFile, 'Delimiter', ',');

% --- Leggi i file delle superfici .mat ---
files = dir(fullfile(dataDir, '*.mat'));
numFiles = length(files);

% Ottieni i nomi delle feature geometriche dal dataset appena creato
% (o calcola su un esempio)
S_example = load(fullfile(dataDir, files(1).name));
Z_example = double(S_example.Z);
Z_example = flipud(Z_example);
[descr_maps, descr_names] =descriptors_primary_derived(Z_example);
[~,~,~, geo_feature_names] = extract_features_bin(descr_maps, descr_names);
%geo_feature_names=cell2mat(geo_feature_names);
numGeoFeatures = numel(geo_feature_names);

geoFeatures = nan(numFiles, numGeoFeatures);
fileNames = cell(numFiles,1);

for i = 1:numFiles
    [~, name, ~] = fileparts(files(i).name);
    fileNames{i} = name;

    % Carica la superficie Z dal file .mat
    S = load(fullfile(dataDir, files(i).name));
    Z = double(S.Z);
    Z = flipud(Z);
    % Calcola solo istogrammi dei descrittori geometrici scelti
    [descr_maps, descr_names] =descriptors_primary_derived(Z);
    [features] = extract_features(descr_maps, descr_names);
    features=cell2mat(features);
    geoFeatures(i,:) = features;
end

% --- Allineamento tra nomi file e righe CSV ---
csvKeys = strcat(distances.name, '_', distances.emotion);

alignedGeoFeatures = nan(height(distances), numGeoFeatures);
for i = 1:height(distances)
    idx = find(strcmp(csvKeys{i}, fileNames));
    if ~isempty(idx)
        alignedGeoFeatures(i,:) = geoFeatures(idx,:);
    end
end

% --- Nomi delle nuove colonne ---
geoTable = array2table(alignedGeoFeatures, 'VariableNames', geo_feature_names);

% --- Unisci al CSV originale ---
finalDataset = [distances geoTable];

% --- Salva il dataset finale ---
writetable(finalDataset, 'dataset_finale_acquisito_new_sellion.csv');

%% DATASET FINALE 
% Leggi i due dataset
T1 = readtable('dataset_finale_Bosphorus_neW.csv');
T2 = readtable('dataset_finale_acquisito_new.csv');

% Ottieni la lista completa delle colonne
allVars = union(T1.Properties.VariableNames, T2.Properties.VariableNames, 'stable');


% Ordina le colonne nello stesso ordine
T1 = T1(:,allVars);
T2 = T2(:,allVars);

% Unisci verticalmente
Ttot = [T1; T2];

% Salva il dataset finale
writetable(Ttot, 'dataset_completo_new.csv');

%% DATASET ridotto 
% --- Carica il dataset finale ---
T= readtable('dataset_completo_new.csv');

% --- Carica la lista delle distanze scelte e prendi solo il primo nome tra gli apici ---
fid = fopen('C:\Users\erric\Politecnico di Torino\Cevoli Elisa - Lab SG3D condiviso\progetto\features_selezionate\distanze_scelte.txt');
dist_lines = textscan(fid, '%s%*[^\n]', 'Delimiter', '\t');
fclose(fid);
dist_cols = dist_lines{1};
for i = 1:numel(dist_cols)
    % Rimuovi apici e spazi
    s = strrep(dist_cols{i}, '''', '');
    s = strtrim(s);
    % Prendi solo la prima "parola" (fino al primo spazio o tab)
    tokens = regexp(s, '(\S+)', 'tokens');
    dist_cols{i} = tokens{1}{1};
end

% --- Carica la lista dei descrittori geometrici scelti e rimuovi gli apici ---
% --- Colonne dei descrittori geometrici (bin) ---
geo_bin_cols = T.Properties.VariableNames(256:end); % <-- cell array semplice

% --- Colonne base da mantenere (nome, emozione, ecc.) ---
base_cols = {};
if any(strcmp('name', T.Properties.VariableNames))
    base_cols{end+1} = 'name';
end
if any(strcmp('emotion', T.Properties.VariableNames))
    base_cols{end+1} = 'emotion';
end

% --- Crea la lista finale delle colonne da estrarre ---
cols_to_keep = [base_cols, dist_cols', geo_bin_cols];

% --- Verifica che tutte le colonne esistano nel dataset ---
cols_to_keep1 = intersect(cols_to_keep, T.Properties.VariableNames, 'stable');

% --- Estrai il nuovo dataset ridotto ---
T_reduced = T(:, cols_to_keep1);
cols_no=setdiff(cols_to_keep,cols_to_keep1,'stable');


T=T_reduced;
% Supponendo che il tuo dataset sia una tabella chiamata 'T'
% e la colonna delle emozioni si chiami 'emotion'

for i = 1:height(T)
    val = T.emotion{i};
    suffix = '';
    
    % Sostituzioni secondo le regole
    if contains(val, 'HAPPY') || contains(lower(val), 'felice')
        T.emotion{i} = ['HAPPY' suffix];
    elseif contains(val, 'N_N') || contains(lower(val), 'seria') || contains(lower(val), 'serio')
        T.emotion{i} = ['NEUTRAL' suffix];
    elseif contains(val, 'LFAU') || contains(lower(val), 'sorriso')
        T.emotion{i} = ['SMILE' suffix];
    end
end

%% creazione dataset per classe 0 - NON PRESENTE NEL DATASET
% Seleziona 2 soggetti casuali tra tutti quelli presenti
% unique_names = unique(T.name, 'stable');
if numel(unique_names) >= 2
    sel_idx = randperm(numel(unique_names), 2);
    selected_names1 = unique_names(sel_idx);
else
    error('Non ci sono almeno 2 soggetti nel dataset');
end

% Rimuovi queste righe da T (il dataset ridotto)
T(is_unknown, :) = [];

%% SALVATAGGIO DATASET 
% Supponendo che la tua tabella si chiami T e la colonna sia 'name'
[unique_names, ~, class_idx] = unique(T.name, 'stable');
T.classes = class_idx;

T_unknown.classes= zeros(size(T_unknown, 1),1);
% --- Salva il nuovo dataset ---
writetable(T, 'dataset_ridotto_new.csv');

writetable(T_unknown, 'test_unknown_new.csv')

