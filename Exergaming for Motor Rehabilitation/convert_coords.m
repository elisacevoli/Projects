function [new_Xs,new_Ys] = convert_coords(Xs,Ys,toScaleX,toScaleY,fromScaleX,fromScaleY)
        Xratio = double(toScaleX) / double(fromScaleX);
        Yratio = double(toScaleY) / double(fromScaleY);
        new_Xs = Xs * Xratio;
        new_Ys = Ys* Yratio;
    end