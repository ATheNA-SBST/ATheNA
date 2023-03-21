%RNDCAUCHY Random matrices a the Cauchy distribution.
% 
% CALL:  R = rndcauchy(a,c,sz)
% 
% R    = matrix of random numbers from the Cauchy distribution
% a,c  = parameters of the Cauchy distribution
%   sz = size(R)    (Default common size of a and c)
%        sz can be a comma separated list or a vector 
%        giving the size of R (see zeros for options).
%
% The Cauchy distribution is defined by the distribution function
% 
%   F(x;a,c) = atan((x-c)/a))/pi+1/2, a>0
% 
% The random numbers are generated by the inverse method. 
%
% Example:
%   R=rndcauchy(1,10,1,100);
%   F = edf(R);
%   phat=plotqq(F(:,2), cdfcauchy(F(:,1),1,10));
%
%   close all;
%
% See also cdfcauchy, invcauchy, rndcauchy, fitcauchy, momcauchy

% Copyright (C) 2007  Per A. Brodtkorb
%
% This file is part of WAFO.
%
% WAFO is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
%
% WAFO is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with WAFO; see the file COPYING.  If not, write to the Free
% Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA.


function R = rndcauchy(varargin)

%error(nargchk(1,inf,nargin))
narginchk(1,inf)
Np = 2;
options = struct; % default options
[params,options,rndsize] = parsestatsinput(Np,options,varargin{:});
if numel(options)>1
  error('Multidimensional struct of distribution parameter not allowed!')
end
[a,c] = deal(params{:});

if isempty(c), c = 0;end
if isempty(a), a = 1;end

if isempty(rndsize)
  csize = comnsize(a,c);
else
  csize = comnsize(a,c,zeros(rndsize{:}));
end
if any(isnan(csize))
    error('a, and c must be of common size or scalar.');
end

R = invcauchy(rand(csize),a,c);
