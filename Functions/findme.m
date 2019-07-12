%% Step [1] Compute the grand mean
grandmean = mean(rate(cond2plot,:));

dx = mean(diff(1:numel(grandmean))); % Find Mean Differece In ‘x’ Values
dy = gradient(grandmean,dx);
dypos = find(dy>0);
dyneg = find(dy<0);
dyy = zeros(size(dy));
dyy(dypos) = 1; neg2pos = find(diff(dyy) == 1);
dyy(dyneg) = -1; pos2neg = find(diff(dyy) == -2);

switch searchwhat
    case 'decrease'
        I = find(timeaxis(pos2neg)<searcharound);
        t0 = max(pos2neg(I)); % MS decrease starts (before 0.4s)
        I = find(timeaxis(neg2pos)>searcharound);
        t1 = min(neg2pos(I)); % MS decrease ends (just after 0.4s)
        
        hlt = round((t0+t1)/2); % the target time
        hlv = grandmean(hlt); % the target amplitude
    case 'increase'
        I = find(timeaxis(neg2pos)<searcharound);
        t0 = max(neg2pos(I)); % MS decrease starts (before 0.4s)
        I = find(timeaxis(pos2neg)>searcharound);
        t1 = min(pos2neg(I)); % MS decrease ends (just after 0.4s)
        
        hlt = round((t0+t1)/2); % the target time
        hlv = grandmean(hlt); % the target amplitude
    case 'peak'
        [~,locs] = findpeaks(grandmean);
        [~,t] = fFindClosest(timeaxis(locs),searcharound);
        hlt = locs(t); % the target time
        hlv = grandmean(hlt); % the target amplitude
        
        t0 = locs(t);
        t1 = locs(t);
        %% Get the peak amplitude! (for PDRder)
        for cond = cond2plot
            c = rate(cond,:);
            [pks,locs] = findpeaks(c);
            [v,t] = fFindClosest(locs,hlt);
            U(cond) = c(locs(t));
            Ut(cond) = locs(t);
        end
        U = reshape(U,[length(U),1]);
        Ut = reshape(Ut,[length(Ut),1]);
        
    case 'trough'
        
        [~,locs] = findpeaks(-grandmean);
        [~,t] = fFindClosest(timeaxis(locs),searcharound);
        
        hlt = locs(t); % the target time
        hlv = grandmean(hlt); % the target amplitude
        
        t0 = locs(t);
        t1 = locs(t);
        
        %% Get the peak amplitude! (for PDRder)
        for cond = cond2plot
            c = rate(cond,:);
            [~,locs] = findpeaks(-c);
            [~,t] = fFindClosest(locs,hlt);
            U(cond) = c(locs(t));
            Ut(cond) = locs(t);
        end
        U = reshape(U,[length(U),1]);
        Ut = reshape(Ut,[length(Ut),1]);
end

switch modetv
    case 'byValue'
        %% Find the timing that each condition cross this half life value
        U = rate(cond2plot,hlt);
        
    case 'byTime'
        %% Find the timing that each condition cross this half life value
        % !! Define the time range where to find the time for the intersection
        %     trange = [.3 .5];
        %     trange = find(timeaxis == trange(1)):find(timeaxis == trange(2));
        trange = t0:t1;
        for cond = cond2plot
            c = rate(cond,trange);
            [~,t] = min(abs((c - hlv)));
            U(cond) = timeaxis(trange(t));
        end
        U = reshape(U,[length(U),1]);
end
