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
    # include <omp.h>

/*! \brief Main function
 *
 *  The main function reads the provided input ply files, expected to be
 *  in x, y, z, red, green and blue format and compute both peridistances
 *  to camera and to the points set itself, for each element of the points
 *  set. The results are exported in the output file.
 *
 *  Usage :
 *  
 *  ./fl_peridistance path_to_set path_to_camera number_of_threads
 *
 *  where the path_to_set is the path to the directory structure containing
 *  the aligned points set. The path_to_camera points the same for the
 *  camera trajectory points set.
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

        /* Token variables */
        char flToken[256] = { '\0' };

        /* Size variables */
        long flcSize = 0;
        long flpSize = 0;

        /* Parsing variables */
        long flParse  = 0;
        long flSearch = 0;

        /* Distance variables */
        double fltDist = 0.0;
        double flcDist = 0.0;
        double flpDist = 0.0;

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

        /* Create stream paths */
        sprintf( flcPath, "%s/aligned/cloud.ply", argv[2] );
        sprintf( flpPath, "%s/aligned/cloud.ply", argv[1] );
        sprintf( flrPath, "%s/peridensity/peridensity.dat", argv[1] );

        /* Create input streams */
        flcStream = fopen( flcPath, "r" );
        flpStream = fopen( flpPath, "r" );

        /* Detect failure */
        if ( ( flcStream == NULL ) || ( flpStream == NULL ) ) {

            /* Display message */
            fprintf( stderr, "Error : unable to open input streams\n" );

            /* Close stream */
            if ( flcStream != NULL ) fclose( flcStream );
            if ( flpStream != NULL ) fclose( flpStream );

            /* Exit to system */
            return( EXIT_FAILURE );

        }

        /* Camera ply header reading */
        do { 

            /* Read token */
            flc = fscanf( flcStream, "%s", flToken ); 

            /* Analyse token */
            if ( strcmp( flToken, "vertex" ) == 0 ) {

                /* Read vertex count */
                flc = fscanf( flcStream, "%li", & flcSize );

            }

        /* Header end */
        } while ( strcmp( flToken, "end_header" ) != 0 );

        /* Allocate array memory */
        flcArray = ( double * ) malloc( flcSize * 3 * sizeof( double ) );

        /* Input stream reading */
        for ( flParse = 0; flParse < flcSize; flParse ++ ) {

            /* Read point coordinates */
            flc = fscanf( flcStream, "%lf %lf %lf %i %i %i", 

                flcArray + ( flParse * 3 ), 
                flcArray + ( flParse * 3 ) + 1,
                flcArray + ( flParse * 3 ) + 2, 

            & flr, & flg, & flb );

        }

        /* Points set ply header reading */
        do { 

            /* Read token */
            flc = fscanf( flpStream, "%s", flToken ); 

            /* Analyse token */
            if ( strcmp( flToken, "vertex" ) == 0 ) {

                /* Read vertex count */
                flc = fscanf( flpStream, "%li", & flpSize );

            }

        /* Header end */
        } while ( strcmp( flToken, "end_header" ) != 0 );

        /* Allocate array memory */
        flpArray = ( double * ) malloc( flpSize * 3 * sizeof( double ) );

        /* Input stream reading */
        for ( flParse = 0; flParse < flpSize; flParse ++ ) {

            /* Read point coordinates */
            flc = fscanf( flpStream, "%lf %lf %lf %i %i %i", 

                flpArray + ( flParse * 3 ), 
                flpArray + ( flParse * 3 ) + 1, 
                flpArray + ( flParse * 3 ) + 2, 

            & flr, & flg, & flb );

        }

        /* Close input streams */
        fclose( flcStream );
        fclose( flpStream );

        /* Create output stream */
        flrStream = fopen( flrPath, "w" );

        /* Detect failure */
        if ( flrStream == NULL ) {

            /* Display message */
            fprintf( stderr, "Error : unable to open output stream\n" );

            /* Exit to system */
            return( EXIT_FAILURE );

        }

        /* Parsing points set vertex */
        # pragma omp parallel firstprivate(flParse,flSearch,flcSize,flpSize,flcDist,flpDist,fltDist) num_threads( atoi( argv[2] ) )
        # pragma omp for
        for ( flParse = 0; flParse < flpSize; flParse += 3 ) {

            /* Search for peridistances */
            flcDist = 1e100;
            flpDist = 1e100;

            /* Search nearest camera */
            for ( flSearch = 0; flSearch < flcSize; flSearch += 3 ) {

                /* Compute distance camera-point */
                fltDist = sqrt( 

                    ( * ( flpArray + flParse     ) - * ( flcArray + flSearch     ) ) * ( * ( flpArray + flParse     ) - * ( flcArray + flSearch     ) ) +
                    ( * ( flpArray + flParse + 1 ) - * ( flcArray + flSearch + 1 ) ) * ( * ( flpArray + flParse + 1 ) - * ( flcArray + flSearch + 1 ) ) +
                    ( * ( flpArray + flParse + 2 ) - * ( flcArray + flSearch + 2 ) ) * ( * ( flpArray + flParse + 2 ) - * ( flcArray + flSearch + 2 ) )

                );

                /* Search for smallest distance */
                if ( fltDist < flcDist ) flcDist = fltDist;

            }

            /* Search nearest point */
            for ( flSearch = 0; flSearch < flpSize; flSearch += 3 ) {

                /* Avoid identical point */
                if ( flSearch != flParse ) {

                    /* Compute distance point-point */
                    fltDist = sqrt( 

                        ( * ( flpArray + flParse     ) - * ( flpArray + flSearch     ) ) * ( * ( flpArray + flParse     ) - * ( flpArray + flSearch     ) ) +
                        ( * ( flpArray + flParse + 1 ) - * ( flpArray + flSearch + 1 ) ) * ( * ( flpArray + flParse + 1 ) - * ( flpArray + flSearch + 1 ) ) +
                        ( * ( flpArray + flParse + 2 ) - * ( flpArray + flSearch + 2 ) ) * ( * ( flpArray + flParse + 2 ) - * ( flpArray + flSearch + 2 ) )

                    );

                    /* Search for smallest distance */
                    if ( fltDist < flpDist ) flpDist = fltDist;

                }

            }

            /* Export peridistances in output stream */
            fprintf( flrStream, "%lf %lf\n", flcDist, flpDist );

        }

        /* Close output stream */
        fclose( flrStream );

        /* Return to system */
        return( EXIT_SUCCESS );

    }

