
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

    function fl_ortho_missing( flPath )

        % Display message %
        fprintf( 2, 'Missing pixel interpolation : importing chromatic matrix\n' );

        % Import chromatic matrix %
        flM = double( imread( [ flPath '/ortho/ortho-photo.png' ] ) ) / 255;

        % Create secondary allocation %
        flS = flM;

        % Display message %
        fprintf( 2, 'Missing pixel interpolation : computing missing pixels\n' );

        % Parsing chromatic matrix %
        for fly = 1 : size( flM, 1 ); for flx = 1 : size( flM, 2 )

            % Detect black pixel %
            if ( ( flM(fly,flx,1) == 0 ) && ( flM(fly,flx,2) == 0 ) && ( flM(fly,flx,3) == 0 ) )

                % Create y-interpolant %
                for fli = -size( flM, 1 ) + 1 : size( flM, 1 ) * 2

                    % Sampling nodes %
                    fliyt( fli + size( flM, 1 ) ) = fli;

                    % Detect position %
                    if ( fli < 1 )

                        % Sampling nodes %
                        fliy1( fli + size( flM, 1 ) ) = flM(-fli+1,flx,1);
                        fliy2( fli + size( flM, 1 ) ) = flM(-fli+1,flx,2);
                        fliy3( fli + size( flM, 1 ) ) = flM(-fli+1,flx,3);

                    elseif ( fli <= size( flM, 1 ) )

                        % Sampling nodes %
                        fliy1( fli + size( flM, 1 ) ) = flM( fli,flx,1);
                        fliy2( fli + size( flM, 1 ) ) = flM( fli,flx,2);
                        fliy3( fli + size( flM, 1 ) ) = flM( fli,flx,3);

                    else

                        % Sampling nodes %
                        fliy1( fli + size( flM, 1 ) ) = flM( 2*size( flM, 1 )+1-fli,flx,1);
                        fliy2( fli + size( flM, 1 ) ) = flM( 2*size( flM, 1 )+1-fli,flx,2);
                        fliy3( fli + size( flM, 1 ) ) = flM( 2*size( flM, 1 )+1-fli,flx,3);

                    end

                end

                % Compute chromatic interpolants %
                flp1 = polyfit( fliyt, fliy1, size( flM, 1 ) );
                flp2 = polyfit( fliyt, fliy2, size( flM, 1 ) );
                flp3 = polyfit( fliyt, fliy3, size( flM, 1 ) );

                % Assign pixel color %
                flS(fly,flx,1) = polyval( flp1, fly );
                flS(fly,flx,2) = polyval( flp2, fly );
                flS(fly,flx,3) = polyval( flp3, fly );

            end

        end; fprintf( 2, '\t%03.1f%%\n', ( fly / size( flM, 1 ) ) * 100 ); end

        % Display message %
        fprintf( 2, 'Missing pixel interpolation : exporting chromatic matrix\n' );

        % Import chromatic matrix %
        imwrite( flS, [ flPath '/ortho/ortho-photo-interpolated.png' ] ) / 255;

    end
