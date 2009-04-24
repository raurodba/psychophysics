function ax = cogplot(rings, cogs, radius)

[gring, gcog] = ndgrid(rings, cogs);
[ringix, cogix] = ndgrid(1:numel(rings), 1:numel(cogs));

gearinches = gring .* (1./gcog) * radius * 2 / 25.4;

[ax, h2, h1] = plotyy([ringix(1:end, :);(ringix(end,:) + 1)], gearinches([1:end end], :), ringix(:), gearinches(:));

set(h1, 'Marker', '.', 'LineStyle', 'none', 'Color', 'k');
set(h2, 'Color', [0.8 0.8 0.8], 'LineStyle', ':');

ylabel(ax(1), 'Gear inches'); 
set( ax(1) ...
    , 'XLim', [0 4] ...
    , 'YLim', [20 120] ...
    , 'YScale', 'log' ...
    , 'XTick', [] ...
    , 'YTick', [20 25 30 40 50 60 80 100 120] ...
    );

%plot the cogs on the right side...

xlabel(ax(2), 'Rings'); 
ylabel(ax(2), 'Cogs')
set( ax(2)...
    , 'Position', get(ax(1), 'Position')...
    , 'XLim', get(ax(1), 'XLim')...
    , 'YLim', get(ax(1), 'YLim')...
    , 'YScale', get(ax(1), 'YScale')...
    , 'XTick', ringix(:,1) ...
    , 'XTickLabel', arrayfun(@num2str, rings, 'UniformOutput', 0)...
    , 'YTick', gearinches(end,end:-1:1)...
    , 'YTickLabel', arrayfun(@num2str, cogs(end:-1:1), 'UniformOutput', 0)...
    );

%now for each gear find the two closest neighbors (that are higher)
hold(ax(1), 'on');
for ix = [gearinches(:) ringix(:) cogix(:)]'
    gi = ix(1);
    rix = ix(2);
    cix = ix(3);
    
    %neighbors accessible by a 'reasonable' shift (at most one ring and two
    %cogs)
    neighbors = [...
        rix-1 cix-2; rix-1 cix-1; rix-1 cix; ...
        rix cix-1; ...
        rix+1 cix; rix+1 cix+1; rix+1 cix+2 ];
    % ; rix+1 cix+2
    neighbors = neighbors ...
        ( (neighbors(:,1) >= 1) & (neighbors(:,1) <= numel(rings)) ...
        & (neighbors(:,2) >= 1) & (neighbors(:,2) <= numel(cogs)) ...
        , :);
    
    neighbors = [gearinches(sub2ind(size(gearinches), neighbors(:,1),neighbors(:,2))) neighbors];
    %only count upshifts...
    neighbors = neighbors(neighbors(:,1) > gi,:);
    
    neighbors = sortrows(neighbors);

    %and only count the first upshift found on each ring.
    [tmp, i] = unique(neighbors(:,2), 'first');
    neighbors = neighbors(i,:);
    
    %plot each with a percentage change...
    colors = [0 1 0; 1 0.7 0; 1 0.2 0.2];
    for jx = neighbors'
        distance = abs(cix-jx(3)) + abs(rix-jx(2));
        pct = (jx(1)/gi - 1) * 100;
        plot(ax(1), [rix jx(2)], [gi jx(1)], '-', 'Color', colors(distance,:));
        h = text((rix+jx(2))/2, (gi+jx(1))/2, sprintf('%.2g%%', pct));
        set(h, 'HorizontalAlignment', 'center', 'BackgroundColor', 'w')
    end
end
hold(ax(1), 'off');