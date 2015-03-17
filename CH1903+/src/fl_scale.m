
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

    function flScale = fl_scale( flRef, flRaw )

        % Scaling factor counter %
        flCount = 0;

        % Scale factor accumulator %
        flScale = 0;

        % First dimension loop %
        for fli = 1 : size( flRef, 1 )

            % Second dimension loop %
            for flj = fli + 1 : size( flRef, 1 )

                % Compute distancies %
                flrDst = sqrt( ( flRef(fli,1) - flRef(flj,1) )^2 + ( flRef(fli,2) - flRef(flj,2) )^2 + ( flRef(fli,3) - flRef(flj,3) )^2 );
                flwDst = sqrt( ( flRaw(fli,1) - flRaw(flj,1) )^2 + ( flRaw(fli,2) - flRaw(flj,2) )^2 + ( flRaw(fli,3) - flRaw(flj,3) )^2 );

                % Accumulate scale factor %
                flScale += flrDst / flwDst;

                % Update factor counter %
                flCount = flCount + 1;

            end

        end

        % Compute scale factor %
        flScale = flScale / flCount;

    end
