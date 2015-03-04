
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

    function fl_ortho_missing( flPath, flRadius )

        % Display message %
        fprintf( 2, 'Missing pixel interpolation : importing chromatic matrix ...\n' );

        % Import chromatic matrix %
        flM = imread( [ flPath '/ortho/ortho-photo.png' ] );

        % Create secondary allocation %
        flS = double( flM );

        % Display message %
        fprintf( 2, 'Missing pixel interpolation : computing missing pixels ...\n' );

        % Parsing chromatic matrix %
        for fly = 2 : size( flM, 1 ) - 1; for flx = 2 : size( flM, 2 ) - 1

            % Detect black pixel %
            if ( ( flM(fly,flx,1) == 0 ) && ( flM(fly,flx,2) == 0 ) && ( flM(fly,flx,3) == 0 ) )

                % Initialize sampling - parsing %
                flmd = +0;
                flds = +0;
                fldx = +1;
                fldy = -1;
                flux = flx;
                fluy = fly;
                fllx = flx; 
                flly = fly;
                flhx = flx;
                flhy = fly;

                % Initialize sampling - accumulators  %
                flar = 0;
                flag = 0;
                flab = 0;
                flac = 0;

                % Initialize chromatic accumulators %
                flpx = 0;
                flmx = 0;
                flpy = 0;
                flmy = 0;

                % Sampling condition %
                while (  ( ( flmx + flpx + flmy + flpy ) < 4 ) && ( flds < flRadius ) )

                    % Compute distance to origin %
                    flds = sqrt( ( flux - flx ) ^ 2 + ( fluy - fly ) ^ 2 );

                    % Sampling range verification %
                    if ( ( flux > 0 ) && ( flux <= size( flM, 2 ) ) && ( fluy > 0 ) && ( fluy <= size( flM, 1 ) ) ) 

                        % Chromatic pixel detection %
                        if ( ( flM(fluy,flux,1) ~= 0 ) && ( flM(fluy,flux,2) ~= 0 ) && ( flM(fluy,flux,3) ~= 0 ) )

                            % Compute weight %
                            flws = ( 1 / flds );

                            % Accumulate color components %
                            flab += double( flM(fluy,flux,1) ) * flws;
                            flag += double( flM(fluy,flux,2) ) * flws;
                            flar += double( flM(fluy,flux,3) ) * flws;

                            % Update sampling weight %
                            flac += flws;

                            % Geometric condition %
                            if ( ( flux - flx ) > 0 ); flpx = 1; else; flmx = 1; end
                            if ( ( fluy - fly ) > 0 ); flpy = 1; else; flmy = 1; end

                        end

                    end

                    % Parsing management %
                    if ( flmd == 0 )

                        % Update x-component %
                        flux += fldx;

                        % Detect boundaries %
                        if     ( flux > flhx ); fldx *= -1; flmd = 1; flhx = flux;
                        elseif ( flux < fllx ); fldx *= -1; flmd = 1; fllx = flux; end

                    elseif ( flmd == 1 )

                        % Update y-component %
                        fluy += fldy;

                        % Detect boundaries %
                        if     ( fluy > flhy ); fldy *= -1; flmd = 0; flhy = fluy;
                        elseif ( fluy < flly ); fldy *= -1; flmd = 0; flly = fluy; end

                    end

                end

                % Check sampling results %
                if ( flac > 0 )

                    % Components reconstruction %
                    flS(fly,flx,1) = flab / flac;
                    flS(fly,flx,2) = flag / flac;
                    flS(fly,flx,3) = flar / flac;

                end

            end

        % Display progression %
        end; fprintf( 2, '\t%05.1f%%\n', ( fly / size( flM, 1 ) ) * 100 ); end

        % Display message %
        fprintf( 2, 'Missing pixel interpolation : exporting chromatic matrix ...\n' );

        % Import chromatic matrix %
        imwrite( uint8( flS ), [ flPath '/ortho/ortho-photo-interpolated.png' ] ) / 255;

    end

