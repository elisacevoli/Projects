function im_fin = INVERT_IMG(im)
% im = imread(img);
mod = length(size(im));
switch mod
    case 3
        [r, c, v] = size(im);
        im_out = zeros(r,c,v);
    case 2
        [r, c] = size(im);
        im_out = zeros(r,c);
end
% caso 2 : grayscale
%caso 3 : rgb

for i=1:c
    switch mod
        case 3
            im_out(:,i,:) = im(:,c-i+1,:);
        case 2
            im_out(:,i) = im(:,c-i+1);
    end
end

switch mod
    case 3
        im_fin = uint8(im_out);
    case 2
        im_fin = im_out;
end
end