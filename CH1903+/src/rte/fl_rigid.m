
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

    function [ flR flt ] = fl_rigid( flRef, flRaw )

        % Compute geometric centers %
        flrCenter = mean( flRef );
        flwCenter = mean( flRaw );

        % Build estimation matrix %
        flMat = ( flRef - repmat( flrCenter, size( flRef, 1 ), 1 ) )' * ( flRaw - repmat( flwCenter, size( flRaw, 1 ), 1 ) );

        % Singular values decomposition on estimation matrix %
        [ flU, flS, flV ] = svd( flMat );

        % Build estimated rotation matrix %
        flR = flV * flU';

        % Reflection detection %
        if ( det( flR ) < 0 ); flV(:,3) *= -1; flR = flV * flU'; end

        % Build estimated translation vector %
        flt = flwCenter' - flR * flrCenter';

    end

