from snappynt.ManifoldNT import ManifoldNT
from sage.all import CC

def compute_trace_field(manifold_name, precision, degree):
    """
    manifold_name should be a string that snappy can understand. I.e. one that can be
    fed to snappy.Manifold().
    precision and degree are both integers that specify the parameters for LLL.
    """
    mfld = ManifoldNT(manifold_name)
    field = mfld.trace_field(prec=precision, degree=degree)
    if field is None:
        return None
    else:
        d = {
            "defining polynomial": str(field.defining_polynomial()),
            "generator name": str(field.gen()),
            "numerical root": {
                "real part": float(CC(field.gen_embedding()).real_part()),
                "imaginary part": float(CC(field.gen_embedding()).imag_part()),
            },
            "discriminant": int(field.discriminant()),
            "signature": str(field.signature()),
        }
        return d
