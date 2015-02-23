
    % foxel laboratories - CH1903+ (Swiss reference systems)
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

        % Import reference point (MN95 NF02 - CH1903+) %
        flRef = load( [ flPath '/ref.xyz' ] );

        % Import origin point (MN95 NF02 - CH1903+) %
        flOrg = load( [ flPath '/origin.xyz' ] );

        % Apply origin shift (MN95 NF02 - CH1903+) %
        flRef(:,1) -= flOrg(1,1);
        flRef(:,2) -= flOrg(1,2);
        flRef(:,3) -= flOrg(1,3);

        % Import raw point cloud corresponding vertex %
        flRaw = load( [ flPath '/raw.xyz' ] );

        % Display message %
        fprintf( 2, 'Alignment : Scaling point cloud ...\n' );

        % Extract scale factor %
        flScale = fl_scale( flRef, flRaw );

        % Apply scale factor on raw data %
        flRaw *= flScale;

        % Display message %
        fprintf( 2, 'Alignment : Computing rigid transformation ...\n' );

        % Estimate linear transformation %
        [ flR flt ] = fl_rigid( [ flRef(:,1), flRef(:,2), flRef(:,3) ] , [ flRaw(:,1), flRaw(:,2), flRaw(:,3) ] );

        % Display message %
        fprintf( 2, 'Alignment : Alignment of point cloud ...\n' );

        % Import point cloud (xyzrgb file) %
        flwPC = load( [ flPath '/original/cloud.xyzrgb' ] );

        % Apply scale factor on raw data %
        flwPC(:,1) *= flScale;
        flwPC(:,2) *= flScale;
        flwPC(:,3) *= flScale;

        % Align point cloud %
        flrPC = fl_linear( flwPC, flR, flt );

        % Display message %
        fprintf( 2, 'Alignment : Exporting point cloud ...\n' );

        % Export aligned point-cloud %
        dlmwrite( [ flPath '/aligned/aligned.xyzrgb' ], flrPC, 'delimiter', ' ' );

    end

