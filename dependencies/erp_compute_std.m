function [STUDY, erp_data, erp_times] = erp_compute_std(STUDY, ALLEEG, chan_label, ...
                                                  filter, trange)

% chan_label
if ischar(chan_label); chan_label = {chan_label}; end
% filter

% trange

[STUDY, erp_data, erp_times] = std_erpplot(STUDY, ALLEEG, ...
                                           'channels', chan_label, ...
                                           'filter', lowpass, ...
                                           'timerange', trange, ...
                                           'noplot', 'on', ...
                                           'averagechan', 'on');
