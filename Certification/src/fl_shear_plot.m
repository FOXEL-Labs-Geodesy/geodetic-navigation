
    % FOXEL Laboratories - CH1903+ - Swiss reference systems
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

    function fl_shear_plot( flPath, flPlanpmin, flPlanpmax, flAltpmin, flAltpmax, flImage )

        % Display message %
        fprintf( 2, 'Shear : importing data ...\n' );

        % Import reference points coordinates %
        flShear = load( [ flPath 'aligned/shear.dat' ] );

        % Display message %
        fprintf( 2, 'Shear : computing plot ...\n' );
        
        % Compute statistical quantities %
        flmx = mean( flShear(:,1) - flShear(:,4) );
        flmy = mean( flShear(:,2) - flShear(:,5) );
        flmz = mean( flShear(:,3) - flShear(:,6) );
        flsx = std ( flShear(:,1) - flShear(:,4) );
        flsy = std ( flShear(:,2) - flShear(:,5) );
        flsz = std ( flShear(:,3) - flShear(:,6) );

        % Display shear variances %
        fprintf( 2, 'Shear x : %f\n', flsx );
        fprintf( 2, 'Shear y : %f\n', flsy );
        fprintf( 2, 'Shear z : %f\n', flsz );

        % Figure %
        figure;

        % Configure subplot %
        subplot( 1, 2, 1 );
        hold on;
        grid on;
        box  on;

        % Draw precision ranges %
        fl_shear_plot_ellipse( 0, 0, flPlanpmin, flPlanpmin, ':', [ 178 30 20 ] / 255, 2 );
        fl_shear_plot_ellipse( 0, 0, flPlanpmax, flPlanpmax, ':', [ 178 30 20 ] / 255, 2 );
        fl_shear_plot_ellipse( 0, 0, flPlanpmin, flPlanpmin, '-', [ 178 30 20 ] / 255, 1 );
        fl_shear_plot_ellipse( 0, 0, flPlanpmax, flPlanpmax, '-', [ 178 30 20 ] / 255, 1 );

        % Draw mean and standard deviation %
        fl_shear_plot_ellipse( flmx, flmy, flsx / 2, flsy / 2, '-', [ 255 117 108 ] / 255, 1 );

        % Display planimetric shear %
        plot( flShear(:,1) - flShear(:,4), flShear(:,2) - flShear(:,5), '+', 'Color', [ 255 117 108 ] / 255 );

        % Axis configuration %
        xlabel( 'x [m]' );
        ylabel( 'y [m]' );
        axis( [ -1.5 1.5 -1.5 1.5 ], 'Square' );

        % Configure subplot %
        subplot( 1, 2, 2 );
        hold on;
        grid on;
        box  on;

        % Draw precision ranges %
        fl_shear_plot_ellipse( 0, 0, flPlanpmin, flAltpmin, ':', [ 178 30 20 ] / 255, 2 );
        fl_shear_plot_ellipse( 0, 0, flPlanpmax, flAltpmax, ':', [ 178 30 20 ] / 255, 2 );
        fl_shear_plot_ellipse( 0, 0, flPlanpmin, flAltpmin, '-', [ 178 30 20 ] / 255, 1 );
        fl_shear_plot_ellipse( 0, 0, flPlanpmax, flAltpmax, '-', [ 178 30 20 ] / 255, 1 );

        % Draw mean and standard deviation %
        fl_shear_plot_ellipse( flmx, flmz, flsx / 2, flsz / 2, '-', [ 255 117 108 ] / 255, 1 );

        % Display altimetric shear %
        plot( flShear(:,1) - flShear(:,4), flShear(:,3) - flShear(:,6), '+', 'Color', [ 255 117 108 ] / 255 );

        % Axis configuration %
        xlabel( 'x [m]' );
        ylabel( 'z [m]' );
        axis( [ -1.5 1.5 -1 1 ], 'Square' );

        % Figure exportation in color EPS file %
        print( '-depsc', '-F:12', [ '../dev/images/' flImage '.eps' ] );

    end

    function fl_shear_plot_ellipse( flx, fly, fla, flb, flDesc, flColor, flWidth )

        % Compose array %
        flu = fla * cos( linspace( 0, 2 * pi, 128 ) );
        flv = flb * sin( linspace( 0, 2 * pi, 128 ) );

        % Draw ellipse %
        plot( flu + flx, flv + fly, flDesc, 'Color', flColor, 'LineWidth', flWidth );

    end
