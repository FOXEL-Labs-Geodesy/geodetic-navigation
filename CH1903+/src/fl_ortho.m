
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

    function fl_ortho( flPath, x1, y1, x2, y2, pixpermn95, z1, z2 )

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Saving CH1903+/MN95 parameters ...\n' );

        % Export function repport %
        fl_cmd( flPath, x1, y1, x2, y2, pixpermn95, z1, z2 );

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Importing reference values ...\n' );

        % Import origin vertex (MN95 NF02 - CH1903+) %
        flOrg = load( [ flPath '/origin.xyz' ] );

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Importing point-cloud ...\n' );

        % Import MN95-NF02-aligned point cloud %
        [ flrPC flSize flpStack flpType flpName flFormat flxr ] = fl_readply( [ flPath 'aligned/cloud.ply' ] );

        % Restor point cloud frame %
        flrPC(:,flxr(1)) += flOrg(1,1);
        flrPC(:,flxr(2)) += flOrg(1,2);
        flrPC(:,flxr(3)) += flOrg(1,3);

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Preparing chromatic matrix ...\n' );

        % Compute ortho-photo matrix size %
        flW = fix( ( x2 - x1 ) * pixpermn95 );
        flH = fix( ( y2 - y1 ) * pixpermn95 );
        
        % Allocate ortho-projection chromatic matrix %
        flM = zeros( flH, flW, 4 );

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Computing chromatic matrix ...\n' );

        % Point cloud vertex projection %
        for fli = 1 : flSize

            % Height filtering %
            if ( ( flrPC(fli,3) >= z1 ) && ( flrPC(fli,3) <= z2 ) )

                % Compute projected point coordinates %
                flx = fix( ( flrPC(fli,1) - x1 ) * pixpermn95 + 0.5 );
                fly = fix( ( flrPC(fli,2) - y1 ) * pixpermn95 + 0.5 );

                % Range detection %
                if ( ( flx >= 1 ) && ( fly >= 1 ) && ( flx <= flW ) && ( fly <= flH ) )

                    % Accumulating colors and count %
                    flM(flH+1-fly,flx,1) += flrPC(fli,flxr(4));
                    flM(flH+1-fly,flx,2) += flrPC(fli,flxr(5));
                    flM(flH+1-fly,flx,3) += flrPC(fli,flxr(6));
                    flM(flH+1-fly,flx,4) += 1;

                end

            end

        end

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Averaging chromatic matrix ...\n' );

        % Parsing image pixels %
        flz = 1; for flx = 1 : flW; for fly = 1 : flH

            % Zero detection %
            if ( flM(flH+1-fly,flx,4) ~= 0 )

                % Computing color average %
                flM(flH+1-fly,flx,1) /= flM(flH+1-fly,flx,4);
                flM(flH+1-fly,flx,2) /= flM(flH+1-fly,flx,4);
                flM(flH+1-fly,flx,3) /= flM(flH+1-fly,flx,4);

            end

        end; end

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Saving chromatic matrix ...\n' );

        % Export ortho-photography image %
        imwrite( flM(:,:,1:3) / 255, [ flPath '/ortho/ortho-photo.png' ] );

    end

    function fl_cmd( flPath, x1, y1, x2, y2, pixpermn95, z1, z2 )

        % Create output stream for repporting %
        flf = fopen( [ flPath '/ortho/cmd.dat' ], 'w' );

        % Export command parameter %
        fprintf( flf, 'Parameters : %f %f %f %f, %f, %f %f\n', x1, y1, x2, y2, pixpermn95, z1, z2 );

        % Delete output stream %
        fclose( flf );

    end

