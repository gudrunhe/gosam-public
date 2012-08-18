# vim: ts=3:sw=3:expandtab

from golem.util.config import Property
from golem.util.path import golem_path


process_name = Property("process_name",
   """\
   A symbolic name for this process. This name will be used
   as a prefix for the Fortran modules.

   Golem will insert an underscore after this prefix.
   If the process name is left blank no prefix will be used
   and no extra underscore will be generated.
   """,
   str, "")

process_path = Property("process_path",
   """\
   The path to which all Form output is written.
   If no absolute path is given, the path is interpreted relative
   to the working directory from which golem-main.py is run.

   Example:
   process_path=/scratch/golem_processes/process1
   """)

qgraf_in = Property("in",
   """\
   A comma-separated list of initial state particles.
   Which particle names are valid depends on the
   model file in use.

   Examples (Standard Model):
   1) in=u,u~
   2) in=e+,e-
   3) in=g,g
   """,
   list)

qgraf_out = Property("out",
   """\
   A comma-separated list of final state particles.
   Which particle names are valid depends on the
   model file in use.

   Examples (Standard Model):
   1) out=H,u,u~
   2) out=e+,e-,gamma
   3) out=b,b~,t,t~
   """,
   list)

model = Property("model",
   """\
   This option allows the selection of a model for the
   Feynman rules. It has to conform with one of four possible
   formats:

   1) model=<name>
   2) model=<path>, <name>
   3) model=<path>, <number>
   4) model=FeynRules, <path>

   Format 1) searches for the model files <name>, <name>.hh
   and <name>.py in the models/ directory under the installation
   path of Golem.

   Format 2) is similar to format 1) but <path> is used instead
   of the models/ directory of the Golem installation

   Format 3) expects the files func<number>.mdl, lgrng<number>.mdl,
   prtcls<number>.mdl and vars<number>.mdl in the directory <path>.
   These files need to be in CalcHEP/CompHEP format.

   Format 4) expects files according to the new FeynRules Python
   interface in the directory specified by <path>.
   (Not fully implemented yet)
   """,
   list)

model_options = Property("model.options",
   """\
   If the model in use supports options they can be passed via this
   property.

   """,
   list)

qgraf_power = Property("order",
   """\
   A 3-tuple <coupling>,<born>,<virt> where <coupling> denotes
   a function of the qgraf style file which can be used as
   an argument in a 'vsum' statement. For the standard model
   file 'sm' there are two such functions, 'gs' which counts
   powers of the strong coupling and 'gw' which counts powers
   of the weak coupling. <born> is the sum of powers for the
   tree level amplitude and <virt> for the virtual amplitude.
   The line
      order = gs, 4, 6
   would select all diagrams which have (gs)^4 at tree level
   and all loop graphs with (gs)^6.

   Note: The line
      order = gw, 2, 2
   does not imply that no virtual corrections are calculated.
   Instead, for the virtual corrections diagrams are chosen
   with the same order in gw but higher order in gs.

   In other models with more than two different coupling
   constants additional 'vsum' statements, which can be passed
   via the qgraph.verbatim option, might be needed
   to select the correct set of diagrams.

   If the last number is omitted no virtual corrections are
   calculated.

   See also: qgraf.options, qgraf.verbatim
   """,
   list)

helicities = Property("helicities",
   """\
   A list of helicities to be calculated. An empty list
   means that all possible helicities should be generated.

   The helicities are specified as a string of characters
   according to the following table:

      spin massive  |  'm'  '-'  '0'   '+'   'k'
        0   YES/NO  | ---- ----    0  ----  ----
      1/2   YES/NO  | ---- -1/2 ----  +1/2  ----
        1     NO    | ----   -1 ----    +1  ----
        1    YES    | ----   -1    0    +1  ----
      3/2     NO    | -3/2 ---- ----  ----  +3/2
      3/2    YES    | -3/2 -1/2 ----  +1/2  +3/2
        2     NO    |   -2 ---- ----  ----    +2
        2    YES    |   -2   -1    0    +1    +2

   Please, note that 'k' and 'm' are not in use yet but reserved
   for future extensions to higher spins.

   The characters correspond to particle 1, 2, ... from left to
   right.

   Examples:
      # e+, e- --> gamma, gamma:
      # Only three helicities required; the other ones are
      # either zero or can be obtained by symmetry
      # transformations.
      helicities=+-++,+-+-,+---;

   Multiple helicities can be encoded in patterns, which are expanded
   at the time of code generation. Patterns can have one of the following
   forms:
      [+-], [+-0], [+0] etc. : the bracket expands to one of the symbols
            in the bracket at a time.
      EXAMPLE
            helicities=[+-]+[+-0]
            # expands to 6 different helicities:
            # helicities=+++, ++-, ++0, -++, -+-, -+0
      [a=+-], etc. : as above, but the helicity is also assigned to the
            symbol and can be reused.
      EXAMPLE
            helicities=[i=+-]+i+
            # expands to two helicities
            # helicities=++++, -+-+
      [ab=+-0], etc. : as above, the first symbol is assigned the helicity,
            the second is minus the helicity
      EXAMPLE
            helicities=[qQ=+-][pP=+-]PQ[+-0]
            # expands to 12 helicities
            # helicities=++--+,++---,++--0,+-+-+,+-+--,+-+-0,\\
            #            -+-++,-+-+-,-+-+0,--+++,--++-,--++0
    
   """,
   list)

qgraf_options = Property("qgraf.options",
   """\
   A list of options which is passed to qgraf via the 'options' line.
   Possible values (as of qgraf.3.1.1) are zero, one or more of:
      onepi, onshell, nosigma, nosnail, notadpole, floop
      topol

   Please, refer to the QGraf documentation for details.
   """,
   list,
   options=["onepi", "onshell", "nosigma", "nosnail", "notadpole",
      "floop", "topol"])

qgraf_verbatim = Property("qgraf.verbatim",
   """\
   This option allows to send verbatim lines to
   the file qgraf.dat. This can be useful if the user
   wishes to put additional restricitons to the selected diagrams.
   This option is mainly inteded for the use of the operators
      rprop, iprop, chord, bridge, psum
   Note, that the use of 'vsum' might interfer with the
   option qgraf.power.

   Example:
   qgraf.verbatim=\\
      # no top quarks: \\n\\
      true=iprop[T, 0, 0];\\n\\
      # at least one Higgs:\\n\\
      false=iprop[H, 0, 0];\\n

   
   Please, refer to the QGraf documentation for details.

   See also: qgraf.options, order
   """,
   str, "")

qgraf_verbatim_lo = Property("qgraf.verbatim.lo",
   """\
   Same as qgraf.verbatim but only applied to LO diagrams.

   See also: qgraf.verbatim, qgraf.verbatim.nlo
   """,
   str, "")

qgraf_verbatim_nlo = Property("qgraf.verbatim.nlo",
   """\
   Same as qgraf.verbatim but only applied to LO diagrams.

   See also: qgraf.verbatim, qgraf.verbatim.nlo
   """,
   str, "")

ldflags_golem95 = Property("golem95.ldflags",
   """\
   LDFLAGS required to link golem95.

   Example:
   golem95.ldflags=-L/usr/local/lib/ -lgolem-gfortran-double

   """,
   str,
   "`pkg-config --libs golem`")

fcflags_golem95 = Property("golem95.fcflags",
   """\
   FCFLAGS required to compile with golem95.

   Example:
   golem95.fcflags=-I/usr/local/include/golem95

   """,
   str,
   "`pkg-config --cflags golem`")

ldflags_samurai = Property("samurai.ldflags",
   """\
   LDFLAGS required to link samurai.

   Example:
   samurai.ldflags=-L/usr/local/lib/ -lsamurai-gfortran-double

   """,
   str,
   "")

fcflags_samurai = Property("samurai.fcflags",
   """\
   FCFLAGS required to compile with samurai.

   Example:
   samurai.fcflags=-I/usr/local/include/samurai

   """,
   str,
   "")

version_samurai = Property("samurai.version",
   """\
   The version of the samurai library in use.

   Example:
   samurai.version=2.1.0

   """,
   str,
   "2.1.1")

zero = Property("zero",
   """\
   A list of symbols that should be treated as identically
   zero throughout the whole calculation. All of these
   symbols must be defined by the model file.

   Examples:
   1) # Light masses are set to zero here:
      zero=me,mU,mD,mS
   2) # Diagonal CKM matrix:
      zero=VUS, VUB, CVDC, CVDT, \\
           VCD, VCB, CVSU, CVST, \\
           VTD, VTS, CVBU, CVBC
      one=  VUD,  VCS,  VTB, \\
           CVDU, CVSC, CVBT

   See also: model, one
   """,
   list)

one = Property("one",
   """\
   A list of symbols that should be treated as identically
   one throughout the whole calculation. All of these
   symbols must be defined by the model file.

   Example:
   one=gs, e

   See also: model, zero
   """,
   list)

qgraf_bin = Property("qgraf.bin",
   """\
   Points to the QGraf executable.

   Example:
   qgraf.bin=/home/my_user_name/bin/qgraf
   """,
   str,
   "qgraf")

form_bin = Property("form.bin",
   """\
   Points to the Form executable.

   Examples:
   1) # Use TForm:
      form.bin=tform
   2) # Use non-standard location:
      form.bin=/home/my_user_name/bin/form
   """,
   str,
   "form")

haggies_bin = Property("haggies.bin",
   """\
   Points to the Haggies executable.
   Haggies is used to transform the expressions of the diagrams
   into optimized Fortran90 programs. It can be obtained from
      http://www.nikhef.nl/~thomasr/download.php
   
   Examples:
      1) haggies.bin=/home/my_user_name/bin/haggies
      2) haggies.bin=/usr/bin/java -Xmx50m -jar ./haggies.jar
   """,
   str,
   "java -jar %s" % golem_path("haggies", "haggies.jar"))

form_tmp = Property("form.tempdir",
   """\
   Temporary directory for Form. Should point to a directory
   on a local disk.

   Examples:
   form.tempdir=/tmp
   form.tempdir=/scratch
   """,
   str,
   "/tmp")

template_path = Property("templates",
   """\
   Path pointing to the directory containing the template
   files for the process. If not set golem uses the directory
   <golem_path>/templates.

   The directory must contain a file called 'template.xml'
   """,
   str,
   "")

group_diagrams = Property("group",
   """\
   Flag whether or not the tree-level diagrams should be grouped
   into a single file.
   """,
   bool,
   True)

sum_diagrams = Property("diagsum",
   """\
   Flag whether or not 1-loop diagrams with the same propagators 
   should be summed before the algebraic reduction.
   """,
   bool,
   False)

renorm = Property("renorm",
   """\
   Indicates if the UV counterterms should be generated.

   Examples:
   renorm=true
   renorm=false
   """,
   bool,
   False, experimental=True)

fc_bin = Property("fc.bin",
   """\
   Denotes the executable file of the Fortran90 compiler.
   """,
   str,
   "gfortran")

extensions = Property("extensions",
   """\
   A list of extension names which should be activated for the
   code generation. These names are not standardised at the moment.

   One option which is affected by this is LDFLAGS. In the following
   example only ldflags.looptools is added to the LDFLAGS variable
   in the makefiles whereas the variable ldflags.qcdloop is ignored.

   extensions=golem95,samurai

   ldflags.qcdloops=-L/usr/local/lib -lqcdloop

   NOTE: Make sure you activate at least one of 'samurai' and 'golem95'.

   Currently active extensions:

   samurai      --- use Samurai for the reduction
   golem95      --- use Golem95 for the reduction
   pjfry        --- use PJFry for the reduction (experimental)
   dred         --- use four dimensional algebra (dim. reduction)
   autotools    --- use Makefiles generated by autotools
   qshift       --- apply the shift of Q already at the FORM level
   topolynomial --- (with FORM >= 4.0) use the ToPolynomial command
   gaugecheck   --- modify gauge boson wave functions to allow for
                    a limited gauge check (introduces gauge*z variables)
   olp_daemon   --- (OLP interface only): generates a C-program providing
                    network access to the amplitude
   no-fr5       --- do not generate finite gamma5 renormalisation
   numpolvec    --- evaluate polarisation vectors numerically
   f77          --- in combination with the BLHA interface it generates
                    an olp_module.f90 linkable with Fortran77
   """,
   list,
   options=["samurai", "golem95", "pjfry", "dred",
      "autotools", "qshift", "topolynomial",
      "qcdloop", "avh_olo", "looptools", "gaugecheck", "derive",
      "generate-all-helicities", "olp_daemon", "numpolvec",
      "f77", "no-fr5","ninja"])

select_lo_diagrams = Property("select.lo",
   """\
   A list of integer numbers, indicating leading order diagrams to be
   selected. If no list is given, all diagrams are selected.
   Otherwise, all diagrams not in the list are discarded.

   The list may contain ranges:

   select.lo=1,2,5:10:3, 50:53

   which is equivalent to

   select.lo=1,2,5,8,50,51,52,53

   See also: select.nlo, filter.lo, filter.nlo
   """,
   list,",")

select_nlo_diagrams = Property("select.nlo",
   """\
   A list of integer numbers, indicating one-loop diagrams to be selected.
   If no list is given, all diagrams are selected.
   Otherwise, all diagrams   not in the list are discarded.

   The list may contain ranges:

   select.nlo=1,2,5:10:3, 50:53

   which is equivalent to

   select.nlo=1,2,5,8,50,51,52,53

   See also: select.lo, filter.lo, filter.nlo
   """,
   list,",")

filter_lo_diagrams = Property("filter.lo",
   """\
   A python function which provides a filter for tree diagrams.

   filter.lo=lambda d: d.iprop(Z) == 1 \\
      and d.vertices(Z, U, Ubar) == 0

   The following methods of the diagram class can be used:

   * d.rank() = the maximum rank in Q possible for this diagram
   * d.loopsize() = the number of propagators in the loop
   * d.vertices(field1, field2, ...) = number of vertices
       with the given fields
   * d.loopvertices(field1, field2, ...) = number of vertices
       with the given fields; only those vertices which have
       at least one loop propagator attached to them
   * d.iprop(field, momentum="...", twospin=..., massive=True/False,
                                                            color=...) =
       the number of propagators with the given properties:
        - field: a field or list of fields
        - momentum: a string denoting the momentum through this propagator,
               such as "k1+k2"
        - twospin: two times the spin (integer number)
        - massive: select only propagators with/without a non-zero mass
        - color: one of the numbers 1, 3, -3 or 8, or a list of
                 these numbers
   * d.chord(...) = number of loop propagators with the given properties;
       the arguments are the same as in iprop
   * d.bridge(...) = number of non-loop propagators with the given
       properties; the arguments are the same as in iprop

   See also: filter.nlo, select.lo, select.nlo
   """,
   str,"")

filter_nlo_diagrams = Property("filter.nlo",
   """\
   A python function which provides a filter for loop diagrams.

   See filter.lo for more explanation.
   """,
   str,"")

filter_module = Property("filter.module",
   """\
   A python file of predefined functions which should be available
   in filters.

   Example:

   filter.module=filter.py
   filter.nlo=my_nlo_filter("vertices.txt")
   filter.lo=my_nlo_filter("vertices.txt")

   ------ filter.py -----

   class my_nlo_filter_class:
      def __init__(self, fname):
         self.fields = []
         f = open(fname, 'r')
         for line in f.readlines():
            fields = map(lambda s: s.strip(),
                  line.split(","))
            self.fields.append(fields)
         f.close()

      def __call__(self, diag):
         for lst in self.fields:
            if diag.vertices(*lst) > 0:
               return False
         return True

   ----------------------

   See filter.lo, filter.nlo
   """,
   str,"")

debug_flags = Property("debug",
   """\
   A list of debug flags.
   Currently, the words 'lo', 'nlo' and 'all' are supported.
   """,
   list,
   options=["nlo", "lo", "numpolvec", "all"])

reference_vectors = Property("reference-vectors",
   """\
   A list of reference vectors for massive and higher spin particles.
   For vectors which are not assigned here, the program picks a 
   reference vector automatically.

   Each entry of the list has to be of the form <index>:<index>

   EXAMPLE

   in=g,u
   out=t,W+
   reference-vectors=1:2,3:4,4:3

   In this example, the gluon (particle 1) takes the momentum k2
   as reference momentum for the polarisation vector. The massive
   top quark (particle 3) uses the light-cone projection l4 of the
   W-boson as reference direction for its own momentum splitting.
   Similarly, the momentum of the W-boson is split into a direction
   l4 and one along l3.

   If cycles are generated in the list (l3 has to be known in order
   to determine l4 and vice versa in the above example) they must be
   at most of length two. For the reference momenta of lightlike
   gauge bosons the length of cycles does not matter, e.g.

   in=g,g
   out=g,g
   reference-vectors=1:2,2:3,3:4,4:1
   """,
   list)

abbrev_limit = Property("abbrev.limit",
   """\
   Maximum number of instructions per subroutine when calculating
   abbreviations, if this number is positive.
   """,
   str, "0")

abbrev_level = Property("abbrev.level",
   """\
   The level at which abbreviations are generated. The value should be
   one of:
      helicity       generates files helicity<X>/abbrevh<X>.f90
      group          generates files helicity<X>/abbrevg<G>h<X>.f90
      diagram        generates files helicity<X>/abbrevd<D>h<X>.f90
   """,
   str, "helicity",
   options=["helicity", "group", "diagram"])

r2 = Property("r2",
   """\
   The algorithm how to treat the R2 term:

   implicit    -- mu^2 terms are kept in the numerator and reduced
                  at runtime
   explicit    -- mu^2 terms are reduced analytically
   only        -- same as 'explicit' but only the R2 term is kept in
                  the result
   off         -- all mu^2 terms are set to zero
   """,
   str, "explicit",
   options=["implicit", "explicit", "off", "only"])

crossings = Property("crossings",
   """\
   A list of crossed processes derived from this process.

   For each process in the list a module similar to matrix.f90 is
   generated.

   Example:

   process_name=ddx_uux
   in=1,-1
   out=2,-2

   crossings=dxd_uux: -1 1 > 2 -2, ud_ud: 2 1 > 2 1
   """,
   list)

symmetries = Property("symmetries",
   """\
   Specifies the symmetries of the amplitude.
   
   This information is used when the list of helicities is generated.

   Possible values are:

   * flavour    -- no flavour changing interactions
            When calculating the list of helicities, fermion lines
       of PDGs 1-6 are assumed not to mix.

   * family     -- flavour changing only within families
            When calculating the list of helicities, fermion lines
       of PDGs 1-6 are assumed to mix only within families,
       i.e. a quark line connecting a up with a down quark would
       be considered, while up-bottom is not.
   * lepton     -- means for leptons what 'flavour' means for quarks
   * generation -- means for leptons what 'family' means for quarks
   * parity     -- the amplitude is invariant under parity tranformation.
                   === Parity is not implemented yet.
   * <n>=<h>    -- restriction of particle helicities,
            e.g. 1=-, 2=+ specifies helicities of particles 1 and 2
   * %<n>=<h>   -- restriction by PDG code,
            e.g. %23=+- specifies the helicity of all Z-bosons to be
            '+' and '-' only (no '0' polarisation).

            %<n> refers to both +n and -n
            %+<n> refers to +n only
            %-<n> refers to -n only
   """,
   list)

pyxodraw = Property("pyxodraw",
   """\
   Specifies whether to draw any diagrams or not.
   """,
   bool, True)

config_renorm_beta = Property("renorm_beta",
   """\
   Set the name of the same variable in config.f90

   Activates or disables beta function renormalisation

   QCD only
   """,
   bool, True)

config_renorm_logs = Property("renorm_logs",
   """\
   Set the name of the same variable in config.f90

   Activates or disables the logarithmic finite terms
   of all UV counterterms

   QCD only
   """,
   bool, True)

config_renorm_mqse = Property("renorm_mqse",
   """\
   Set the name of the same variable in config.f90

   Activates or disables the UV counterterm coming from the
   massive quark propagators

   QCD only
   """,
   bool, True)

config_renorm_decoupling = Property("renorm_decoupling",
   """\
   Set the name of the same variable in config.f90

   Activates or disables UV counterterms coming from
   massive quark loops

   QCD only
   """,
   bool, True)

config_renorm_mqwf = Property("renorm_mqwf",
   """\
   Set the name of the same variable in config.f90

   Activates or disables UV countertems coming from
   external massive quarks

   QCD only
   """,
   bool, True)

config_renorm_gamma5 = Property("renorm_gamma5",
   """\
   Set the same variable in config.f90

   Activates finite renormalisation for axial couplings in the
   't Hooft-Veltman scheme

   QCD only, works only with built-in model files.
   """,
   bool, True)

config_reduction_interoperation = Property("reduction_interoperation",
   """
   Set the same variable in config.f90. A value of '-1' lets gosam
   decide depending on the specified extensions.

   See common/config.f90 for details.
   """,
   int, -1)

config_nlo_prefactors = Property("nlo_prefactors",
   """
   Set the same variable in config.f90. The values have the 
   following meaning:

   0: A factor of alpha_(s)/2/pi is not included in the NLO result
   1: A factor of 1/8/pi^2 is not included in the NLO result
   2: The NLO includes all prefactors

   Note, however, that the factor of 1/Gamma(1-eps) is not 
   included in any of the cases.
   """,
   int, 0, options=["0","1","2"])

config_SP_check = Property("SP_check",
   """\
   Set the same variable in config.f90

   Activates test on the single for the full amplitude.
   !!Works for only for QCD and with built-in model files!!
   """,
   bool, False)

config_SP_verbosity = Property("SP_verbosity",
   """\
   Set the same variable in config.f90

   Sets the verbosity of the SP_check.
   verbosity = 0 : no output
   verbosity = 1 : output only when rescue failed
   verbosity = 2 : as 1 but PS points are written in bad.pts
   verbosity = 3 : output whenever the rescue system is used
                   with comment about the success of the rescue
   !!Works for only for QCD and with built-in model files!!
   """,
   int, 2, options=["0","1","2","3"])

config_SP_chk_threshold1 = Property("SP_chk_threshold1",
   """\
   Set the same variable in config.f90

   Threshold to declare the check on the single pole failed and 
   the activation of the rescue
   !!Works for only for QCD and with built-in model files!!
   """,
   str, 0.0001)

config_SP_rescue = Property("SP_rescue",
   """\
   Set the same variable in config.f90

   Activates rescue based on the single pole check for the full 
   amplitude.

   Note: the usage of this rescue system is most stable if used 
   with the extension 'derive' which ensures a stabler 
   reconstruction of the tensor coefficients.

   !!Works for only for QCD and with built-in model files!!
   """,
   bool, True)

config_SP_chk_threshold2 = Property("SP_chk_threshold2",
   """\
   Set the same variable in config.f90

   Threshold to declare the rescue of the ps-point failed.
   !!Works for only for QCD and with built-in model files!!
   """,
   str, 0.001)

properties = [
   process_name,
   process_path,
   qgraf_in,
   qgraf_out,
   model,
   model_options,
   qgraf_power,
   zero,
   one,
   renorm,
   helicities,
   qgraf_options,
   qgraf_verbatim,
   qgraf_verbatim_lo,
   qgraf_verbatim_nlo,
   qgraf_bin,
   form_bin,
   form_tmp,
   haggies_bin,
   fc_bin,
   group_diagrams,
   sum_diagrams,
   extensions,
   template_path,
   debug_flags,

   fcflags_golem95,
   ldflags_golem95,
   fcflags_samurai,
   ldflags_samurai,
   version_samurai,

   select_lo_diagrams,
   select_nlo_diagrams,
   filter_lo_diagrams,
   filter_nlo_diagrams,
   filter_module,

   config_renorm_beta,
   config_renorm_mqwf,
   config_renorm_decoupling,
   config_renorm_mqse,
   config_renorm_logs,
   config_renorm_gamma5,
   config_reduction_interoperation,
   config_nlo_prefactors,
   config_SP_check,
   config_SP_verbosity,
   config_SP_chk_threshold1,
   config_SP_rescue,
   config_SP_chk_threshold2,

   reference_vectors,
   abbrev_limit,
   abbrev_level,

   r2,
   symmetries,
   crossings,
   pyxodraw
]

REDUCTION_EXTENSIONS = ["samurai", "golem95", "pjfry"]

def getExtensions(conf):
   ext_name = str(extensions)
   ext_set = []

   ext_sets = {}

   for key in conf:
      parts = key.split(".")
      if parts[-1].lower().strip() == ext_name:
         prefix = ".".join(parts[:-1])
         lst = []
         ext_sets[prefix] = lst
         for s in conf.getListProperty(key, ","):
            lst.append(s.lower())
         lst.sort()
   keys = sorted(ext_sets.keys())
   for key in keys:
      lst = ext_sets[key]
      for ext in lst:
         if ext not in ext_set:
            ext_set.append(ext)

   return list(ext_set)


def setInternals(conf):
   extensions = getExtensions(conf)
   conf["__INTERNALS__"] = [
         "__GENERATE_DERIVATIVES__",
         "__DERIVATIVES_AT_ZERO__",
         "__REGULARIZATION_DRED__",
         "__REGULARIZATION_HV__",
         "__REQUIRE_FR5__",
         "__GAUGE_CHECK__",
         "__NUMPOLVEC__",
         "__REDUCE_HELICITIES__",
         "__OLP_DAEMON__",
         "__OLP_TRAILING_UNDERSCORE__",
         "__OLP_CALL_BY_VALUE__",
         "__OLP_TO_LOWER__",
         "__GENERATE_NINJA_TRIPLE__",
         "__GENERATE_NINJA_DOUBLE__"]

   conf["__GENERATE_DERIVATIVES__"] = "derive" in extensions
   conf["__DERIVATIVES_AT_ZERO__"] = "derive" in extensions

   conf["__GENERATE_NINJA_TRIPLE__"] = "ninja" in extensions
   conf["__GENERATE_NINJA_DOUBLE__"] = "ninja" in extensions

   conf["__REGULARIZATION_DRED__"] = "dred" in extensions
   conf["__REGULARIZATION_HV__"] = not conf["__REGULARIZATION_DRED__"]

   conf["__GAUGE_CHECK__"] = "gaugecheck" in extensions
   conf["__NUMPOLVEC__"] = "numpolvec" in extensions
   conf["__REDUCE_HELICITIES__"] = "generate-all-helicities" not in extensions
   conf["__OLP_DAEMON__"] = "olp_daemon" in extensions
   conf["__OLP_TRAILING_UNDERSCORE__"] = "f77" in extensions
   conf["__OLP_CALL_BY_VALUE__"] = "f77" not in extensions
   conf["__OLP_TO_LOWER__"] = "f77" in extensions

   conf["__REQUIRE_FR5__"] = conf["__REGULARIZATION_HV__"] \
         and "no-fr5" not in extensions
