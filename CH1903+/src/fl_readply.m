
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

    function [ flVertex flSize flpStack flpType flpName flFormat flxr ] = fl_readply( flPly )

        % Create input stream %
        flf = fopen( flPly, 'r' );

        % Check input stream %
        if ( flf == -1 )

            % Display message %
            fprintf( 2, 'Error : unable to open %s file\n', flPly );

        else

            % Initialize reading %
            flFormat = '';
            flMode   = 1;
            flSize   = 0;
            flpStack = 0;

            % Initialize fast array access %
            flxr = zeros( 1, 6 );

            % Reading loop %
            while ( ( ~ feof( flf ) ) && ( flMode > 0 ) )

                % Reading mode %
                if     ( flMode == 1 )

                    % Read token %
                    flToken = fscanf( flf, '%s', 1 );

                    % Detect format consistency %
                    if ( strcmp( flToken, 'ply' ) ); flMode = 2; else; flMode = 0; end

                elseif ( flMode == 2 )

                    % Read token %
                    flToken = fscanf( flf, '%s', 1 );

                    % Detect format consistency %
                    if ( strcmp( flToken, 'format' ) )

                        % Read token and detect format consistency %
                        if ( strcmp( fscanf( flf, '%s', 1 ), 'ascii' ) ) 

                            % Update mode %
                            flMode = 3;

                        else; flMode = 0; end

                    else; flMode = 0; end

                elseif ( flMode == 3 )

                    % Read token %
                    flToken = fscanf( flf, '%s', 1 );

                    % Detect specific token %
                    if     ( strcmp( flToken, 'element' ) )

                        % Read secondary token %
                        if ( strcmp( fscanf( flf, '%s', 1 ), 'vertex' ) )

                            % Import element vertex count %
                            flSize = fscanf( flf, '%i', 1 );

                        end

                    elseif ( strcmp( flToken, 'property' ) );

                        % Update property stack %
                        flpStack += 1;

                        % Read token %
                        flpType{ flpStack } = fscanf( flf, '%s', 1 );

                        % Detect property type %
                        if     ( strcmp( flpType{ flpStack }, 'float' ) )

                            % Update format string %
                            flFormat = [ flFormat '%f ' ];

                        elseif ( strcmp( flpType{ flpStack }, 'uchar' ) )

                            % Update format string %
                            flFormat = [ flFormat '%i ' ];

                        end

                        % Read token %
                        flpName{ flpStack } = fscanf( flf, '%s', 1 );

                        % Detect property name %
                        if     ( strcmp( flpName{ flpStack }, 'x' ) )

                            % Fast array access %
                            flxr(1) = flpStack;

                        elseif ( strcmp( flpName{ flpStack }, 'y' ) )

                            % Fast array access %
                            flxr(2) = flpStack;

                        elseif ( strcmp( flpName{ flpStack }, 'z' ) )

                            % Fast array access %
                            flxr(3) = flpStack;

                        elseif ( strcmp( flpName{ flpStack }, 'red' ) )

                            % Fast array access %
                            flxr(4) = flpStack;

                        elseif ( strcmp( flpName{ flpStack }, 'green' ) )

                            % Fast array access %
                            flxr(5) = flpStack;

                        elseif ( strcmp( flpName{ flpStack }, 'blue' ) )

                            % Fast array access %
                            flxr(6) = flpStack;

                        end

                    elseif ( strcmp( flToken, 'end_header' ) );

                        % Update mode %
                        flMode = 4;

                    end

                elseif ( flMode == 4 )

                    % Initialze cell array %
                    flVertex = zeros( flSize, flpStack );

                    % Reading vertex %
                    for fli = 1 : flSize; flVertex( fli, 1 : flpStack ) = fscanf( flf, flFormat, flpStack ); end

                end

            end

            % Detect reading error on format %
            if ( flMode == 0 ) 

                % Display message %
                fprintf( 2, 'Error : unable to interpret %s content\n', flPly );

            end

            % Close input stream %
            fclose( flf );

        end

    end
