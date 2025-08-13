function [features, bin_edges, kept_bins, feature_names] = extract_features_bin(descr_maps, descr_names, kept_bins_in)
% descr_maps: cell array 1xN_descr, ogni cella matrice [rows x cols x N_imgs]
% descr_names: cell array 1xN_descr, nomi dei descrittori
% kept_bins_in: (opzionale) cell array 1xN_descr, indici dei bin da tenere per ogni descrittore
% features: cell array 1xN_imgs, ogni cella vettore feature per quell'immagine
% bin_edges: cell array 1xN_descr, edges usati per ogni descrittore
% kept_bins: cell array 1xN_descr, indici dei bin mantenuti (tutti)
% feature_names: cell array 1xN_total_features, nomi delle feature (es. sin_e_hist1)

% Parametri bin per ogni descrittore
bin_settings = struct( ...
    'sin_e',    15, ...
    'atan_e',   15, ...
    'mean_g',   15, ...
    'median_g', 15, ...
    'sin_g',    15, ...
    'atan_g',   15, ...
    'median_H', 15, ...
    'S',        9, ... % Koenderink & van Doorn
    'C',        15, ...
    'atan_G',   15, ...
    'ln_E',     15);

N_descr = numel(descr_names);
[rows, cols, N_imgs] = size(descr_maps{1});
features = cell(1, N_imgs);
bin_edges = cell(1, N_descr);
kept_bins = cell(1, N_descr);

% Per costruire i nomi delle feature
feature_names = {};

% Step 1: Calcola edges globali per ogni descrittore
for d = 1:N_descr
    descr_name = descr_names{d};
    all_vals = [];
    for img = 1:N_imgs
        vals = descr_maps{d}(:,:,img);
        vals = vals(:);
        vals = vals(~isnan(vals) & ~isinf(vals));
        vals = vals(imag(vals)==0); % elimina valori complessi
        all_vals = [all_vals; vals];
    end
    if strcmpi(descr_name, 'S')
        edges = linspace(-1, 1, 10);
        kept_bins{d} = 1:9; % Tieni sempre tutti i bin per 'S'
    else
        nbins = bin_settings.(descr_name);
        edges = linspace(min(all_vals), max(all_vals), nbins+1);
        kept_bins{d} = 1:nbins; % Tieni sempre tutti i bin
    end
    bin_edges{d} = edges;
    % Costruisci i nomi delle feature per questo descrittore
    for k = 1:length(kept_bins{d})
        feature_names{end+1} = sprintf('%s_hist%d', descr_name, kept_bins{d}(k));
    end
end

% Step 2: Estrai feature per ogni immagine, usando tutti i bin
for img = 1:N_imgs
    feat_vec = [];
    for d = 1:N_descr
        vals = descr_maps{d}(:,:,img);
        vals = vals(:);
        vals = vals(~isnan(vals) & ~isinf(vals));
        vals = vals(imag(vals)==0); % elimina valori complessi
        edges = bin_edges{d};
        [counts, ~] = histcounts(vals, edges);
        % Normalizza
        if sum(counts)>0
            counts = counts / sum(counts);
        end
        counts = counts(kept_bins{d}); % Ora kept_bins{d} = tutti i bin
        feat_vec = [feat_vec, counts];
    end
    features{img} = feat_vec;
end

end
