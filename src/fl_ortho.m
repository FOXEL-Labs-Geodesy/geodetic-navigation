
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

    function fl_ortho( flPath, x1, y1, x2, y2, pixpermn95 )

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Importing CH1903+ point cloud vertex ...\n' );

        % Import origin point (MN95 NF02 - CH1903+) %
        flOrg = load( [ flPath '/origin.xyz' ] );

        % Import aligned point cloud %
        flrPC = load( [ flPath 'aligned/aligned.xyzrgb' ] );

        % Restor point cloud frame %
        flrPC(:,1) += flOrg(1,1);
        flrPC(:,2) += flOrg(1,2);
        flrPC(:,3) += flOrg(1,3);

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Preparing image matrix ...\n' );

        % Create ortho-photo size %
        flW = fix( ( x2 - x1 ) * pixpermn95 );
        flH = fix( ( y2 - y1 ) * pixpermn95 );
        
        % Create ortho-photo matrix %
        flM = zeros( flH, flW, 3 );
        flC = zeros( flH, flW, 1 );

        % Display message %
        fprintf( 2, '\t%i\n\t%i\n', flW, flH );

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Computing primary image matrix ...\n' );

        % Point cloud vertex projection %
        for fli = 1 : size( flrPC, 1 )

            % Compute point position %
            flx = fix( ( flrPC(fli,1) - x1 ) * pixpermn95 + 0.5 );
            fly = fix( ( flrPC(fli,2) - y1 ) * pixpermn95 + 0.5 );

            % Range detection %
            if ( ( flx >= 1 ) && ( fly >= 1 ) && ( flx <= flW ) && ( fly <= flH ) )

                % Accumulating colors %
                flM(flH+1-fly,flx,1) += flrPC(fli,4);
                flM(flH+1-fly,flx,2) += flrPC(fli,5);
                flM(flH+1-fly,flx,3) += flrPC(fli,6);

                % Update count %
                flC(flH+1-fly,flx) += 1;

            end

            % Display progression %
            if ( mod( fli, 10000 ) == 0 ); fprintf( 2, '\t%3.1f%%\n', 100 * ( fli / size( flrPC, 1 ) ) ); end

        end

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Averaging primary image matrix ...\n' );

        % Parsing image pixels %
        flz = 1; for flx = 1 : flW; for fly = 1 : flH

            % Zero detection %
            if ( flC(flH+1-fly,flx) ~= 0 )

                % Computing color average %
                flM(flH+1-fly,flx,1) /= flC(flH+1-fly,flx);
                flM(flH+1-fly,flx,2) /= flC(flH+1-fly,flx);
                flM(flH+1-fly,flx,3) /= flC(flH+1-fly,flx);

            else 

                % Update zero count %
                flz += 1;

            end

        end; end

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Computing secondary image matrix ...\n' );

        % Loop on zeros %
        while ( flz > 0 )

            % Parsing image pixels %
            for flx = 1 : flW; for fly = 1 : flH

                % Detect zero %
                if ( flC(flH+1-fly,flx) == 0 )

                    % Compute square edges %
                    fllx = flx - 1; if ( fllx < 1   ) fllx = 1;   end
                    flhx = flx + 1; if ( flhx > flW ) flhx = flW; end
                    flly = fly - 1; if ( flly < 1   ) flly = 1;   end
                    flhy = fly + 1; if ( flhy > flH ) flhy = flH; end

                    % Reset color accumulators %
                    flr = 0;
                    flg = 0;
                    flb = 0;
                    flc = 0;
                    fld = 0;

                    % Parsing sub-square %
                    for flu = fllx : flhx; for flv = flly : flhy

                        % Zero detection %
                        if ( flC(flH+1-flv,flu) > 0 )

                            % Compute distances %
                            flk = 1 / sqrt( (flx-flu)^2 + (fly-flv)^2 );

                            % Accumulates colors %
                            flr += flM(flH+1-flv,flu,1)*flk;
                            flg += flM(flH+1-flv,flu,2)*flk;
                            flb += flM(flH+1-flv,flu,3)*flk;

                            % Update distance accumulation %
                            fld += flk;

                            % Update count %
                            flc += 1;

                        end

                    end; end

                    % Detect statistic %
                    if ( flc > 1 )

                        % Assign color %
                        flM(flH+1-fly,flx,1) = flr / fld;
                        flM(flH+1-fly,flx,2) = flg / fld;
                        flM(flH+1-fly,flx,3) = flb / fld;

                        % Update zero count %
                        flz -= 1;

                        % Remove zero condition %
                        flC(flH+1-fly,flx) = -1;

                    end

                end

            end; end

            % Parsing image pixels %
            for flx = 1 : flW; for fly = 1 : flH

                % Reset values %
                if ( flC(flH+1-fly,flx) < 0 ); flC(flH+1-fly,flx) = 1; end

            end; end

            % Display progression %
            fprintf( 2, '\t%i\n', flz );

            % Export ortho-photo %
            imwrite( flM / 256, [ flPath '/ortho/ortho-photo-' num2str( flz ) '.png' ] );

        end

        % Display message %
        fprintf( 2, 'Ortho-photogrammetry : Saving ortho-photo ...\n' );

        % Export ortho-photo %
        imwrite( flM / 256, [ flPath '/ortho/ortho-photo.png' ] );

    end

