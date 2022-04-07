function [acceleration] = IDM(veh_type1, veh_speed, front_speed, front_gap)
%���룺�����ٶȡ�ǰ���ٶȡ�ǰ�����
%������������ٶ�

%IDM����- ������2�У��ֱ��Ӧ��2�ֳ�������
net_dist=[0.8,1]; %ͣ����ࣨm��
reac_time=[1.2,1.8]; %��Ӧʱ�䣨s��
desire_speed=[30,25]; %�����ٶȣ�m/s��
max_acc=[4.0,3.5]; %�����ٶȣ�m/s2��
comfort_dec=[2.0,1.5]; %���ʼ��ٶȣ�m/s2��

%IDM��ʽ
desire_dist=net_dist(veh_type1)+2*sqrt(veh_speed/desire_speed(veh_type1))+...
    reac_time(veh_type1)*veh_speed+veh_speed*(veh_speed-front_speed)/2/sqrt(max_acc(veh_type1)*comfort_dec(veh_type1));
acceleration=max_acc(veh_type1)*(1-power(veh_speed/desire_speed(veh_type1),4)-power(desire_dist/front_gap,2));
                    
end