function [ Pa ] = get_lc_prob(Xy, Xa, Vy, Va , LW)

%���Ƴ�����������
LW=LW;
if Xy>Xa%Ŀ�공��Ϊ��೵��
    delta_x=Xy-Xa;
    Pa=min(1,max(0,(LW-delta_x)/LW*1));
elseif Xy<Xa%Ŀ�공��Ϊ�Ҳ೵��
    delta_x=Xa-Xy;
    Pa=min(1,max(0, (LW-delta_x)/LW*1));
else
    Pa=0;
end

end