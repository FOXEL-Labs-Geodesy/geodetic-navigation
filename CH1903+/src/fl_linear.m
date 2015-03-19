
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

    function flrPC = fl_linear( flwPC, flR, flt, flxr )

        % Initialize array memory %
        flrPC = flwPC;

        % Apply linear transformation on raw point cloud vertex %
        flrPC(:,flxr(1)) = ( flwPC(:,1) - flt(1) ) * flR'(1,1) + ( flwPC(:,2) - flt(2) ) * flR'(1,2) + ( flwPC(:,3) - flt(3) ) * flR'(1,3);
        flrPC(:,flxr(2)) = ( flwPC(:,1) - flt(1) ) * flR'(2,1) + ( flwPC(:,2) - flt(2) ) * flR'(2,2) + ( flwPC(:,3) - flt(3) ) * flR'(2,3);
        flrPC(:,flxr(3)) = ( flwPC(:,1) - flt(1) ) * flR'(3,1) + ( flwPC(:,2) - flt(2) ) * flR'(3,2) + ( flwPC(:,3) - flt(3) ) * flR'(3,3);

    end
