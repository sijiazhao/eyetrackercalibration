function x = bisample(y)
%
%   �T���v�����O���[�g���{�ɂ���
%   2�_�̕��ϒl�𗘗p
%
if size(y,2)==1
    y = y';
    o = 1;
elseif (size(y,1)-1)*(size(y,2)-1)~=0
    error('input must be vector');
else
    o=0;
end

tmp = ([0 y] + [y 0])/2;
tmp = [y;tmp(2:end)];
x = reshape(tmp,1,size(tmp,2)*2);
x(end) = [];
if o==1
    x = x';
end
