%   ����·������������ͨ������DEMO
%
%	�漰�Ľ�ͨ�������ݰ�����
%	�������ɣ��������/������ʼ����������ɾ����
%	����ģ�͡�����ģ�ͣ���������/����ѡ��/��϶ѡ��/����ִ�У�
%
%   ����������ѯ��ye_yingjun@qq.com
%
%	Copyright (c) TOPS GROUP

%% ģ��1�������������
sim_reso=0.1;%���澫�� (s)
sim_period=900; %����ʱ����s��
ramp_flow=[600*ones(1,sim_period)];% ��������: Сʱ����*(1,����ʱ��)
exp_flow=[600*ones(1,sim_period)];% ��λ��Сʱ����-veh/h/ln ����ʱ��-s
% ramp_flow=[600*ones(1,200),900*ones(1,200),1200*ones(1,200),800*ones(1,300)];% ��������: Сʱ����*(1,����ʱ��)
% exp_flow=[800*ones(1,200),1000*ones(1,200),1000*ones(1,200),600*ones(1,300)];% ��λ��Сʱ����-veh/h/ln ����ʱ��-s

%��·���ã�Ŀǰ��ʱ��֧���޸�
global expw_num ramp_num lane_width
expw_num=3; %�߿���·���߳�������
ramp_num=1; %�ѵ�����
lane_width=4;%�������(m)
lane_speed_limit=[80,80,100,120]./3.6;%�������٣����⵽�ڣ� km/h

%��������
global veh_type
veh_type=struct('veh_width',{},'veh_length',{},'veh_ratio',{}); %��������: 1-car, 2-bus
veh_type(1).veh_width=1.8;%�������(m)
veh_type(1).veh_length=4;%��������(m)
veh_type(1).veh_ratio=0.95;%�������ͱ���
veh_type(2).veh_width=2;%(m)
veh_type(2).veh_length=10;%(m)
veh_type(2).veh_ratio=0.05;

i=0; %����֡��
lane_num=expw_num+ramp_num;%��������
flow_input=[ramp_flow;exp_flow;exp_flow;exp_flow]; %���߲�ͬ������
hdw=zeros(lane_num,1);%headway��ͷʱ��
veh_num=zeros(lane_num,1);
frame_last_veh=zeros(lane_num,1);
global lanes %1-�������, 2-λ��, 3-�ٶ�, 4-���ٶ� 5-�������� %6-������־(0-������ 1-���� 2-����)
lanes=cell(lane_num,1);
expw_veh_id=1; %��ʼ�ĳ������, ���������ĳ������α��2,3,4,...
start_pos=150;
lc_record=[];


%% ��ʼ���棬��ÿһ֡���е�������
while(i*sim_reso<sim_period)
    lanes0=lanes;

    for k=1:4
        %% ģ��2����������ģ��
        if (i==0 || (~isempty(lanes{k,1}) && veh_num(k)~=sum(lanes{k,1}(:,1)>0)))  %�ڷ��濪ʼ���������ɳ�������Ҫ������һ������ʱ����
            hdw(k)=Rand_Hdw(flow_input(k,ceil((i+1)*sim_reso)));
            frame_last_veh(k)=i;
        end
        if (~isempty(lanes{k,1}))
            veh_num(k)=sum(lanes{k,1}(:,1)>0);
        end

        if (i-frame_last_veh(k)<hdw(k)*10)
            i=i+1;
        else
            % �����µĳ���
            if k<lane_num && rand()>veh_type(1).veh_ratio
                veh_type0=2; %bus
            else
                veh_type0=1; %car
            end
            if isempty(lanes{k,1})
                if k==1 %���ѵ��б��ĩ�����һ����ֹ�ĳ������������ݸ���ģ��δ��ɻ�����ѵ�������ͣ���ѵ�ĩ��
                    lanes{k,1}=[lanes{k,1};[10000,405,0,0,1,0];[expw_veh_id,0,lane_speed_limit(k),0,veh_type0,0]]; 
                else
                    lanes{k,1}=[lanes{k,1};[expw_veh_id,200+100*rand(),lane_speed_limit(k),0,veh_type0,0]];
                end
            else %�����ɵĳ��������б����
                if lanes{k,1}(end,2)-start_pos>2*veh_type(lanes{k,1}(end,5)).veh_length
                    lanes{k,1}=[lanes{k,1};[expw_veh_id,start_pos,lanes{k,1}(end,3),0,veh_type0,0]];
                else % �������ӵ�����ӵ�·����㣬�������ɵĳ����ں��Ŷ�
                    lanes{k,1}=[lanes{k,1};[expw_veh_id,lanes{k,1}(end,2)-2*veh_type(lanes{k,1}(end,5)).veh_length,lanes{k,1}(end,3),0,veh_type0,0]];%lanes{k,1}(end,3)+rand()
                end
            end
            veh_traj{expw_veh_id,1}=[];
            expw_veh_id=expw_veh_id+1;
        end
        
       %% ģ��3����������ģ��
        if (~isempty(lanes{k,1}))

            lanes{k,1}(1,2)=lanes{k,1}(1,2)+lanes{k,1}(1,3)*sim_reso;
            if (length(lanes{k,1}(:,1))>1)
                for j=2:length(lanes{k,1}(:,1))
                    % ����ģ��: ������IDM(���������滻)
                    veh_type0 = lanes{k,1}(j,5);
                    veh_id = lanes{k,1}(j,1);
                    veh_pos = lanes{k,1}(j,2);
                    veh_speed = lanes{k,1}(j,3);
                    front_speed = lanes{k,1}(j-1,3);
                    front_gap = lanes{k,1}(j-1,2)-lanes{k,1}(j,2)-veh_type(lanes{k,1}(j-1,5)).veh_length;
                    new_veh_acc=IDM(veh_type0, veh_speed, front_speed, front_gap); %TODO���˴������ж�IDM�������滻������GM/Gippsģ�ͣ������ؼ��ٶ�
                    if veh_speed+new_veh_acc*sim_reso<0
                        new_veh_acc=(0-veh_speed)/sim_reso;
                        new_veh_speed=0;  % ���⵹��
                    else
                        if veh_speed+new_veh_acc*sim_reso>lane_speed_limit(k)
                            new_veh_acc=(lane_speed_limit(k)-veh_speed)/sim_reso;
                            new_veh_speed=lane_speed_limit(k); % ��������
                        else
                            new_veh_speed=veh_speed+new_veh_acc*sim_reso;
                        end
                    end
                    new_veh_pos=max(veh_pos+veh_speed*sim_reso+0.5*new_veh_acc*sim_reso*sim_reso,veh_pos);
                    if new_veh_pos>450
                        lanes{k,1}(j,1)=0; % ���������ʻ��·���յ㣬�����ű��Ϊ0������ͳһɾ��
                    end
                    lanes{k,1}(j,2)=new_veh_pos;
                    lanes{k,1}(j,3)=new_veh_speed;
                    lanes{k,1}(j,4)=new_veh_acc;
                    
                    % ����ģ�� ��Line126~185��
                    veh_pos = lanes{k,1}(j,2);
                    veh_speed = lanes{k,1}(j,3);
                    veh_lc_flag = lanes{k,1}(j,6);
                    front_lc_flag = lanes{k,1}(j-1,6);
                    if (veh_lc_flag==0 && veh_pos>50 && lanes{k,1}(j,1)~=0 && front_lc_flag==0)%isempty(veh_traj{lanes{k,1}(j-1,1),1})
                        surr_vehs=find_surr(k,j);%�����ڳ���ǰ�󳵣�����һ��4*2�ľ����京������
                        %index1:1-��ǰ; 2-���; 3-��ǰ; 4-�Һ�
                        %index2:1-����; 2-�ٶ�
                        lf_gap=surr_vehs(1,1); lf_speed=surr_vehs(1,2);
                        lb_gap=surr_vehs(2,1); lb_speed=surr_vehs(2,2);
                        rf_gap=surr_vehs(3,1); rf_speed=surr_vehs(3,2);
                        rb_gap=surr_vehs(4,1); rb_speed=surr_vehs(4,2);
                        
                        if k<=ramp_num %�ѵ�MLC
                            %MLC_gap MLC���ٽ��϶ lf-��ǰ; lb-���; rf-��ǰ; rb-�Һ�
                            ramp_rest_length = lanes{1,1}(1,2)-lanes{k,1}(j,2); %���������ѵ��յ㣨ǿ�ƻ����㣩�ľ���
                            MLC_gap_lf=1+0.15*2.237*max(0,veh_speed-lf_speed)+0.3*2.237*min(0,veh_speed-lf_speed)+0.2*2.237*veh_speed+0.1*2.237*(1-exp(-0.008*ramp_rest_length))+randn();
                            MLC_gap_rf=1+0.15*2.237*max(0,veh_speed-rf_speed)+0.3*2.237*min(0,veh_speed-rf_speed)+0.2*2.237*veh_speed+0.1*2.237*(1-exp(-0.008*ramp_rest_length))+randn();
                            MLC_gap_lb=1.5+0.1*2.237*max(0,lb_speed-veh_speed)+0.35*2.237*min(0,lb_speed-veh_speed)+0.25*2.237*lb_speed+0.1*2.237*(1-exp(-0.008*ramp_rest_length))+1.5*randn();
                            MLC_gap_rb=1.5+0.1*2.237*max(0,rb_speed-veh_speed)+0.35*2.237*min(0,rb_speed-veh_speed)+0.25*2.237*rb_speed+0.1*2.237*(1-exp(-0.008*ramp_rest_length))+1.5*randn();
                            if veh_pos>200 %��ʾλ�ڼ��ٳ�����
                                if ((front_speed<lf_speed-10/3.6 || ramp_rest_length<100+50*rand()) ... %MLC-�ٻ���������Ŀ�공��ǰ���ٶȸ��ڱ���10km/h���ϣ��Ҿ�����ٳ���ĩ��С��100m��
                                        && lf_gap>MLC_gap_lf && lb_gap>MLC_gap_lb) %MLC-�ۼ�϶ѡ��
                                    lanes{k,1}(j,6)=1;
                                    veh_traj{veh_id,1}=LC_traj(k,j);%MLC-�ܻ���ִ��
                                    lc_record=[lc_record;[veh_id,k,k+1]];
                                end
                            end
                        else %����DLC
                            %DLC_gap DLC���ٽ��϶ lf-��ǰ; lb-���; rf-��ǰ; rb-�Һ�
                            DLC_gap_lf=1+0.2*2.237*max(0,veh_speed-lf_speed)+0.35*2.237*min(0,veh_speed-lf_speed)+0.25*2.237*veh_speed+randn();
                            DLC_gap_rf=1+0.2*2.237*max(0,veh_speed-rf_speed)+0.35*2.237*min(0,veh_speed-rf_speed)+0.25*2.237*veh_speed+randn();
                            DLC_gap_lb=1.5+0.15*2.237*max(0,lb_speed-veh_speed)+0.45*2.237*min(0,lb_speed-veh_speed)+0.30*2.237*lb_speed+1.5*randn();
                            DLC_gap_rb=1.5+0.15*2.237*max(0,rb_speed-veh_speed)+0.45*2.237*min(0,rb_speed-veh_speed)+0.30*2.237*rb_speed+1.5*randn();
                            
                            front_pos = lanes{k,1}(j-1,2);
                            front_type = lanes{k,1}(j-1,5);
                            if (front_type==2 && front_pos-veh_pos<2*veh_speed && front_speed<lf_speed...%DLC-�١ﻻ������1�����ǰ���Ǵ��ͳ���,���󳵵�ǰ���ٶȸ��ڵ�ǰ����ǰ���ٶ�
                                    && lf_gap>DLC_gap_lf && lb_gap>DLC_gap_lb) %DLC-�ۡ��϶ѡ��������϶������ֵ���ͻ���
                                lanes{k,1}(j,6)=1;
                                veh_traj{veh_id,1}=LC_traj(k,j); %DLC-�ܻ���ִ�У����ɻ����켣��
                                lc_record=[lc_record;[veh_id,k,k+1]];
                            elseif (front_type==2 && front_pos-veh_pos<2*veh_speed && front_speed<rf_speed ...%DLC-�ڳ���ѡ�񣺸߿���·�ȿ�������໻����Ȼ���ٿ����Ҳ�
                                    && rf_gap>DLC_gap_rf && rb_gap>DLC_gap_rb)
                                lanes{k,1}(j,6)=2;
                                veh_traj{veh_id,1}=LC_traj(k,j);
                                lc_record=[lc_record;[veh_id,k,k-1]];
                            end
                            
                            if (lanes{k,1}(j,6)==0 && veh_speed<lane_speed_limit(k)-20/3.6 && front_speed<veh_speed*0.8 && front_speed<lf_speed-10/3.6 ...%DLC-�ٻ�������2��ǰ���ٵ��������ٶ�20km/h���£���ǰ���ٶȱȱ����ٶȵ�20%��Ŀ�공��ǰ���ٶȸ��ڱ�����ǰ��10km/h����
                                    && lf_gap>DLC_gap_lf && lb_gap>DLC_gap_lb) %DLC-�ۼ�϶ѡ��������϶������ֵ���ͻ���
                                lanes{k,1}(j,6)=1;
                                veh_traj{veh_id,1}=LC_traj(k,j); %DLC-�ܻ���ִ��
                                lc_record=[lc_record;[veh_id,k,k+1]];
                            elseif (lanes{k,1}(j,6)==0 && veh_speed<lane_speed_limit(k)-20/3.6&& front_speed<veh_speed*0.8 &&front_speed<rf_speed-10/3.6 ...
                                    && rf_gap>DLC_gap_rf && rb_gap>DLC_gap_rb) %�Ҳ�ͬ��
                                lanes{k,1}(j,6)=2;
                                veh_traj{veh_id,1}=LC_traj(k,j);
                                lc_record=[lc_record;[veh_id,k,k-1]];
                            end
                        end
                    end
                end
            end
            lanes{k,1}=lanes{k,1}(lanes{k,1}(:,1)>0,:); % % ɾ�����Ϊ0������������ʻ��·���ᱻ��Ϊ0 �� Line116��
        end
       %% ģ��4��������
        % ������ӻ����������ߣ����ٳ�������200m��
        if (~isempty(lanes0{k,1}))
            line([50 200],[-lane_width*6 0],'Color','k');hold on;
            line([50 200],[-lane_width*6-lane_width/cos(tanh(lane_width/25)) -lane_width],'Color','k');hold on;
            line([200 400],[-lane_width -lane_width],'Color','k');hold on;
            line([400 410],[-lane_width 0],'Color','k');hold on;
            line([0 200],[0 0],'Color','k');hold on;
            line([410 600],[0 0],'Color','k');hold on;
            line([200 410],[0 0],'linestyle',':','Color','k');hold on;
            line([0 600],[lane_width lane_width],'linestyle',':','Color','k');hold on;
            line([0 600],[lane_width*2 lane_width*2],'linestyle',':','Color','k');hold on;
            line([0 600],[lane_width*3 lane_width*3],'Color','k');hold on;
            text(400, -60, ['simulation time: ',num2str(i/10), ' s']);
            
            % �����泵��
            for j=length(lanes0{k,1}(:,1)):-1:1
                if lanes0{k,1}(j,6)==0
                    if (k==1 && lanes0{k,1}(j,2)>50 && lanes0{k,1}(j,2)<405)
                        if lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length>200  %���ٳ�������
                            h=rectA(lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length,(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2-lane_width,veh_type(lanes0{k,1}(j,5)).veh_length,veh_type(lanes0{k,1}(j,5)).veh_width,0);
                        else %�ѵ���������б��
                            h=rectA(lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length,4/25*(lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length)-32-(lane_width+veh_type(lanes0{k,1}(j,5)).veh_width)/2,veh_type(lanes0{k,1}(j,5)).veh_length,veh_type(lanes0{k,1}(j,5)).veh_width,tanh(4/25));
                        end
                    elseif k==2 %���߳���
                        h=rectA(lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length,(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2,veh_type(lanes0{k,1}(j,5)).veh_length,veh_type(lanes0{k,1}(j,5)).veh_width,0);
                    elseif k==3
                        h=rectA(lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length,(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2+lane_width,veh_type(lanes0{k,1}(j,5)).veh_length,veh_type(lanes0{k,1}(j,5)).veh_width,0);
                    elseif k==4
                        h=rectA(lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length,(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2+lane_width*2,veh_type(lanes0{k,1}(j,5)).veh_length,veh_type(lanes0{k,1}(j,5)).veh_width,0);
                    end
                else
                    if ~isempty(veh_traj{lanes0{k,1}(j,1),1}) && lanes0{k,1}(j,2)<veh_traj{lanes0{k,1}(j,1),1}(end-2,1) %
                        for m=1:length(veh_traj{lanes0{k,1}(j,1),1})-5
                            if veh_traj{lanes0{k,1}(j,1),1}(m,1)<lanes0{k,1}(j,2)
                                continue
                            else
                                %�ڻ��������У��������ѹ�������ߣ�����Ϊ����ͬʱ�����������ĺ󳵲���Ӱ��
                                veh_heading=tanh((veh_traj{lanes0{k,1}(j,1),1}(m+5,2)-veh_traj{lanes0{k,1}(j,1),1}(m,2))/(veh_traj{lanes0{k,1}(j,1),1}(m+5,1)-veh_traj{lanes0{k,1}(j,1),1}(m,1)));
                                
                                if (lanes0{k,1}(j,6)==1 && ceil((veh_traj{lanes0{k,1}(j,1),1}(m,2)+veh_type(lanes0{k,1}(j,5)).veh_width+(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2)/lane_width)+1~=k)
                                    new_lane=ceil((veh_traj{lanes0{k,1}(j,1),1}(m,2)+veh_type(lanes0{k,1}(j,5)).veh_width+(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2)/lane_width)+1;
                                    if ~ismember(lanes0{k,1}(j,1),lanes{new_lane,1}(:,1))
                                        lanes{new_lane,1}(end+1,:)=lanes0{k,1}(j,:);
                                        lanes{new_lane,1}=sortrows(lanes{new_lane,1},-2);
                                        new_order=find(lanes0{new_lane,1}(:,1)==lanes0{k,1}(j,1));
                                    end
                                elseif (lanes0{k,1}(j,6)==2 && ceil((veh_traj{lanes0{k,1}(j,1),1}(m,2)-(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2)/lane_width)+1~=k)
                                    new_lane=ceil((veh_traj{lanes0{k,1}(j,1),1}(m,2)-(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2)/lane_width)+1;
                                    if ~ismember(lanes0{k,1}(j,1),lanes{new_lane,1}(:,1))
                                        lanes{new_lane,1}(end+1,:)=lanes0{k,1}(j,:);
                                        lanes{new_lane,1}=sortrows(lanes{new_lane,1},-2);
                                        new_order=find(lanes0{new_lane,1}(:,1)==lanes0{k,1}(j,1));
                                    end
                                end
                                %�ڻ���ĩ�ڣ����������ȫ����Ŀ�공�����Ͱ���������ԭ����Ų��Ŀ�공����ȥ
                                if (lanes0{k,1}(j,6)==1 && ceil((veh_traj{lanes0{k,1}(j,1),1}(m,2)+(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2)/lane_width)+1~=k)
                                    if k==lc_record(lc_record(:,1)==lanes0{k,1}(j,1),2)
                                        lanes{k,1}(lanes{k,1}(:,1)==lanes0{k,1}(j,1),:)=[];
                                    end
                                elseif (lanes0{k,1}(j,6)==2 && ceil((veh_traj{lanes0{k,1}(j,1),1}(m,2)+veh_type(lanes0{k,1}(j,5)).veh_width-(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2)/lane_width)+1~=k)
                                    if k==lc_record(lc_record(:,1)==lanes0{k,1}(j,1),2)
                                        lanes{k,1}(lanes{k,1}(:,1)==lanes0{k,1}(j,1),:)=[];
                                    end
                                end
                                break
                            end
                        end

                        
                        if (ismember(lanes0{k,1}(j,1),lanes0{lc_record(lc_record(:,1)==lanes0{k,1}(j,1),3),1}(:,1)) && k==lc_record(lc_record(:,1)==lanes0{k,1}(j,1),2)) 
                            continue;
                        else
                            h=rectA(lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length,veh_traj{lanes0{k,1}(j,1),1}(m,2),veh_type(lanes0{k,1}(j,5)).veh_length,veh_type(lanes0{k,1}(j,5)).veh_width,veh_heading);
                        end

                    else
                        h=rectA(lanes0{k,1}(j,2)-veh_type(lanes0{k,1}(j,5)).veh_length,(lane_width-veh_type(lanes0{k,1}(j,5)).veh_width)/2+lane_width*(k-2),veh_type(lanes0{k,1}(j,5)).veh_length,veh_type(lanes0{k,1}(j,5)).veh_width,0);
                        if k==lc_record(lc_record(:,1)==lanes0{k,1}(j,1),3)
                            lanes{k,1}(lanes{k,1}(:,1)==lanes0{k,1}(j,1),6)=0;
                            origin_order=find(lanes{lc_record(lc_record(:,1)==lanes0{k,1}(j,1),2),1}(:,1)==lanes0{k,1}(j,1));
                            if ~isempty(origin_order)
                                lanes{lc_record(lc_record(:,1)==lanes0{k,1}(j,1),2),1}(origin_order,:)=[];
                            end
                            veh_traj{lanes0{k,1}(j,1),1}=[];
                            lc_record(lc_record(:,1)==lanes0{k,1}(j,1),:)=[];
                        end
                    end
                    
                end

                axis([150 450 -100 100]);
            end
        end
    end

    drawnow %��ʾ���ӻ�ͼ��
    clf %���ͼ��
end