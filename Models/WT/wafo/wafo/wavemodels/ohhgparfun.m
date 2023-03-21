function [A0,B0,C0]= ohhgparfun(Hm0,def,dim)
%OHHGPARFUN Wave height, Hd, distribution parameters for Ochi-Hubble spectra. 
%
% CALL [a b c] = ohhgparfun(Hm0,def,dim)
%
% Hm0 = significant wave height [m].
% def = defines the parametrization of the spectral density (default 1)
%       1 : The most probable spectrum  (default)
%       2,3,...11 : gives 95% Confidence spectra
% dim = 'time'  : Hd distribution parameters in time (default)
%       'space' : Hd distribution parameters in space
%
%  OHHGPARFUN returns the Generalized gamma distribution parameters which
%  approximates the marginal PDF of Hd/Hrms, i.e.,
%  zero-downcrossing wave height, for a Gaussian process with a Bimodal
%  Ochi-Hubble spectral density (ochihubble). The empirical parameters of
%  the model is fitted by least squares to simulated Hd data for 24
%  classes of Hm0. Between 50000 and 150000 zero-downcrossing waves were
%  simulated for each class of Hm0 for DIM=='time'.
%  Between 50000 and 300000 zero-downcrossing waves were
%  simulated for each class of Hm0 for DIM=='space'.
%  OHHGPARFUN is restricted to the following range for Hm0: 
%   0 < Hm0 [m] < 12,  1 <= def < 11, 
% 
%  Example:
%  Hm0 = 6;def = 8;Hrms = Hm0/sqrt(2);
%  [a b c] = ohhgparfun(Hm0,def);
%  h = linspace(0,4*Hrms)'; 
%  f = pdfgengam(h/Hrms,a,b,c)/Hrms;
%  plot(h,f)
% 
%  See also  ohhvpdf, ohhcdf 

% Adapted to  cssmooth  by GL Feb 2011
% History:
% by pab 29.01.2001

%error(nargchk(2,3,nargin))
narginchk(2,3)
persistent OHHGPAR OHHSGPAR
if nargin<3||isempty(dim), dim = 'time';end
if nargin<2||isempty(def), def = 1;end 

if any(Hm0>12| Hm0<=0 )
  disp('Warning: Hm0 is outside the valid range')
  disp('The validity of the parameters returned are questionable')
end

if def>11||def<1 
  warning('DEF is outside the valid range')
  def = mod(def-1,11)+1;
end

pardef =1;
switch pardef
  case 1,
    if strncmpi(dim,'s',1),  % wave height distribution in space
      % pdfgengam distribution parameters as a function of Hm0
      % Best fit by smoothing spline 
      % Then approximate the spline with a rational polynomial
               
      da1={[ -0.00004138090870   0.00109430794436  -0.00269440736780 ...
	      -0.06705897283924  -0.55164440895527],...
	    [0.00004937786498  -0.00134400481142   0.00676573945561 ...
	      0.00208710869648  -0.31102727301470],...
	    [-0.07779895000407  -0.01541613940921],...
	    [0.00012851785795  -0.00714115752747   0.05114781130635 ...
	      -0.17663963262922],...
	    [0.00332180691448  -0.05666446616529   0.31714325506504 ...
	      -0.55816731477282],...
	    [-0.00111352210231   0.00673694644824   0.06414268764116 ...
	      -0.54807790917122],...
	    [-0.00061700196531   0.01149080934720  -0.06699565421063 ...
	      -0.16311703448820],...
	    [-0.00001475352999   0.00040291282700  -0.00295454783865 ...
	      0.00397174812619  -0.01538667731742  -0.33966924696171],...
	    [-0.00001061573392   0.00044435203176  -0.00497643732486 ...
	      0.01467622201442  -0.04568798057552  -0.37832649729316],...
	    [-0.00100368236647   0.00084782401829   0.08554210278523 ...
	      -0.48800043496091],...
	    [-0.00091995034005   0.00636754206764   0.07532818993481 ...
	      -0.66017075731642]};
      da2={     1,...
	    [0.01444657322783  -0.18050127512374   1],...
	    [-0.00000551632145   0.00024179389257  -0.00405951378831 ...
	      0.03460258829729  -0.14499641228538   0.25097182572877 ...
	      1],...	    
	    [0.02094653009449  -0.21580097808702   1],...
	    [0.00000039824156  -0.00001401589784   0.00017538598241 ...
	      -0.00087595887249   0.02173043069134  -0.27896326832222 ...
	      1],...
	    [0.00027793890241   0.01250747301868  -0.22143627593439 ...
	      1],...
	    [0.00018201646553   0.00498464954163  -0.13196545891600 ...
	      1],...
	    [0.01762406173827   1],...
	    [0.01893329704474  -0.14577267850356   1],...
	    [0.00016451696260  -0.00313094910565   0.04262525186595 ...
	      -0.30975235923116   1],...
	    [0.00084470714310  -0.00044404366986  -0.15631462629050 ...
	      1]};
      db1={[   0.00002786726541  -0.00075751430599   0.00223834654260 ...
	      0.01054367751133   0.10539758995860],...
	    [-0.00005472405514  -0.00017765436849  -0.00103888994770 ...
	      0.07270379185212],...
	    [-0.00035828959539  -0.00021346175807   0.03679282545071 ...
	      -0.25646599618411],...
	    [-0.00033639133259   0.00467251743336  -0.01864550369819 ...
	      -0.00578836659867],...
	    [-0.00002567795716   0.00072047013458  -0.00882477037641 ...
	      0.05131654500007  -0.09227600377294  -0.18801238885291],...
	       0.10350498693227,...
	    [  -0.00246180597282   0.02589321523550 ...
	      0.00907312834779],...
	    [-0.00037609466003   0.00450296629496  -0.02220335764921 ...
	      0.03778920247594],...
	    [-0.00003116726300   0.00016129446028  -0.00054419987444 ...
	      -0.00138211697551   0.15107822446509],...
	    [-0.00071749136602   0.01239103711323  -0.06353761070440 ...
	      0.13667553417682],...
	    [-0.00023012665524  -0.00316272717879   0.03161663379982]};
      db2={1,...
	    [0.00630055272128  -0.13060394885807   1],...
	    [0.00675670048886  -0.09157124225316   1],...
	    [0.01447609327850  -0.18780870215326   1],...
	    [0.00012506959353  -0.00399534285493   0.05568791406103 ...
	      -0.37522310581758   1],...
	    [-0.00000889474966   0.00039067088782  -0.00526511202274 ...
	      0.03605007085256  -0.16822575305751   1],...
	    [0.00597564032776  -0.10776631476009   1],...
	    [0.00783990826359  -0.13379412280046   1],...
	    [0.01030151384679  -0.13410883880079   1],...
	    [0.00038948731188  -0.01126916677156   0.12437510447577 ...
	      -0.53570433281264   1],...
	    [0.00665362466697  -0.12269914566155   1]};
      
      dc1={[   0.00002627362126  -0.00063812306976   0.00114120300792 ...
	      0.00886321919773   0.84155790455689],...
	    [-0.00013741465763   0.00700935191663  -0.11536719885091 ...
	      0.86521574098404],...
	    [-0.00032560353126   0.00663077427031  -0.04671406141137 ...
	      0.55889438436586],...
	    [-0.00036432872797   0.01719976738176  -0.17716437338482 ...
	      0.79397122217912],...
	    [-0.07607968213050   0.53647655665311],...
	    [-0.00001755184498   0.00046265130528   0.00480698598445 ...
	      -0.14808812508160   0.84780942084456],...
	    [0.00292089451560  -0.07387219916706   0.84761929045052],...
	    [-0.00044854206584   0.01387594105541  -0.14747232736858 ...
	      0.81184247660099],...
	    [-0.00005017276400   0.00045086394299   0.01172143963145 ...
	      -0.15481844733632   0.91466994240931],...
	    [-0.00083399294307   0.03173700856505  -0.29875868719042 ...
	      0.90916386040348],...
	    [0.00503410266470  -0.10045149188202   0.81028961148079]};
      dc2={1,...
	    [0.00708771085200  -0.13075895458907   1],...
	    [0.00815235594758  -0.08754229008767   1],...
	    [0.01530566856719  -0.19610393150465   1],...
	    [0.00000213557112  -0.00007247268251   0.00074418207415 ...
	      -0.00268709541198   0.01988142634668   1],...
	    [0.01098844298808  -0.19395166448863   1],...
	    [0.00614723653340  -0.11162270280918   1],...
	    [0.01019120537993  -0.14977053903121   1],...
	    [0.01585353393664  -0.18310375006209   1],...
	    [0.00006216421770  -0.00196107382326   0.04077825055198 ...
	      -0.33903949832675   1],...
	    [0.00669091523183  -0.12406192574979   1]};
    else
      % wave height distribution in time
      % pdfgengam distribution parameters as a function of Hm0
      % Best fit by smoothing spline 
      % Then approximate the spline with a rational polynomial
      da1={ [ -0.00021090006386   0.00099934574943  -0.00900432806455 ...
	      0.05360872962522  -0.13820834412204],...
	    [-0.00084087472436   0.01342836937721  -0.07021482301815 ...
	      0.10439996243985],...
	    [-0.00411971761194   0.05373598422752  -0.18954063934808],...
	    [-0.00012474421100   0.00250396234414  -0.01801864263205 ...
	      0.04851788377177  -0.02919751683519],...
	    [0.00028241591775  -0.00383579194909   0.08174348963620 ...
	      -1.32724254419412],...
	    [-0.00017670476778  -0.00666915903614   0.04795062219298 ...
	      -0.13645139083902],...
	    [-0.02424372646941   0.09954627397581],...
	    [-0.06133903253669   0.05728131281798],...
	    [-0.00157851613462   0.02089581891395  -0.10894624869976 ...
	      0.19453964201717],...
	    [-0.01725452144688   0.03330237828587],...
	    [0.00000717915718  -0.00019257298441   0.00147154032200 ...
	      -0.00259863686010   0.00035395444663  -0.64480480511488]};
      da2={[ 0.05995605951733  -0.41068759358531   1],...
	    [0.00000751042631  -0.00028613416391   0.00328291899811 ...
	      0.00442091959847  -0.24443844451609   1],...
	    [0.00000430688254  -0.00009106448814  -0.00099869003370 ...
	      0.04154886980845  -0.35890809950952   1],...
	    [0.00023935833522  -0.00591735713261   0.06798723820754 ...
	      -0.38982961431090   1],...
	    [0.00757595539218  -0.10398127181499   1],...
	    [-0.00072248110815   0.02596637975011  -0.18269842814972 ...
	      1],...
	    [-0.00000174711174   0.00008201186938  -0.00150525140157 ...
	      0.01343865711936  -0.05780002313203   0.09429348230678 ...
	      -0.06929032245607   1],...
	    [0.00000208895738  -0.00009609847933   0.00175625002335 ...
	      -0.01601454504333   0.07354831049560  -0.14197461088754 ...
	      0.05078972211934   1],...
	    [-0.00031339835776   0.02438458742232  -0.24117432192535 ...
	      1],...
	    [0.00000066080839  -0.00003627357887   0.00080940846999 ...
	      -0.00943978109394   0.06107606819380  -0.20327993732412 ...
	      0.16542626434793   1],...
	    1};
      db1={[ 0.00022921830947   0.00159925872577  -0.01667704061973 ...
	      0.04662592566503],...
	    [0.00057178028982  -0.00890122096380   0.04679472490838 ...
	      -0.08028139564541],...
	    [0.00108489203287  -0.01346348585841   0.05229228752301],...
	    [0.00006368692453  -0.00130819737566   0.00915200813786 ...
	      -0.02057643921056  -0.00686231640066],...
	    [-0.00036032275155   0.00344363592639  -0.05318676610821 ...
	      0.37800784358293],...
	    [0.00039750363777   0.00118081867213  -0.01920573851960 ...
	      0.04255527451428],...
	    [-0.00000026023512   0.00000971125710  -0.00013658049789 ...
	      0.00089291632946  -0.00253312265455   0.00240791462920 ...
	      0.01221834880497  -0.07673840034416],...
	    [0.03330461771087  -0.06407470597208],...
	    [0.00099308980246  -0.01367631695322   0.06928373414460 ...
	      -0.12532575027873],...
	    [0.00000533318040  -0.00006666739193   0.00004963589207 ...
	      0.01075821412260  -0.04329177213143],...
	    [0.00308340943994  -0.04643773034627   0.22197554243575]};
      db2={[  -0.00173474354751   0.05621596437959  -0.34427151101243 ...
	      1],...
	    [-0.00058223738613   0.03192289667137  -0.32567254582345 ...
	      1],...
	    [0.00005760340117  -0.00273523846872   0.04818874703932 ...
	      -0.35440595407476   1],...
	    [0.00029278914954  -0.00683914266105   0.07249650256932 ...
	      -0.39352564537810   1],...
	    [0.00638543230930  -0.10764451762078   1],...
	    [0.02648227174070  -0.15567637863345   1],...
	    1,...
	    [-0.00000409424117   0.00012066238812  -0.00102643428320 ...
	      -0.00104437419007   0.05110946289237  -0.11321681855217 ...
	      1],...
	    [0.00025276069418   0.02452366546367  -0.26440802697312 ...
	      1],...
	    [0.01001142751412  -0.16817656582429   1],...
	    [0.01372171990510  -0.20396436206820   1]};
      dc1={[ -0.00133929519239   0.04730786996996  -0.29305862191180 ...
	      0.81513950477133],...
	    [-0.00001694036044  -0.00020962139068   0.01936017704239 ...
	      -0.21457808551888   0.71651822962780],...
	    [-0.00000006539271  0.00000289050182  -0.00005039376355 ...
	      0.00043764989508  -0.00196285715424   0.00431652413026 ...
	      -0.00327762303122   0.00162843010482   0.83762164036746],...
	    [0.00029465993453  -0.00668829521454   0.06554242495875 ...
	      -0.32893277935724   0.78933481630309],...
	    [-0.00042306886854   0.01169315489889  -0.15234924008196 ...
	      1.07947721976127],...
	    [0.00008612163029   0.01913711028089  -0.15116777911992 ...
	      0.80820390970050],...
	    [-0.00000009184030   0.00000539190949  -0.00009430392625 ...
	      0.00082888134980   0.00416708981125  -0.14314823340722 ...
	      0.72026361378988],...
	    [0.02184596827502  -0.24092029708847   0.73236399219820],...
	    [0.00087239619444   0.00317550897707  -0.12537252077704 ...
	      0.64440899045430],...
	    [0.00000520709551  -0.00007316412551   0.00778043773746 ...
	      -0.13068465733412   0.73793632047669],...
	    [-0.00000358589802   0.00009488464816  -0.00071800099087 ...
	      0.00082796715513  -0.00010259391795   1.00634386416504]};
      dc2={[  -0.00191628271245   0.05897119249625  -0.35851961723834 ...
	      1],...
	    [-0.00110670951778   0.03475616787178  -0.32343924869809 ...
	      1],...
	    1,...
	    [0.00029664024285  -0.00687396790239   0.07160724547061 ...
	      -0.38909506719167   1],...
	    [0.00847891734366  -0.11511722816039   1],...
	    [0.02110863910760  -0.16839461856688   1],...
	    [0.01221660139132  -0.21791917424613   1],...
	    [-0.00000063445622   0.00002035073383  -0.00019255458144 ...
	      -0.00030177314761   0.04026875326209  -0.36308545539702 ...
	      1],...
	    [0.00024856242058   0.01796990025221  -0.24248924588261 ...
	      1],...
	    [0.01017663527287  -0.18166946821495   1],...
	    1};
    end   
    A0 = exp(polyval(da1{def},Hm0)./polyval(da2{def},Hm0));
    B0 = exp(polyval(db1{def},Hm0)./polyval(db2{def},Hm0));
    C0 = exp(polyval(dc1{def},Hm0)./polyval(dc2{def},Hm0));
 case 2,
   if strncmpi(dim,'s',1)
      % Waveheight distribution in space
      
      if isempty(OHHSGPAR)
        OHHSGPAR = load('ohhsgpar.mat');
      end
      % Generalized Gamma  distribution parameters as a function of Hm0 
      A00 = OHHSGPAR.A00s;
      B00 = OHHSGPAR.B00s;
      C00 = OHHSGPAR.C00s;
      Hm00 = OHHSGPAR.Hm0;
    else
      % wave height distribution in time
      
      if isempty(OHHGPAR)
        OHHGPAR = load('ohhgpar.mat');
      end
      % logarithm of Generalized Gamma  distribution parameters as a function of Tp, Hm0 
      A00 = OHHGPAR.A00s;
      B00 = OHHGPAR.B00s;
      C00 = OHHGPAR.C00s;    
      Hm00 = OHHGPAR.Hm0;
    end
    
    if 0,
      method = '*cubic';
      A0 = exp(interp1(Hm00,A00(:,def),Hm0,method));
      B0 = exp(interp1(Hm00,B00(:,def),Hm0,method));
      C0 = exp(interp1(Hm00,C00(:,def),Hm0,method));
    else
      A0 = exp(cssmooth(Hm00,(A00(:,def)),1,Hm0));
      B0 = exp(cssmooth(Hm00,(B00(:,def)),1,Hm0));
      C0 = exp(cssmooth(Hm00,C00(:,def),1,Hm0));
    end

end


return


% old parameters for Hd in space

% da1={[0.00000002406418  -0.00000145864213   0.00002600427250 ...
% 	      -0.00005326802443  -0.00338753223636   0.04276396672557 ...
% 	      -0.22397486790581   0.55397003503315  -0.55201813718275],...
% 	    [-0.00000676965122   0.00020200920966  -0.00205838398409 ...
% 	      0.00019797655476   0.08016410340483  -0.31152517839130],....
% 	    [-0.00000476260375   0.00019130072039  -0.00371521972888 ...
% 	      0.02386336139550  -0.05970268563274  -0.01617628729118],...
% 	    [0.00024283057775  -0.00833239642085   0.05582385447507 ...
% 	      -0.17648495861337],....
% 	    [0.00007720352467  -0.00238040941550   0.02862824083340 ...
% 	      -0.16839558114694   0.48846396125956  -0.55750790378169],...
% 	    [-0.00111421509970   0.00674053248615   0.06417458439903 ...
% 	      -0.54809442793967],...
% 	    [-0.00061655028333   0.01149116196906  -0.06700465624727 ...
% 	      -0.16306675248567],...
% 	    [-0.00000008790850   0.00000494031449  -0.00011873707829 ...
% 	      0.00158201747763  -0.01252778901847   0.05903244219134 ...
% 	      -0.16295659853979  0.27679041787843  -0.33920506275510],....
% 	    [0.00019944972975  -0.00387246294051   0.00871836622093 ...
% 	      0.07525104478615  -0.37975077120345],...
% 	    [-0.00011980183052   0.00111964000381  -0.01215116602786 ...
% 	      0.09008588020134  -0.48851968906629],...
% 	    [-0.00091863878485   0.00636619673737   0.07526302723788 ...
% 	      -0.66019998776218  ]};
%       
%       
%       da2={[0.00000010060522  -0.00000550366553   0.00014160956534 ...
% 	      -0.00221926674196   0.02234423849354  -0.14211836784142 ...
% 	      0.54260149839428  -1.12617270843975   1],...
% 	    [0.00000337580209   0.00008243933002  -0.00451274033888 ...
% 	      0.06863436347737  -0.42296672448054   1],....
% 	    [0.00003069759331  -0.00049421544034   0.00114689371645 ...
% 	      0.04477822583039  -0.36818127349426   1],...
% 	    [-0.00056051865784   0.02794081232903  -0.24546163340283 ...
% 	      1],...
% 	    [0.00000016332729   0.00047498038386  -0.01307670200874 ...
% 	      0.13215678946670  -0.58743354090320   1],...
% 	    [0.00027827266513   0.01251000719516  -0.22149079152022 ...
% 	      1],...
% 	    [0.00018130364106   0.00498960156317  -0.13199762979401 ...
% 	      1],...
% 	    [0.00000033412316  -0.00001877261316   0.00044090470098 ...
% 	      -0.00563540723674   0.04240614918096 -0.19001070154163 ...
% 	      0.50385657013424  -0.84025825331257   1],....
% 	    [0.00025709183125  -0.00617747756904   0.07958557077854 ...
% 	      -0.44069798439265   1],...
% 	    [0.00035572688653  -0.00647843130859   0.06126897862841 ...
% 	      -0.31208814468029   1],...
% 	    [0.00084329792629  -0.00044723971576  -0.15620403936717 ...
% 	      1]};
%       db1={[-0.00082074327622   0.00310711191739   0.02983321893646 ...
% 	      0.10512685294208],...
% 	    [-0.00001651586126   0.00023940502444   0.00036988943260 ...
% 	      -0.01852343109453   0.07182618187072],...
% 	    [-0.00016426460078   0.00351053772758  -0.03264452977275 ...
% 	      0.14045211622147  -0.25729061669762],...
% 	    [-0.00033440303631   0.00432232613154  -0.01629785223659 ...
% 	      -0.00632348250638],...
% 	    [-0.00002864536325   0.00079788325346  -0.00933896867008 ...
% 	      0.05162357092566  -0.08979872153610  -0.18807381931685],...
% 	    [-0.00001292516199   0.00022611026761   0.00130613541462 ...
% 	      -0.02758546678738   0.10440258704625],...
% 	    [-0.00246211139569   0.02589825879106   0.00905229907941],....
% 	    [  -0.00037781795743   0.00450525318031  -0.02220074480905 ...
% 	      0.03782125966200],....
% 	    [-0.00005365190329   0.00061220198257   0.00106106554759 ...
% 	      -0.03638237470114   0.15043660450147],....
% 	    [-0.00002448300168   0.00009317073942   0.00480245117187 ...
% 	      -0.04497407339539   0.13588148121929],...
% 	    [-0.00023013152466  -0.00316576689047   0.03163238265516]};
%       db2={[0.00098484194373  -0.01380614814547   0.17980395966828 ...
% 	      1],....
% 	    [0.00010708975223  -0.00396929506746   0.05929719875494 ...
% 	      -0.39612320450062   1],....
% 	    [0.00025838476420  -0.00767382409100   0.09587505689743 ...
% 	      -0.47907524905693   1],...
% 	    [  -0.00055609648946   0.02656272782926  -0.24343322979930 ...
% 	      1],...
% 	    [-0.00000090496443   0.00017295210287  -0.00483418013997 ...
% 	      0.06123112719430  -0.38640594789832   1],...
% 	    [0.00018726679267  -0.00507562033837   0.06605806753868 ...
% 	      -0.40364596143106   1],...
% 	    [0.00597566091081  -0.10777062098535   1],....
% 	    [0.00002127246670   0.00732906517042  -0.13023170576265 ...
% 	      1],...
% 	    [0.00012522165992  -0.00416789302263   0.06029772023606 ...
% 	      -0.37903124030781   1],...
% 	    [0.00020634188557  -0.00610326675692   0.07715475800899 ...
% 	      -0.42169072765716   1],....
% 	    [0.00665456046645  -0.12267260104256   1]};
%       dc1={[  -0.00036807850265   0.00545545695466   0.01352919193262 ...
% 	      0.84197423534212],...
% 	    [-0.00050432820881   0.01708120740048  -0.19876997429965 ...
% 	      0.86435448125891],...
% 	    [-0.00033914940618   0.00795116688552  -0.06846531465339 ...
% 	      0.55840198615046],...
% 	    [-0.00071488796998   0.02486449026128  -0.21041580231524 ...
% 	      0.79355468847845],...
% 	    [-0.00009892859012   0.00276591546072  -0.03002633457402 ...
% 	      0.15931972337914  -0.43161505755054   0.53570434002641],....
% 	    [0.00010619165436  -0.00347018536796   0.05224169636433 ...
% 	      -0.34338472358767   0.84860394264648],...
% 	    [0.00292046061510  -0.07387190243640   0.84760512059299],...
% 	    [-0.00044089964679   0.01369119753544  -0.14634713714506 ...
% 	      0.81184916823722],...
% 	    [0.00002984289196  -0.00214159202410   0.04287625923275 ...
% 	      -0.30428570545530   0.91417829223642],...
% 	    [0.00013890296940  -0.00488554788279   0.06763232035215 ...
% 	      -0.38511409814644   0.90958685139151],...
% 	    [0.00503526324868  -0.10045012206915   0.81030061018108]};
%       dc2={[0.00019399967847   0.00463671477881   0.00678275747181 ...
% 	      1],...
% 	    [-0.00055113183662   0.01961448142377  -0.22929214637072 ...
% 	      1],...
% 	    [-0.00019930915226   0.01208390021168  -0.12871437482774 ...
% 	      1],...
% 	    [-0.00041983098003   0.02513894419236  -0.23999047344698 ...
% 	      1],...
% 	    [0.00001515022471   0.00099690344938  -0.02498697386844 ...
% 	      0.19572691863159  -0.65081992606434   1],....
% 	    [0.00016992835272  -0.00504226547517   0.06822048124694 ...
% 	      -0.42064421003533   1],...
% 	    [0.00614680320329  -0.11162528205048   1],...
% 	    [0.00000891584989   0.00996459000728  -0.14831429085591 ...
% 	      1],....
% 	    [0.00010585667875 -0.00337757377606   0.05286633398607 ...
% 	      -0.34794726199725   1],....
% 	    [0.00020046464996  -0.00613702100495   0.07881624295611 ...
% 	      -0.43164177673728   1],...
% 	    [0.00669221007614  -0.12405570006965   1]};
