
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

    function fl_writeply( flPly, flVertex, flSize, flpStack, flpType, flpName, flFormat )

        % Create output stream %
        flf = fopen( flPly, 'w' );

        % Check output stream %
        if ( flf == -1 )

            % Display message %
            fprintf( 2, 'Error : unable to create %s file\n', flPly );

        else

            % Export standard header %
            fprintf( flf, 'ply\nformat ascii 1.0\nelement vertex %i\n', flSize );

            % Export property %
            for fli = 1 : flpStack

                fprintf( flf, 'property %s %s\n', flpType{ fli }, flpName{ fli } );

            end

            % Export end of header %
            fprintf( flf, 'end_header\n' );

            % Export element vertex %
            for fli = 1 : flSize; fprintf( flf, [ flFormat '\n' ], flVertex( fli, 1:flpStack ) ); end

            % Close output stream %
            fclose( flf );

        end

    end
