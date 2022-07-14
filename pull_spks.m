function spks = pull_spks(unit_info, ss, varargin)

% Jake Westerberg
% Vanderbilt University
% jakewesterberg@gmail.com

% defaults
spks.fs = 1000; % at or below 1000
spks.pre_dur = 1;
spks.on_dur = 1;
spks.off_dur = 1;

varStrInd = find(cellfun(@ischar,varargin));
for iv = 1:length(varStrInd)
    switch varargin{varStrInd(iv)}
        case {'-f','fs','sampling_frequency'}
            spks.fs = varargin{varStrInd(iv)+1};
        case {'-pred', 'pre_dur'}
            spks.pre_dur = varargin{varStrInd(iv)+1};
        case {'-ond', 'on_dur'}
            spks.on_dur = varargin{varStrInd(iv)+1};
        case {'-offd', 'off_dur'}
            spks.off_dur = varargin{varStrInd(iv)+1};
    end
end

%% Create GLO trial data
for i = 1 : ss.total_trials
    pre_spks{i}         = unit_info.spk_times(unit_info.spk_times>ss.on(i)-spks.pre_dur & unit_info.spk_times<=ss.on(i)) - ss.on(i);
    pre_spkids{i}       = unit_info.spk_unit(unit_info.spk_times>ss.on(i) -spks.pre_dur & unit_info.spk_times<=ss.on(i));
    on_spks{i}          = unit_info.spk_times(unit_info.spk_times>ss.on(i) & unit_info.spk_times<=ss.on(i)+spks.on_dur) - ss.on(i);
    on_spkids{i}        = unit_info.spk_unit(unit_info.spk_times>ss.on(i) & unit_info.spk_times<=ss.on(i)+spks.on_dur);

    % this current version corrects and aligns to off responses. For direct
    % comparisons, it is important to consider this is 'stiched' rather
    % than continuous. This should not be a worry for pre to on where they
    % use the same alignment point, it is only a concern for on to off
    off_spks{i}         = unit_info.spk_times(unit_info.spk_times>ss.off(i) & unit_info.spk_times<=ss.off(i)+spks.off_dur) - ss.off(i);
    off_spkids{i}       = unit_info.spk_unit(unit_info.spk_times>ss.off(i) & unit_info.spk_times<=ss.off(i)+spks.off_dur);
end

pre_spks_conv = single(nan(unit_info.total, spks.fs*spks.pre_dur, ss.total_trials));
on_spks_conv = single(nan(unit_info.total, spks.fs*spks.on_dur, ss.total_trials));
off_spks_conv = single(nan(unit_info.total, spks.fs*spks.off_dur, ss.total_trials));
for i = 1:unit_info.total
    for j = 1:ss.total_trials
        t_vec_pre = zeros(1,1000*spks.pre_dur);
        t_vec_on = zeros(1,1000*spks.on_dur);
        t_vec_off = zeros(1,1000*spks.off_dur);

        t_vec_pre(ceil(pre_spks{j}(pre_spkids{j}==i)*1000 + spks.pre_dur*1000)) = 1;
        t_vec_on(ceil(on_spks{j}(on_spkids{j}==i)*1000)) = 1;
        t_vec_off(ceil(off_spks{j}(off_spkids{j}==i)*1000)) = 1;

        t_vec_pre = spks_conv(t_vec_pre, spks_kernel('psp'));
        t_vec_on = spks_conv(t_vec_on, spks_kernel('psp'));
        t_vec_off = spks_conv(t_vec_off, spks_kernel('psp'));

        pre_spks_conv(i,:,j) = single(t_vec_pre(1:(1000/spks.fs):end) .* 1000);
        on_spks_conv(i,:,j) = single(t_vec_on(1:(1000/spks.fs):end) .* 1000);
        off_spks_conv(i,:,j) = single(t_vec_off(1:(1000/spks.fs):end) .* 1000);
    end
end

spks.conv = cat(2,pre_spks_conv,on_spks_conv,off_spks_conv);

end