
    % FOXEL Laboratories - Certification
    %
    % Copyright (c) 2013-2015 FOXEL SA - http://foxel.ch
    % Please read <http://foxel.ch/license> for more information.
    %
    %
    % Author(s):
    %
    %      Nils Hamel <n.hamel@foxel.ch>
    %
    %
    % This file is part of the FOXEL project <http://foxel.ch>.
    %
    % This program is free software: you can redistribute it and/or modify
    % it under the terms of the GNU Affero General Public License as published by
    % the Free Software Foundation, either version 3 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU Affero General Public License for more details.
    %
    % You should have received a copy of the GNU Affero General Public License
    % along with this program.  If not, see <http://www.gnu.org/licenses/>.
    %
    %
    % Additional Terms:
    %
    %      You are required to preserve legal notices and author attributions in
    %      that material or in the Appropriate Legal Notices displayed by works
    %      containing it.
    %
    %      You are required to attribute the work as explained in the "Usage and
    %      Attribution" section of <http://foxel.ch/license>.

    function fl_peridensity_plot( flPath, flMin, flMax, flRes, flImage )

        % Display message %
        fprintf( 2, 'Peridensity analysis : importing peridensity data ...\n' );

        % Import peridistances %
        flDensity = load( [ flPath 'peridensity/peridensity.dat' ] );

        % Create statistical arrays %
        flSize = fix( ( flMax - flMin ) / flRes );
        flDist = cell ( flSize );
        flStat = cell ( flSize );
        flPlot = zeros( flSize, 1 );

        % Display message %
        fprintf( 2, 'Peridensity analysis : computing peridensity statistics ...\n' );

        % Fill statistical array %
        for fli = 1 : size( flDensity, 1 )

            % Compute statistical bin %
            flBin = fix( ( flDensity( fli, 1 ) - flMin ) / flRes );

            % Range detection on bins %
            if ( ( flBin >= 1 ) && ( flBin <= flSize ) )

                % Push measure %
                flDist{ flBin } = flDensity( fli, 1 );
                flStat{ flBin } = [ flStat{ flBin }, flDensity( fli, 2 ) ];

            end

        end

        % Compute statistical array %
        flk = 0; for fli = 1 : flSize

            % Detect empty bin %
            if ( length( flStat{ fli } ) > 16 ) 

                % Update index %
                flk += 1;

                % Compute mean value of bin %
                flPlot( flk, 1 ) = flDist{ fli };
                flPlot( flk, 2 ) = mean( flStat{ fli } );
                flPlot( flk, 3 ) = std ( flStat{ fli } );

            end

        end

        % Resize array %
        flPlot = flPlot( 1 : flk, : );

        % Display message %
        fprintf( 2, 'Peridensity analysis : computing peridensity theoric models ...\n' );

        % Compute theoric models %
        [ flPair flBest ] = fl_peridensity_model( flPlot(:,1) );

        % Display message %
        fprintf( 2, 'Peridensity analysis : computing peridensity plot ...\n' );

        % Figure configuration %
        figure;
        hold on;
        grid on;
        box  on;

        % Area plot of mean and standard deviation %
        flArea = area( flPlot(:,1), [ flPlot(:,2) - flPlot(:,3) * 0.5, flPlot(:,3) * 0.5, flPlot(:,3) * 0.5 ] );

        % Configure area plot %
        set( flArea(1), 'FaceColor', 'None'             , 'EdgeColor', 'None' );
        set( flArea(2), 'FaceColor', [ 178 30 20 ] / 255, 'EdgeColor', 'None' );
        set( flArea(3), 'FaceColor', [ 178 30 20 ] / 255, 'EdgeColor', 'None' );

        % Display mean curve %
        plot( flPlot(:,1), flPlot(:,2), '-', 'Color', [ 255 117 108 ] / 255, 'LineWidth', 1 );

        % Display theoric models %
        %plot( flPlot(:,1), flPair, ':' , 'Color', [ 232 83  12 ] / 255, 'LineWidth', 1 );
        %plot( flPlot(:,1), flBest, '-.', 'Color', [ 255 168 21 ] / 255, 'LineWidth', 1 );

        % Figure configuration %
        xlabel( 'Camera peridistances [m]' );
        xlim( [ min( flPlot(:,1) ), max( flPlot(:,1) ) ] );
        ylabel( 'Peridensity [m]' );
        ylim( [ min( flPlot(:,2) - flPlot(:,3) * 0.5 ), max( flPlot(:,2) + flPlot(:,3) * 0.5 ) ] );

        % Figure exportation in color EPS file %
        print( '-depsc', '-F:12', [ '../dev/images/' flImage '.eps' ] );
        
    end

