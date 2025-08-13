function [descr_maps, descr_names] = descriptors_primary_derived(Z)
% Calcola istogrammi normalizzati a nbins per i descrittori geometrici primari (E, S, C, H, K)
% e per una selezione di derivati specificati dall'utente
% Z: matrice di profondità/superficie
%
% Output:
%   features: vettore feature compatte (solo istogrammi concatenati)
%   feature_names: cell array con i nomi delle feature

    % --- Calcolo descrittori geometrici primari ---
    ZX = gradient(Z); ZX = movmean(ZX, 3, 1); ZX = movmean(ZX, 3, 2);
    ZY = gradient(Z')'; ZY = movmean(ZY, 3, 1); ZY = movmean(ZY, 3, 2);
    ZXX = gradient(ZX); ZXX = movmean(ZXX, 3, 1); ZXX = movmean(ZXX, 3, 2);
    ZYY = gradient(ZY')'; ZYY = movmean(ZYY, 3, 1); ZYY = movmean(ZYY, 3, 2);
    ZXY = gradient(ZX')'; ZXY = movmean(ZXY, 3, 1); ZXY = movmean(ZXY, 3, 2);

    % Coefficienti forme fondamentali e curvature
    E = 1 + ZX.^2;
    e = ZXX ./ sqrt(1 + ZX.^2 + ZY.^2);
    g = ZYY ./ sqrt(1 + ZX.^2 + ZY.^2);
    F = ZX .* ZY;
    Gm = 1 + ZY.^2;
    f = ZXY ./ sqrt(1 + ZX.^2 + ZY.^2);
    H = (e.*Gm - 2.*f.*F + g.*E) ./ (2*(E.*Gm - F.^2));
    K = (e.*g - f.^2) ./ (E.*Gm - F.^2);
    delta = sqrt(H.^2 - K);
    k1 = H + delta;
    k2 = H - delta;
    S = (-2/pi) .* atan((k1 + k2) ./ (k1 - k2));
    C = sqrt((k1.^2 + k2.^2) / 2);

    window = 5;

    descr_names = {};
    descr_maps = {};

    % --- Descrittori primari ---
    prim_names = {'S','C'};
    prim_descr = { S, C};
    for i = 1:numel(prim_names)
        descr_names{end+1} = prim_names{i};
        descr_maps{end+1} = prim_descr{i};
    end

    % --- Derivati richiesti ---
  
    % mean_g, median_g, sin_g, atan_g
    descr_names{end+1} = 'mean_g';
    descr_maps{end+1} = movmean(g, window, 'Endpoints', 'shrink');
    descr_names{end+1} = 'median_g';
    descr_maps{end+1} = medfilt2(real(g), [window window], 'symmetric');
    descr_names{end+1} = 'sin_g';
    descr_maps{end+1} = sin(g);
    descr_names{end+1} = 'atan_g';
    descr_maps{end+1} = atan(g);

    % median_H 
    descr_names{end+1} = 'median_H';
    descr_maps{end+1} = medfilt2(real(H), [window window], 'symmetric');
    % atan_e, sin_e
    descr_names{end+1} = 'atan_e';
    descr_maps{end+1} = atan(e);
    descr_names{end+1} = 'sin_e';
    descr_maps{end+1} = sin(e);

    %atanG, lnE
    descr_names{end+1} = 'atan_G';
    descr_maps{end+1} = atan(Gm);
    descr_names{end+1} = 'ln_E';
    descr_maps{end+1} = log(abs(E) + eps);

  
end
