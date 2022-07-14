function plot_rndctl_iglo(i, glo_info, glo_spks, varargin); hold on;

be = 0.05;
ss = 5;

varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-be','bl_epoch'}
            be = varargin{varStrInd(iv)+1};
        case {'-ss', 'smoothing_span'}
            ss = varargin{varStrInd(iv)+1};
    end
end

bl_epoch = (glo_spks.pre_dur*glo_spks.fs-be*glo_spks.fs):(glo_spks.pre_dur*glo_spks.fs);
onoff_epoch = (glo_spks.pre_dur*glo_spks.fs+1):(glo_spks.pre_dur+glo_spks.on_dur+glo_spks.off_dur)*glo_spks.fs;
pres_epoch = (-1* glo_spks.pre_dur*1000) + 1000/glo_spks.fs : ...
    1000/glo_spks.fs : ...
    (((glo_spks.on_dur + glo_spks.off_dur)*1000)*4);

ilo = baseline_correct([ squeeze(glo_spks.conv(i,:,find(glo_info.ilo_rndctl)-3)); ...
                        squeeze(glo_spks.conv(i,onoff_epoch,find(glo_info.ilo_rndctl)-2)); ...
                        squeeze(glo_spks.conv(i,onoff_epoch,find(glo_info.ilo_rndctl)-1)); ...
                        squeeze(glo_spks.conv(i,onoff_epoch,find(glo_info.ilo_rndctl)))], ...
                        bl_epoch);

[m,l,u] = confindence_interval(double(ilo));
plot_ci(smooth(l,ss),smooth(u,ss),pres_epoch,[.5 0 0],.25)
iLocal = plot(pres_epoch,smooth(m,ss),'linewidth',2,'color',[.5 0 0]);


igo = baseline_correct([ squeeze(glo_spks.conv(i,:,find(glo_info.igo_rndctl)-3)); ...
                        squeeze(glo_spks.conv(i,onoff_epoch,find(glo_info.igo_rndctl)-2)); ...
                        squeeze(glo_spks.conv(i,onoff_epoch,find(glo_info.igo_rndctl)-1)); ...
                        squeeze(glo_spks.conv(i,onoff_epoch,find(glo_info.igo_rndctl)))], ...
                        bl_epoch);

[m,l,u] = confidence_interval(double(igo));
plot_ci(smooth(l,ss),smooth(u,ss),pres_epoch,[0 .9 0],.25)
iGlobal = plot(pres_epoch,smooth(m,ss),'linewidth',2,'color',[0 .9 0]);

legend([iLocal,iGlobal],{'iLocal','iGlobal'},'location','northwest', 'box', 'on')
set(gca,'XLim',[(-1* glo_spks.pre_dur*1000) (glo_spks.on_dur*1000 + glo_spks.off_dur*1000)*4])
title('Inverse GLO in Random Control')

end