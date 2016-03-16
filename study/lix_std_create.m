function lix_std_create(p)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in = p.dir.backproj;
% in = '/home/lix/Documents/data/yang_all/backprojsets';
ou = p.dir.std;
% ou = fullfile(in, 'study');
if ~exist(ou, 'dir'); mkdir(ou); end

study = p.std;
nvar = study.nvar; % number of variables
name_of_study = study.name_study;
name_of_task = study.name_task;
note_of_study = study.note_study;
dipselect = study.dipselect;
inbrain = study.inbrain;
tmp = dir(fullfile(in, '*.set'));
setname = natsort({tmp.name});
setname_prefix = get_prefix(setname, 1);
% good_subj = {'chenfang', ...
% 		'chenyanqiu',...
% 		'cuishilin',...
% 		'huniping',...
% 		'jiaming',...
% 		'liangnian',...
%             'liushuang',...
%             'liuxuemei',...
%             'liuyanan',...
%             'liyuhong',...
%             'longfan',...
%             'mazhen',...
%             'pujianyong',...
%             'suqiuying',...
%             'wangdan',...
%             'wujun',...
%             'xujin',...
%             'yuanbingtao',...
%             'yuanjianmei',...
%             'yueliang',...
%             'zengmaoxiang',...
%             'zhangting',...
%             'zhangyandi',...
%             'zhaoxiao',...
%             'zhoujiahua'};
good_subj = {'liuxuemei', 'chenfang', 'jiaming', 'liushuang', ...
             'suqiuying', 'wangdan', 'liangnian', 'zhangting', ...
             'liuyuhong', 'zhaoxiao', 'yuanbingtao', 'zhaoyandi', ...
             'zhoujiahua', 'liuyanan', 'wujun', 'yuanjianmei', ...
             'huniping'};
good_ind = ismember(setname_prefix, good_subj);
setname = setname(good_ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load sets
ALLEEG = []; EEG = []; STUDY = [];
EEG = pop_loadset('filename', setname, 'filepath', in);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'study',0);

[sb, sb_remain] = strtok(setname, '_');
[con, con_remain] = strtok(sb_remain, '_');
[grp, grp_remain] = strtok(con_remain, '_');
% create studycommands cell arrays
studycommands = cell(size(setname));
switch nvar
case 0
	for i = 1:numel(setname)
		studycommands{i} = {'index', i, ...
				    'subject', sb{i}};
	end	
case 1
	for i = 1:numel(setname)
		studycommands{i} = {'index', i, ...
				    'subject', sb{i}, ...
				    'condition', con{i}};
	end	
case 2
	for i = 1:numel(setname)
		studycommands{i} = {'index', i, ...
				    'subject', sb{i}, ...
				    'condition', con{i}, ...
				    'group', grp{i}};
	end
end
if ~isempty(inbrain) && ~isempty(dipselect)
	studycommands = {studycommands{:}, {'inbrain', inbrain, 'dipselect', dipselect}};
end

[STUDY ALLEEG] = std_editset( STUDY, ALLEEG, ...
				'name', name_of_study, ...
				'task', name_of_task, ...
				'notes', note_of_study, ...
				'commands', studycommands, ...
				'updatedat', 'on');

STUDY = pop_savestudy(STUDY, EEG, 'filename', name_of_study, 'filepath', ou);


