/*
 * FOXEL Laboratories - Certification
 *
 * Copyright (c) 2013-2015 FOXEL SA - http://foxel.ch
 * Please read <http://foxel.ch/license> for more information.
 *
 *
 * Author(s):
 *
 *      Nils Hamel <n.hamel@foxel.ch>
 *
 *
 * This file is part of the FOXEL project <http://foxel.ch>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * Additional Terms:
 *
 *      You are required to preserve legal notices and author attributions in
 *      that material or in the Appropriate Legal Notices displayed by works
 *      containing it.
 *
 *      You are required to attribute the work as explained in the "Usage and
 *      Attribution" section of <http://foxel.ch/license>.
 */

    # include <stdio.h>
    # include <stdlib.h>
    # include <string.h>
    # include <math.h>

    /*! \brief Main function
     *
     *
     *  \param  argv Main function standard parameter
     *  \param  argc Main function standard parameter
     *
     *  \return Returns exit code
     */

    int main ( int argc, char ** argv ) {

        /* Path variables */
        char flcPath[256] = { '\0' };
        char flpPath[256] = { '\0' };
        char flrPath[256] = { '\0' };

        /* Length variables */
        long flcSize = 0;
        long flpSize = 0;

        /* Parsing variables */
        long flParse = 0;
        long flSearch = 0;

        /* Distance variables */
        double fltDist = 0;
        double flcDist = 0;
        double flpDist = 0;

        /* Reading variables */
        int flr = 0;
        int flg = 0;
        int flb = 0;
        int fla = 0;
        int flc = 0;
        
        /* Array pointer variables */
        double * flcArray = NULL;
        double * flpArray = NULL;

        /* Stream variables */
        FILE * flcStream = NULL;
        FILE * flpStream = NULL;
        FILE * flrStream = NULL;

        /* Create input path */
        sprintf( flcPath, "%s/density/camera.xyzrgba", argv[1] );
        sprintf( flpPath, "%s/density/cloud.xyzrgba" , argv[1] );
        sprintf( flrPath, "%s/density/results.dat"   , argv[1] );

        /* Create input streams */
        flcStream = fopen( flcPath, "r" );
        flpStream = fopen( flpPath, "r" );

        /* Retrieve stream sizes */
        flc = fscanf( flcStream, "%li", & flcSize );
        flc = fscanf( flpStream, "%li", & flpSize );

        /* Allocate arrays memory */
        flcArray = ( double * ) malloc( flcSize * 3 * sizeof( double ) );
        flpArray = ( double * ) malloc( flpSize * 3 * sizeof( double ) );

        /* Input stream reading */
        for ( flParse = 0; flParse < flcSize; flParse ++ ) 

            /* Read point definition */
            flc = fscanf( flcStream, "%lf %lf %lf %i %i %i %i", flcArray + flParse * 3, flcArray + flParse * 3 + 1, flcArray + flParse * 3 + 2, & flr, & flg, & flb, & fla );

        /* Input stream reading */
        for ( flParse = 0; flParse < flpSize; flParse ++ ) 

            /* Read point definition */
            flc = fscanf( flpStream, "%lf %lf %lf %i %i %i %i", flpArray + flParse * 3, flpArray + flParse * 3 + 1, flpArray + flParse * 3 + 2, & flr, & flg, & flb, & fla );

        /* Close input streams */
        fclose( flcStream );
        fclose( flpStream );

        /* Create output stream */
        flrStream = fopen( flrPath, "w" );

        /* Parsing points */
        for ( flParse = 0; flParse < flpSize; flParse += 3 ) {

            /* Initialize search */
            flcDist = 1e100;
            flpDist = 1e100;

            /* Search nearest camera */
            for ( flSearch = 0; flSearch < flcSize; flSearch += 3 ) {

                /* Compute distance */
                fltDist = sqrt( 

                    ( * ( flpArray + flParse     ) - * ( flcArray + flSearch     ) ) * ( * ( flpArray + flParse     ) - * ( flcArray + flSearch     ) ) +
                    ( * ( flpArray + flParse + 1 ) - * ( flcArray + flSearch + 1 ) ) * ( * ( flpArray + flParse + 1 ) - * ( flcArray + flSearch + 1 ) ) +
                    ( * ( flpArray + flParse + 2 ) - * ( flcArray + flSearch + 2 ) ) * ( * ( flpArray + flParse + 2 ) - * ( flcArray + flSearch + 2 ) )

                );

                /* Compare distance */
                if ( fltDist < flcDist ) flcDist = fltDist;

            }

            /* Search nearest camera */
            for ( flSearch = 0; flSearch < flcSize; flSearch += 3 ) {

                /* Avoid identical point */
                if ( flSearch != flParse ) {

                    /* Compute distance */
                    fltDist = sqrt( 

                        ( * ( flpArray + flParse     ) - * ( flpArray + flSearch     ) ) * ( * ( flpArray + flParse     ) - * ( flpArray + flSearch     ) ) +
                        ( * ( flpArray + flParse + 1 ) - * ( flpArray + flSearch + 1 ) ) * ( * ( flpArray + flParse + 1 ) - * ( flpArray + flSearch + 1 ) ) +
                        ( * ( flpArray + flParse + 2 ) - * ( flpArray + flSearch + 2 ) ) * ( * ( flpArray + flParse + 2 ) - * ( flpArray + flSearch + 2 ) )

                    );

                    /* Compare distance */
                    if ( fltDist < flpDist ) flpDist = fltDist;

                }

            }

            /* Export results */
            fprintf( flrStream, "%lf %lf\n", flcDist, flpDist );

        }

        /* Close output stream */
        fclose( flrStream );

        /* Return to system */
        return( EXIT_SUCCESS );

    }
