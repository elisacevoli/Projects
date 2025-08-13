clc; clear all; close all;
% lm: tabella dei landmark del soggetto corrente (con colonne Acronym, coord_X, coord_Y, coord_Z)
% Z: matrice di profondità/superficie del volto (input per geometric descriptors)
% nomepz: stringa con il nome del 
base_path = 'C:\Users\erric\Politecnico di Torino\Cevoli Elisa - Lab SG3D condiviso\progetto\Bosphorus\';
lms_path = fullfile(base_path, 'lms_1\');
mesh_path = fullfile(base_path, 'Surface Z\');
output_path = fullfile(base_path, 'features_new_sellion');
lm3_files = dir(fullfile(lms_path, '**', '*.mat'));

for k = 1:length(lm3_files)
    lm3_file = fullfile(lm3_files(k).folder, lm3_files(k).name);
    load(lm3_file)
    [~, name, ~] = fileparts(lm3_file);
    parts = split(name, "_");
    prefix = parts(1) + "_"; % "lm_"
    nomepz = join(parts(2:end), "_"); % "bs000_E_HAPPY_0"
    mesh_file = fullfile(mesh_path, [char(nomepz), '.mat']);
    load(mesh_file)

    % 1. Escludi landmark delle orecchie
    orecchie = {'elsx','eldx'};
    lm_filt = lm(~ismember(lm.Acronym, orecchie), :);

    % 2. Calcola tutte le distanze euclidee tra le coppie di landmark
    n = height(lm_filt);
    dist_names = {};
    dist_expl = {};
    dist_vals = [];
    idx = 1;
    for i = 1:n-1
        for j = i+1:n
            % Conversione delle coordinate in cm
            p1 = [lm_filt.cord_X(i), lm_filt.cord_Y(i), lm_filt.cord_Z(i)] / 10;
            p2 = [lm_filt.cord_X(j), lm_filt.cord_Y(j), lm_filt.cord_Z(j)] / 10;
            d = norm(p1 - p2);
            d = round(d,1); % Arrotonda a una cifra decimale
            dist_names{idx,1} = sprintf('dist_euc_%d', idx);
            dist_expl{idx,1} = sprintf('%s-%s', lm_filt.Acronym{i}, lm_filt.Acronym{j});
            dist_vals(idx,1) = d;
            idx = idx + 1;
        end
    end
  
    % 3. Calcola istogrammi dei descrittori geometrici primari e derivati (E, S, C, H, K)
    
    [descr_maps, descr_names] =descriptors_primary_derived(Z);
   
    [geo_features bin_edges, kept_bins1,geo_feature_names] = extract_features_bin(descr_maps, descr_names);
    geo_features=cell2mat(geo_features);
    % 4. Crea la tabella finale delle feature (distanze euclidee + feature geometriche)
    feature_names = [dist_names; geo_feature_names'];
    feature_expl = [dist_expl; repmat({''}, numel(geo_feature_names), 1)];
    feature_vals = [dist_vals; geo_features'];

    Features = table(feature_names, feature_expl, feature_vals, ...
        'VariableNames', {'Feature', 'Description', 'Value'});

    % 5. Salva la struttura
    filename = fullfile(output_path, "features_" + nomepz + ".mat");
    save(filename, 'Features');
    fprintf('Salvato: %s\n', ['features_', char(nomepz), '.mat']);
end
