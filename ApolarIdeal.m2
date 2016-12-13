-- -*- coding: utf-8 -*-
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- APOLAR IDEAL ----------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Copyright 2012 Zach Teitler
--
-- This program is free software: you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, either version 3 of the License, or (at your option) any later
-- version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
-- details.
--
-- You should have received a copy of the GNU General Public License along with
-- this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- This is pre-release software which has limitations and possibly bugs.
-- Please use at your own risk.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


newPackage(
  "ApolarIdeal",
  Version => "0.3.2",
  Date => "August 24, 2015",
  Authors => {
    {
      Name => "Zach Teitler",
      Email => "zteitler@member.ams.org",
      HomePage => "http://math.boisestate.edu/~zteitler/"
    }
  },
  Headline => "apolar ideals",
  DebuggingMode=>false
)

export {
  "catKer",
  "Apolar",
  "jacIdeal",
  "socleDegree",
  "dualSocleGen",
  "hessian"
}


--------------------------------------------------------------------------------
-- METHODS ---------------------------------------------------------------------
--------------------------------------------------------------------------------

catKer = method()
catKer (List, List) := (L,D) -> (
  R := ring(first L);
  
  if( length(D) != degreeLength(R) ) then (
    error "catKer: expected length of degree vector to equal degreeLength of ring";
  );
  
  if( not all(L,F -> isHomogeneous(F)) ) then (
    error "catKer: expected homogeneous polynomials";
  );
  
  B := basis(D,R);
  
  K := intersect apply(L, f -> (
    d := degree f;
    B' := basis(d-D,R);
    Cat := diff( (transpose B')*B, f );
    promote(ideal first entries(B*(gens kernel Cat)), R)
  ));
  
  return trim K;
)
catKer (RingElement, List) := (f,D) -> catKer({f},D)
catKer (List, ZZ) := (L,r) -> catKer(L,{r})
catKer (RingElement, ZZ) := (f,r) -> catKer({f},{r})


Apolar = method()
Apolar (List) := (L) -> (
  R := ring(first L);
  degreeLen := degreeLength R;
  zeroDegree := toList(degreeLen:0);
  oneDegree := toList(degreeLen:1);
  
  if( not all(L, F -> isHomogeneous(F)) ) then (
    error "Apolar: expected homogeneous polynomial(s)";
  );
  
  degreeList := sum(apply(L, f -> set(zeroDegree..((degree f)+oneDegree))));

--  apoideal := ideal(0_R);
--  for i from 0 to d+1 do (
--    apoideal = apoideal + catKer(L,i);
--  );

  apoideal := sum(apply(toList degreeList, D -> catKer(L,D)));
  
  return(trim apoideal);
)
Apolar (RingElement) := (f) -> Apolar({f})


jacIdeal = method()
jacIdeal (RingElement) := f -> trim ideal flatten entries jacobian ideal f

socleDegree = method()
socleDegree (Ideal) := I -> first degree first reduceHilbert hilbertSeries I

dualSocleGen = method()
dualSocleGen (Ideal) := I -> (
  R := ring I;
  d := socleDegree I;
  bb := super basis(d,I);
  B := basis(d,R);
  K := gens ker diff(transpose bb, B);
  ffmatrix := B * K;
  return ffmatrix_(0,0);
)


hessian = method()
hessian (RingElement) := f -> (
  R := ring f;
  B := vars R;
  Hessmatrix := diff( (transpose B)*B , f );
  return det Hessmatrix;
)


--------------------------------------------------------------------------------
-- DOCUMENTATION ---------------------------------------------------------------
--------------------------------------------------------------------------------

beginDocumentation()

document {
  Key => {
    ApolarIdeal
  },
  Headline => "apolar ideals",
  PARA "This mini-package has a few tools for studying apolar ideals and related items."
}

document {
  Key => {
    catKer,
    (catKer,RingElement,ZZ),
    (catKer,List,ZZ)
  },
  Headline => "kernel of catalecticant",
  SYNOPSIS {
    Heading => "kernel of catalecticant of a polynomial",
    Usage => "catKer(f,r)",
    Inputs => {
      "f" => RingElement => "a homogeneous polynomial",
      "r" => ZZ => "an integer"
    },
    Outputs => {
      Ideal => "the ideal generated by the degree r kernel of the catalecticant of f"
    },
    PARA "This gives the kernel of the r'th catalecticant of
    a homogeneous form f.",
    EXAMPLE lines ///
      R = QQ[x,y,z];
      f = x^2*y - y^2*z;
      catKer(f,2)
    ///
  },
  SYNOPSIS {
    Heading => "kernel of catalecticant of a linear series",
    Usage => "catKer(L,r)",
    Inputs => {
      "L" => List => "list of homogeneous polynomials",
      "r" => ZZ => "an integer"
    },
    Outputs => {
      Ideal => "the ideal generated by the degree r kernel of the catalecticant of the list"
    },
    PARA "This gives the kernel of the r'th catalecticant of
    a list of homogeneous forms, that is, the intersection of
    the kernels of catalecticants of the forms in the list.",
    EXAMPLE lines ///
      x = symbol x;
      R = QQ[x_1..x_4];
      catKer({x_1*x_2*x_3,x_1*x_2*x_4,x_1*x_3*x_4,x_2*x_3*x_4},2)
    ///
  }
}

document {
  Key => {
    Apolar,
    (Apolar,RingElement),
    (Apolar,List)
  },
  Headline => "apolar ideal",
  SYNOPSIS {
    Heading => "apolar ideal of a homogeneous polynomial",
    Usage => "Apolar(f)",
    Inputs => {
      "f" => RingElement => "a homogeneous polynomial"
    },
    Outputs => {
      Ideal => "the apolar ideal of f"
    },
    PARA "This gives the apolar or annihilating ideal of f.",
    EXAMPLE lines ///
      R = QQ[x,y,z];
      f = x^2*y - y^2*z;
      Apolar(f)
    ///
  },
  SYNOPSIS {
    Heading => "apolar ideal of a list of polynomials",
    Usage => "Apolar(L)",
    Inputs => {
      "L" => List => "a list of homogeneous polynomials"
    },
    Outputs => {
      Ideal => "the apolar ideal of f"
    },
    PARA "This gives the apolar or annihilating ideal of
    a list of homogeneous polynomials, that is, the ideal
    of differential operators that annihilate each member
    of the list.",
    EXAMPLE lines ///
      x = symbol x;
      R = QQ[x_1..x_4];
      Apolar({x_1*x_2*x_3,x_1*x_2*x_4,x_1*x_3*x_4,x_2*x_3*x_4})
      Apolar({x_1,x_2^2,x_3^3,x_4^4})
    ///
  }
}

document {
  Key => {
    jacIdeal,
    (jacIdeal,RingElement)
  },
  Headline => "jacobian ideal",
  Usage => "jacIdeal(f)",
  Inputs => {
    "f" => RingElement => "a homogeneous polynomial"
  },
  Outputs => {
    Ideal => "the jacobian ideal of f"
  },
  PARA "This gives the jacobian ideal of f, that is, the ideal
  generated by the first partial derivatives of f.
  This ideal defines the singular locus of the (affine) hypersurface
  defined by f.
  In particular f defines a smooth projective hypersurface if and only if
  its jacobian ideal is Artinian.",
  PARA "The point of this function is to enable study of questions raised in
  Lorenzo Di Biagio, Elisa Postinghel ",
  EM "Apolarity, Hessian and Macaulay polynomials ",
  HREF { "http://arxiv.org/abs/1007.4891v1" },
  EXAMPLE lines ///
    R = QQ[x,y,z];
    f = x^2*y - y^2*z;
    jacIdeal(f)
  ///
}

document {
  Key => {
    socleDegree,
    (socleDegree,Ideal)
  },
  Headline => "socle degree of an Artinian ideal",
  Usage => "socleDegree(I)",
  Inputs => {
    "I" => Ideal => "an Artinian ideal"
  },
  Outputs => {
    ZZ => "an integer, the socle degree of I"
  },
  PARA "This gives the socle degree of the Artinian ideal I,
  that is the highest degree in which I is strictly smaller than the ring.",
  PARA "Warning: the implementation of this function should be
  checked carefully.",
  EXAMPLE lines ///
    R = QQ[x,y,z];
    f = x^2*y - y^2*z;
    socleDegree Apolar f
  ///
}

document {
  Key => {
    dualSocleGen,
    (dualSocleGen, Ideal)
  },
  Headline => "apolar generator of an Artinian Gorenstein ideal",
  Usage => "dualSocleGen(I)",
  Inputs => {
    "I" => Ideal => "an Artinian Gorenstein ideal"
  },
  Outputs => { 
    RingElement => "a polynomial f"
  },
  PARA "This gives a polynomial f such that I is the apolar ideal of f.
  The ideal I must be Artinian Gorenstein, that is, I has codimension 1
  in the ring in its socle degree. The output polynomial is only defined
  up to a nonzero scalar factor.",
  EXAMPLE lines ///
    R = QQ[x,y,z];
    f = x^2*y - y^2*z;
    I = Apolar f;
    g = dualSocleGen I
    f / g  -- they are equal up to a scalar multiple
    Apolar g == I
    ff = random(6,R)
    II = Apolar ff;
    gg = dualSocleGen II
    ff / gg -- they are equal up to a scalar multiple
    Apolar gg == II
  ///
}



document {
  Key => {
    hessian,
    (hessian,RingElement)
  },
  Headline => "Hessian",
  PARA "The Hessian of a polynomial --- the determinant of the matrix
  of its second partial derivatives.",
  EXAMPLE lines ///
    R = QQ[x,y,z];
    hessian(x^3+y^3+z^3)
    hessian(x*y*z)
    h = hessian(x^2*y+y^2*z)
    Apolar h
    g = dualSocleGen jacIdeal(x^3+y^3+z^3)
    Apolar g
  ///
}

end

