Math
====

.. cpp:function:: vector AngleNormalize( vector v )

.. cpp:function:: vector CalcRelativeVector( vector a, vector b )

.. cpp:function:: vector CalcRelativeAngles( vector a, vector b )

.. cpp:function:: bool BoxIntersectsBox( vector mins1, vector maxs1, vector mins2, vector maxs2 )

.. cpp:function:: float clamp( number a, number b, number c )

.. cpp:function:: float Interpolate( number startTime, number moveTime, number easeIn, number easeOut )

  Interpolate with cubic hermite during ease-in and ease-out times

.. cpp:function:: vector LerpVector( vector vecFrom, vector vecTo, float percent )

  Lineraly interpolate between two vectors

.. cpp:function:: vector GetRandom3DPointIn2DCircle( number radius, var base3D_or_null )

  Get a random 2d point in a circle, as a 3d point, with optional 3d base

.. cpp:function:: float Graph( number a, number b, number c, number d, number e )

.. cpp:function:: float GraphCapped( number a, number b, number c, number d, number e )

.. cpp:function:: vector GraphCappedVector( number a, number b, number c, vector d, vector e )

.. cpp:function:: float Smooth01( float f, int i )

.. cpp:function:: var SmoothCD( number a, number b, number c, number d, number e )

.. cpp:function:: var SmoothCDVector( vector a, vector b, vector c, number d, number e )

.. cpp:function:: vector GetApproxClosestHitboxToRay( entity ent, vector v1, vector v2 )
