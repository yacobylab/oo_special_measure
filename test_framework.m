%
try
  dbquit
catch
end
clear all;
a=instrfind;
try
  fclose(a);
catch
end
global smdata;
smdata=smdata_class;
smdata.inst.Count1=smc_test('Count1'); 
smdata.inst.Count2=smc_test('Count2'); 
smdata.channels=[smchannel('foo','Count1','test'), smchannel('bar','Count2','test'), smchannel('ramp','Count1','ramp_test')]; %,smchannel('Time',smdata.inst{3},1)];
%smdata.sminitdisp;
fprintf('Done\n');

%% Test setting
fprintf('1 channel set\n');
smset(1,0);
assert(cell2mat(smget(1)) == 0);
smset(1,1);
assert(cell2mat(smget(1))==1);
fprintf('2 channel set\n');
smset([1 2],1);
assert(cell2mat(smget(2))==1);
smset([1 2],0);
assert(cell2mat(smget(1))==0);
assert(cell2mat(smget(2)) == 0);
fprintf('2 channel different set\n');
smset([1 2],[3 4]);
assert(cell2mat(smget(1))==3);
assert(cell2mat(smget(2)) == 4);
fprintf('String set\n');
smset({'foo','bar'},6);
assert(cell2mat(smget('bar')) == 6);
fprintf('Done\n');

%% Test step-ramping
fprintf('Ramping\n');
smset('ramp',0);
r=smchanlookup('ramp');
r.ramprate=1;
tic;
smset('ramp',1);
if(abs(toc-1) > 0.00001);
  fprintf('Ramp was expected to take 1 second; it took %g\n',toc);
end
fprintf('Done\n');

%% Test time
fprintf('Time test\n');
assert(abs(cell2mat(smget('Time'))-now) < 1e-3);
fprintf('Done\n');

%% Test dmm
vmi=length(smdata.inst)+1;
smdata.inst{vmi}=smc_DMM('vm',visa('NI','USB0::0x0957::0x0607::MY47020346::INSTR'));
smdata.inst{vmi}.open;
smdata.channels(end+1:end+2)=[smchannel('VM',smdata.inst{vmi},1),smchannel('Buf',smdata.inst{vmi},2)];
%%
smdata.sminitdisp;
vm=smdata.inst{vmi};
vm.bufconfig(10,10);
vm.arm;
vm.trigger;
a=smget('Buf');
assert(size(a{1},2)==10);




