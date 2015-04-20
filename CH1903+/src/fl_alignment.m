
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

    function fl_alignment( flPath )

        % Display message %
        fprintf( 2, 'Alignment : Importing reference values ...\n' );

        % Import origin vertex (MN95 NF02 - CH1903+) %
        flOrg = load( [ flPath '/origin.xyz' ] );

        % Import reference vertex (MN95 NF02 - CH1903+) %
        flRef = load( [ flPath '/ref.xyz' ] );

        % Apply origin shift (MN95 NF02 - CH1903+) %
        flRef(:,1) -= flOrg(1,1);
        flRef(:,2) -= flOrg(1,2);
        flRef(:,3) -= flOrg(1,3);

        % Import raw point cloud reference vertex %
        flRaw = load( [ flPath '/raw.xyz' ] );

        % Display message %
        fprintf( 2, 'Alignment : Scaling point cloud ...\n' );

        % Compute scale factor (Point cloud/MN95-NF02) %
        flScale = fl_scale( flRef, flRaw );

        % Display message %
        fprintf( 2, 'Alignment : Computing rigid transformation ...\n' );

        % Estimate linear transformation (rigid transformation) %
        [ flR flt ] = fl_rigid( [ flRef(:,1), flRef(:,2), flRef(:,3) ] , [ flRaw(:,1), flRaw(:,2), flRaw(:,3) ] * flScale );

        % Display message %
        fprintf( 2, 'Alignment : Alignment of point cloud ...\n' );

        % Import point cloud (xyzrgba file) %
        [ flwPC flSize flpStack flpType flpName flFormat flxr ] = fl_readply( [ flPath '/original/cloud.ply' ] );

        % Apply scale factor on point cloud vertex %
        flwPC(:,flxr(1)) *= flScale;
        flwPC(:,flxr(2)) *= flScale;
        flwPC(:,flxr(3)) *= flScale;

        % Apply linear transformation on point cloud vertex %
        flrPC = fl_linear( flwPC, flR, flt, flxr );

        % Display message %
        fprintf( 2, 'Alignment : Exporting point cloud ...\n' );

        % Export MN95-NF02-aligned point cloud (xyzrgba file) %
        fl_writeply( [ flPath '/aligned/cloud.ply' ], flrPC, flSize, flpStack, flpType, flpName, flFormat );

        % Display message %
        fprintf( 2, 'Alignment : Exporting CH1903+/MN95/NF02 alignement repport ...\n' );

        % Export alignement repport %
        fl_alignment_repport( flPath, flRef, flRaw, flR, flt, flScale );

    end

    function fl_alignment_repport( flPath, flRef, flRaw, flR, flt, flScale )

        % Create output stream for scale %
        flf = fopen( [ flPath '/aligned/scale.dat' ], 'w' );

        % Exporting scale factor %
        fprintf( flf, '%f %f %f\n', flScale, flScale, flScale );

        % Close output stream for scale %
        fclose( flf );

        % Create output stream for shear %
        flf = fopen( [ flPath '/aligned/shear.dat' ], 'w' );

        % Apply scale factor %
        flRaw(:,1) *= flScale;
        flRaw(:,2) *= flScale;
        flRaw(:,3) *= flScale;

        % Parsing reference and raw points %
        for fli = 1 : min( size( flRaw, 1 ), size( flRef, 1 ) )

            % Compute aligned raw points %
            flx = ( flRaw( fli, 1 ) - flt(1) ) * flR'(1,1) + ( flRaw( fli, 2 ) - flt(2) ) * flR'(1,2) + ( flRaw( fli, 3 ) - flt(3) ) * flR'(1,3);
            fly = ( flRaw( fli, 1 ) - flt(1) ) * flR'(2,1) + ( flRaw( fli, 2 ) - flt(2) ) * flR'(2,2) + ( flRaw( fli, 3 ) - flt(3) ) * flR'(2,3);
            flz = ( flRaw( fli, 1 ) - flt(1) ) * flR'(3,1) + ( flRaw( fli, 2 ) - flt(2) ) * flR'(3,2) + ( flRaw( fli, 3 ) - flt(3) ) * flR'(3,3);

            % Export points coordinates %
            fprintf( flf, '%f %f %f %f %f %f\n', flRef( fli, 1 ), flRef( fli, 2 ), flRef( fli, 3 ), flx, fly, flz );

        end

        % Close output stream for shear %
        fclose( flf );

        % Create output stream for transformation %
        flf = fopen( [ flPath '/aligned/transform.dat' ], 'w' );

        % Export rotation matrix %
        fprintf( flf, '%.16f %.16f %.16f\n', flR'(1,1), flR'(1,2), flR'(1,3) );
        fprintf( flf, '%.16f %.16f %.16f\n', flR'(2,1), flR'(2,2), flR'(2,3) );
        fprintf( flf, '%.16f %.16f %.16f\n', flR'(3,1), flR'(3,2), flR'(3,3) );

        % Export translation vector %
        fprintf( flf, '%.16f %.16f %.16f\n', flt(1), flt(2), flt(3) );

        % Close output stream for transformation %
        fclose( flf );

    end

