function varargout = genemania_tool(varargin)
% GENEMANIA_TOOL MATLAB code for genemania_tool.fig
%      GENEMANIA_TOOL, by itself, creates a new GENEMANIA_TOOL or raises the existing
%      singleton*.
%
%      H = GENEMANIA_TOOL returns the handle to a new GENEMANIA_TOOL or the handle to
%      the existing singleton*.
%
%      GENEMANIA_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENEMANIA_TOOL.M with the given input arguments.
%
%      GENEMANIA_TOOL('Property','Value',...) creates a new GENEMANIA_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before genemania_tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to genemania_tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help genemania_tool

% Last Modified by GUIDE v2.5 30-Jun-2014 12:06:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @genemania_tool_OpeningFcn, ...
                   'gui_OutputFcn',  @genemania_tool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before genemania_tool is made visible.
function genemania_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to genemania_tool (see VARARGIN)

% Choose default command line output for genemania_tool
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

if length(varargin)>0,smp=varargin{1};else,return;end
main_data=get(handles.genemania_tool_root,'UserData');
try
    main_data.numc=feature('numcores');
catch me
    main_data.numc=2;
end
%set Genemania preferences
main_data.genemania_data_dir=fullfile(pwd,'gmdata-2012-08-02');
main_data.output_format='flat';
main_data.rel_gene_limit=0;
main_data.output_dir=pwd;
main_data.main_sample_list=smp.main_sample_list;
main_data.gid=smp.gid;
main_data.gsymb=smp.gsymb;
main_data.pname=smp.pname;
main_data.prank=smp.prank;
main_data.fdr=smp.fdr;
main_data.fc=smp.fc;
main_data.tt=smp.tt;
main_data.pareto_gui_root=smp.pareto_gui_root;
if strcmp(smp.build,'hg19'),main_data.species='H. Sapiens';
elseif strcmp(smp.build,'mm9'),main_data.species='M. Musculus';end
gs{1}=sprintf('Gene : Entrez ID : Screen rank : Screen p-value : Expression fold change : T-test p-value\n');
for i=1:length(main_data.gid)
    gs{i+1}=[sprintf('%s : ',main_data.gsymb{i}),sprintf('%i : ',main_data.gid(i)),...
             sprintf('%i : ',main_data.prank(i)),sprintf('%g : ',main_data.fdr(i)),...
             sprintf('%g : ',main_data.fc(i)),sprintf('%g\n',main_data.tt(i))];
end
set(handles.glist_textbox,'String',gs);
set(handles.genemania_tool_root,'UserData',main_data);
% UIWAIT makes genemania_tool wait for user response (see UIRESUME)
% uiwait(handles.genemania_tool_root);
end

% --- Outputs from this function are returned to the command line.
function varargout = genemania_tool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in build_network_pushbutton.
function build_network_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to build_network_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

main_data=get(handles.genemania_tool_root,'UserData');
outdir=uigetdir(main_data.pname,'Please select a directory where I can save your network.');
if ~outdir,return;end
main_data.output_dir=outdir;
set(handles.genemania_tool_root,'UserData',main_data);
f=fopen(fullfile(outdir,'genemania_query'),'w');
fprintf(f,'%s\n',main_data.species);
for i=1:length(main_data.gsymb)-1
    fprintf(f,'%i\t',main_data.gid(i));
end
fprintf(f,'%i\n',main_data.gid(end));
fprintf(f,'coloc\tgi\tpath\tpi\n');
fprintf(f,'%i\n',main_data.rel_gene_limit);
fprintf(f,'average\n');
fclose(f);
% cmd=['java -d64 -Xmx3G -cp GeneMANIA.jar org.genemania.plugin.apps.QueryRunner',...
%                   ' --data ',main_data.genemania_data_dir,...
%                   ' --out ',main_data.output_format,...
%                   ' --results ',main_data.output_dir,...
%                   ' --threads ',num2str(main_data.numc),...
%                   ' --verbose ',...
%                   fullfile(outdir,'genemania_query') ' ']
%[flg,msg]=system(cmd);

nthds=num2str(main_data.numc);
wait_msg=['Starting GeneMANIA query using ' nthds ' threads.'];
gmCmd = {'java','-d64','-Xmx3G','-cp','GeneMANIA.jar','org.genemania.plugin.apps.QueryRunner',...
                  '--data',main_data.genemania_data_dir,...
                  '--out',main_data.output_format,...
                  '--results',main_data.output_dir,...
                  '--threads',num2str(main_data.numc),...
                  '--verbose',...
                  fullfile(outdir,'genemania_query')};
exit_code=sys(gmCmd,wait_msg)
pause(0.1)
f=fopen(fullfile(outdir,'genemania_query-results.report.txt'));
D=textscan(f,'%s%*[^\n]',1);
while ~strcmpi(D{1}{:},'Gene 1')
    D=textscan(f,'%s%*[^\n]',1,'Delimiter','\t');
end
D=textscan(f,'%s%s%n%s%s%*[^\n]');
[kz,~,ulocs]=unique(D{4});
itcut=0.9;%interaction strength quantile cuttoff for inclusion in net
sample_data=get(main_data.main_sample_list,'UserData');
fclose(f);
nets=containers.Map;%interaction types are keys, sparse adj matrices are data
links=0;
for i=1:length(kz)
    idx=find(ulocs==i);
    D{3}(idx)=D{3}(idx)/max(D{3}(idx));
    hidx=find(D{3}(idx)>quantile(D{3}(idx),itcut));
    idx=idx(hidx);
    src=[];trgt=[];w=[];%store adj matrix, with rows as source cols as target
    for j=1:length(idx)
        %find the index of genes in query in the screen's sample data
        sgid=str2num(D{1}{idx(j)});
        %we may allow genemania to add genes not in query later,
        %genemania currently adds their gene symbols even though we
        %submitted entrez ids
        if isempty(sgid),sidx=min(find(strcmpi(sample_data.gsymb,D{1}{idx(j)})));
        else,sidx=min(find(sgid==sample_data.gid));end
        tgid=str2num(D{2}{idx(j)});
        if isempty(tgid),tidx=min(find(strcmpi(sample_data.gsymb,D{2}{idx(j)})));
        else,tidx=min(find(tgid==sample_data.gid));end
        if ~isempty(sidx)&~isempty(tidx)
            %genemania sometimes produces duplicate edges, sometimes with
            %different weights, we keep the heaviest
            chk_idx=find(sidx==src&tidx==trgt);
            if isempty(chk_idx),src=[src;sidx];trgt=[trgt;tidx];w=[w;D{3}(idx(j))];
            else,w(chk_idx)=max(w(chk_idx),D{3}(idx(j)));end
        end
    end
    nets(kz{i})=sparse(src,trgt,w,length(sample_data.gsymb),length(sample_data.gsymb));
    nets(kz{i})=nets(kz{i})+nets(kz{i})';
    links=links+any(nets(kz{i}));
end
if ~links,alert('String','No interactions between the genes in your list are annotated in my database');return;end
sample_data.nets=nets;
set(main_data.main_sample_list,'UserData',sample_data);
%write network and edge attributes to file
f=fopen(fullfile(outdir,'network_flatfile.sif'),'w');
g=fopen(fullfile(outdir,'edge_attributes.attrs'),'w');
fprintf(g,'InteractionStrength\n');
prog=0;
gidx=[];
h=waitbar(0,'Writing networks to file');
for i=1:length(kz)
    msg='Writing the network to file...';
    waitbar(prog,h,msg);
    N=nets(kz{i});
    [ridx,cidx,vals]=find(tril(N));
    delta=1/length(kz)/length(ridx);
    for j=1:length(ridx)
        fprintf(f,'%s\t',sample_data.gsymb{ridx(j)});
        fprintf(f,'%s\t',kz{i});
        fprintf(f,'%s\n',sample_data.gsymb{cidx(j)});
                
        fprintf(g,'%s ',sample_data.gsymb{ridx(j)});
        fprintf(g,'(%s) ',kz{i});
        fprintf(g,'%s ',sample_data.gsymb{cidx(j)});
        fprintf(g,' = %g\n',vals(j));
        prog=prog+delta;
        waitbar(prog,h,msg);
    end
    gidx=[gidx;ridx;cidx];
end
gidx=unique(gidx);
delete(h)
fclose('all');
%write screen data out as node attributes
h=waitbar(0,'Writing node attributes to file');
f=fopen(fullfile(outdir,'screen_rank.attrs'),'w');
fprintf(f,'ScreenRank\n');
for i=1:length(gidx)
    fprintf(f,'%s = ',sample_data.gsymb{gidx(i)});
    fprintf(f,'%i\n',sample_data.prank(gidx(i)));
end
waitbar(0.25,h,'Wrote screen rank');
fclose(f);
if ~isempty(sample_data.fc)
    f=fopen(fullfile(outdir,'exp_fc.attrs'),'w');
    fprintf(f,'ExpressionFC\n');
    for i=1:length(gidx)
        fprintf(f,'%s = ',sample_data.gsymb{gidx(i)});
        fprintf(f,'%g\n',sample_data.fc(gidx(i)));
    end
    waitbar(0.5,h,'Wrote expression fold change');
    fclose(f);
    f=fopen(fullfile(outdir,'exp_tt.attrs'),'w');
    fprintf(f,'ExpressionTTest\n');
    for i=1:length(gidx)
        fprintf(f,'%s = ',sample_data.gsymb{gidx(i)});
        fprintf(f,'%g\n',sample_data.tt(gidx(i)));
    end
    waitbar(0.75,h,'Wrote expression fold change t-test pvalue');
    fclose(f);
end
f=fopen(fullfile(outdir,'screen_pval.attrs'),'w');
fprintf(f,'ScreenPValue\n');
for i=1:length(gidx)
    fprintf(f,'%s = ',sample_data.gsymb{gidx(i)});
    fprintf(f,'%g\n',sample_data.fdr(gidx(i)));
end
fclose(f);
waitbar(0.9,h,'Wrote screen FDRs');
if isdeployed|~strcmp(outdir,pwd)
    copyfile('pareto_tool_vizmap.props',fullfile(outdir,'pareto_tool_vizmap.props'));
end
delete(h)

    
    
    
    
alert('Title','Genemania query finished','String','Genemania report written!');
end
% --- Executes on selection change in glist_textbox.
function glist_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to glist_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns glist_textbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from glist_textbox
end

% --- Executes during object creation, after setting all properties.
function glist_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to glist_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in vis_net_pushbutton.
function vis_net_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to vis_net_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

main_data=get(handles.genemania_tool_root,'UserData');
if ~isdeployed
    if ismac, cyto_cmd='/Applications/Cytoscape_v3.0.2/cytoscape';
    else, cyto_cmd='/home/aaron/Cytoscape_v3.0.2/cytoscape';end
    if isunix, cyto_cmd=[cyto_cmd,'.sh'];
    else, cyto_cmd=[cyto_cmd,'.bat'];end
else
    cyto_cmd=get(handles.cyto_exe_path,'String');
end
cmd=[cyto_cmd,' -N ',fullfile(main_data.output_dir,'network_flatfile.sif'),...
     ' -T ' fullfile(main_data.output_dir,'edge_attributes.attrs'),...
     ' -T ' fullfile(main_data.output_dir,'screen_rank.attrs'),...
     ' -T ' fullfile(main_data.output_dir,'screen_pval.attrs'),...
     ' -T ' fullfile(main_data.output_dir,'exp_tt.attrs'),...
     ' -T ' fullfile(main_data.output_dir,'exp_fc.attrs'),...
     ' -T ' fullfile(main_data.output_dir,'ordinal_network_centrality.attrs'),...
     ' --vizmap ' fullfile(main_data.output_dir,'pareto_tool_vizmap.props')];
system([cmd]);
end

% --- Executes on button press in comp_cent_pushbutton.
function comp_cent_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to comp_cent_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
max_iter=20;%maximum number of iterations for computing the joint spectrum
h=[];
main_data=get(handles.genemania_tool_root,'UserData');
sample_data=get(main_data.main_sample_list,'UserData');
if ~isfield(sample_data,'nets'),alert('String','Build a gene network first'),return;end
nets=sample_data.nets;
net_cent=containers.Map;%store the dominant eigenvector 
sm_nets=containers.Map;%
sm_net_cent=containers.Map;
kz=nets.keys;
%include_list={'Co-expression','Co-localization','Genetic','Pathway','Physical','Predicted','Shared'};
include_list={'Co-localization','Genetic','Pathway','Physical'};
e=zeros(length(kz),1);
idx=[];%relable the subset of nodes with degree >0
for i=1:length(kz)
    [ridx,cidx]=find(nets(kz{i}));
    idx=union(idx,union(unique(ridx),unique(cidx)));
end
strt=zeros(length(idx),1);
for i=1:length(kz)
    N=nets(kz{i});
    M=zeros(length(idx));%adj. mtx for nodes with deg>0
    [ridx,cidx]=find(N);
    for j=1:length(ridx)
        xidx=find(idx==ridx(j));yidx=find(idx==cidx(j));
        M(xidx,yidx)=N(ridx(j),cidx(j));
    end
    if ismember(kz{i},include_list),sm_nets(kz{i})=M;end
    opts.issym=true;
    [u,v,flg]=eigs(M,1,'la',opts);
    [~,midx]=max(abs(u));
    if u(midx)<0,u=-u;end
    u(find(u<eps))=0;
    strt=strt+u;%start at the centroid of the co-spectrum
    %if strcmp(kz{i},start_key),strt=u;end%start vector for joint spectrum comp
    U=zeros(size(N,1),1);
    U(idx)=u;
    if isfield(sample_data,'net_cent')
        nc2=sample_data.net_cent;
        net_cent(kz{i})=max(U,nc2(kz{i}));
    end
    net_cent(kz{i})=U;%nc;
    sm_net_cent(kz{i})=u;
    e(i)=v;
end
strt=strt/length(kz);
h=waitbar(0,'Computing the joint spectrum');
options = optimset('outputfcn',@outfun,'Display','iter-detailed','Diagnostics','on','Algorithm','sqp','MaxIter',20);
%[y,flag,relres,iter,resvec,lsvec]=lsqr(A,zeros(size(A(:,1))),[],[],[],[],net_cent(kz{1}));
%[y,resnorm,res,exitflg,output,lambda]=lsqnonneg(A,zeros(size(A(:,1))),options)
[y,fval,exitflg,output]=fmincon(@(x) obj_fun(sm_nets,e,x),strt,[],[],[],[],-eps*ones(length(strt),1),[],[],options);
delete(h)
alert('String','Genes have been annotated with their network centrality');
%[y,fval,exitflg,output]=fminunc(@(x) obj_fun(sm_nets,e,x),strt,options)
y(find(y<eps))=0;
gl=length(sample_data.gid);
nc=zeros(gl,1);
nc(idx)=y;
if isfield(sample_data,'net_cent')
    nc2=sample_data.net_cent;
    net_cent('combined')=max(nc,nc2('combined'));
end
net_cent('combined')=nc;
[~,sidx]=sort(nc,'descend');
nco=zeros(size(nc));nco(sidx)=1:gl;
net_cent('ordinal')=nco;
sample_data.net_cent=net_cent;
sample_data.net_cent_comb=net_cent('combined');
set(main_data.main_sample_list,'UserData',sample_data);
if ~isfield(main_data,'output_dir'), return;end
if isempty(main_data.output_dir),return;end
h=waitbar(0,'Writing network centrality annotations to file for visualization');
f=fopen(fullfile(main_data.output_dir,'network_centrality.attrs'),'w');
fprintf(f,'NetworkCentrality\n');
for i=1:length(sample_data.gsymb)
    fprintf(f,'%s = ',sample_data.gsymb{i});
    fprintf(f,'%g\n',nco(i));
end
fclose(f);
kz=net_cent.keys;
for i=1:length(net_cent.keys)
    waitbar(i/length(net_cent.keys),h)
    f=fopen(fullfile(main_data.output_dir,[kz{i} '_network_centrality.attrs']),'w');
    fprintf(f,[kz{i} 'NetworkCentrality\n']);
    nc=net_cent(kz{i});
    for i=1:length(sample_data.gsymb)
        fprintf(f,'%s = ',sample_data.gsymb{i});
        fprintf(f,'%g\n',nc(i));
    end
    fclose(f);
end
delete(h)
alert('String','Network centrality estimates are ready for visualization')
    function stop =outfun(x,optimValues,state)
        stop=false;
        waitbar((optimValues.iteration/max_iter),h)
    end
end



function cyto_exe_path_Callback(hObject, eventdata, handles)
% hObject    handle to cyto_exe_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cyto_exe_path as text
%        str2double(get(hObject,'String')) returns contents of cyto_exe_path as a double

end
% --- Executes during object creation, after setting all properties.
function cyto_exe_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cyto_exe_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function gmloc_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to gmloc_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gmloc_textbox as text
%        str2double(get(hObject,'String')) returns contents of gmloc_textbox as a double
main_data=get(handles.genemania_tool_root,'UserData');
main_data.genemania_data_dir=get(hObject,'String');
end

% --- Executes during object creation, after setting all properties.
function gmloc_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gmloc_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',fullfile(pwd,'gmdata-2012-08-02'));
end