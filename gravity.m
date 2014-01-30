clc; clear; clf;

G = 6.67300*10^-11;

% F = G*m1*m2 / r^2;
% M = m / sqrt(1 - v^2/c^2)
% Fcf = w^2 * r

RESOLUTION = [131 131];
SIZE = 1; % Each cell

Density = zeros(RESOLUTION); % density
Speeds = zeros([RESOLUTION 2]); % x y
Forces = zeros([RESOLUTION 2]); % x y

[rx ry] = meshgrid(-RESOLUTION(1):RESOLUTION(1),-RESOLUTION(2):RESOLUTION(2));
R2inv = 1./double(sqrt(rx.^2 + ry.^2));
R2inv(R2inv == Inf) = 0;
R2invX = R2inv .* cos(atan2(-ry,-rx));
R2invY = R2inv .* sin(atan2(-ry,-rx));



gx = linspace(ceil(-RESOLUTION(1)/2),ceil(RESOLUTION(1)/2-1),RESOLUTION(1));
gy = linspace(ceil(-RESOLUTION(2)/2),ceil(RESOLUTION(2)/2-1),RESOLUTION(2));
[x y] = meshgrid(gx,gy);
R = sqrt(x.^2 + y.^2) < mean(RESOLUTION)/3;
showgrey(R)
sum(R(:))

%{
%fh = figure()
%set(fh,'WindowStyle','docked')
keyIn = '';                 %Allows monitoring keyb. input while on figure
quit = 0;                   %Boolean for quit of program
%while quit == 0
    keyIn = get(gcf,'CurrentCharacter');
    if strcmpi(keyIn,' ') %If "space" is pressed --> Quit
        keyIn = '';
        quit = 1;
        break;
    end
%}
    Forces = zeros([RESOLUTION 2]);
    Density = R;
    [I J V]= find(Density > 0);
    nDensity = zeros([RESOLUTION]);
    for m = 1:length(V)
        % Move matter
        sDensity = zeros([RESOLUTION]);
        sDensity(I(m),J(m)) = V(m);
        sDensity = moveGas(sDensity,I(m),J(m),V(m),Speeds(I(m),J(m),:));
        nDensity = nDensity + sDensity;
        
        % Add G forces from this mass
        % centered at I(m) J(m), multiplied by V(m)
        xs = RESOLUTION(1) + 2 - I(m);
        xe = xs + RESOLUTION(1) - 1;
        ys = RESOLUTION(2) + 2 - J(m);
        ye = ys + RESOLUTION(2) - 1;
        %fprintf('m=%d,size=%d %d\n',m,size(R2invX(xs:xe,ys:ye),1),size(R2invX(xs:xe,ys:ye),2))
        Forces(:,:,1) = Forces(:,:,1) + V(m) * R2invX(xs:xe,ys:ye);
        Forces(:,:,2) = Forces(:,:,2) + V(m) * R2invY(xs:xe,ys:ye);
                    
        % Update speeds
        Speeds = Speeds + Forces ./ repmat(Density,[1 1 2]); % v = v + a, a = F/m
        Speeds(repmat(Density,[1 1 2]) == 0) = 0;
    end
    
    Density = nDensity;
    %
    %showgrey(R)
    %drawnow
%end
showgrey(Density)
showgrey(sqrt((Forces(:,:,1).^2 + Forces(:,:,2).^2)))