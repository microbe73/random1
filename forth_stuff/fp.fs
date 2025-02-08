: qform ( F: a b c -- x- x+ )
frot ftuck 4e0 f* f* frot ftuck -1e0 f* frot  frot fswap fdup f* fswap f- fsqrt fover fover f+ frot frot f- frot 2e0 f* ftuck f/ frot frot f/
;
: discr ( F: a b c -- discriminant ) fswap fdup f* frot frot 4e0 f* f* f- fsqrt ;
: qflocal ( F: a b c -- x- x+ )
{ F: a F: b F: c } a b c discr b -1e0 f* fover fover f+ frot frot fswap f- a 2e0 f* ftuck f/ frot frot f/ ;
