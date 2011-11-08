# vim: ts=3:sw=3:expandtab
import golem.templates.kinematics
import golem.templates.parameters
import golem.templates.analyzer
import golem.templates.integrals
import golem.templates.multi
import golem.templates.olp
import golem.util.parser

from golem.util.tools import debug, warning, error, message, \
      copy_file

class TemplateFactory:
   def __init__(self):
      pass

   def process(self, in_file, out_file, class_name, props, conf, opts):
      debug("Transforming file %r by template class %sTemplate" % 
            (in_file, class_name))

      assert class_name is not None

      if class_name == "Verbatim":
         if out_file is None:
            try:
               f_in = open(in_file, 'r')
               result = "".join(f_in.readlines())
               f_in.close()
            except IOError as err:
               raise golem.util.parser.TemplateError(err)
            return result
         else:
            copy_file(in_file, out_file)
      else:
         try:
            f_template = open(in_file, "r")
            if class_name == "Model":
               if "conf" not in opts:
                  raise golem.util.parser.TemplateError(
                        "Cannot use template 'Model' here.")
               conf = opts["conf"]
               template = golem.templates.parameters.ModelTemplate(f_template)
               template.init_model(conf)
               if "in_particles" in opts and \
                     "out_particles" in opts:
                  in_particles = opts["in_particles"]
                  out_particles = opts["out_particles"]
                  template.add_kinematics_parameters(
                        in_particles, out_particles)
            elif class_name == "Integrals":
               if "loopcache" not in opts \
                     or "in_particles" not in opts \
                     or "out_particles" not in opts \
                     or "conf" not in opts \
                     or "tree_signs" not in opts \
                     or "lo_flags" not in opts \
                     or "nlo_flags" not in opts \
                     or "heavy_quarks" not in opts:
                  raise golem.util.parser.TemplateError(
                        "Cannot use template 'Integrals' here.")
               loopcache = opts["loopcache"]
               in_particles = opts["in_particles"]
               out_particles = opts["out_particles"]
               tree_signs = opts["tree_signs"]
               # tree_flows = opts["tree_flows"]
               conf = opts["conf"]
               heavy_quarks = opts["heavy_quarks"]
               lo_flags = opts["lo_flags"]
               nlo_flags = opts["nlo_flags"]

               template = golem.templates.integrals.IntegralsTemplate(
                     f_template)
               template.setup(loopcache, in_particles, out_particles,
                     tree_signs, conf, heavy_quarks, lo_flags, nlo_flags)
            elif class_name == "Kinematics":
               if "in_particles" not in opts or \
                     "out_particles" not in opts or \
                     "conf" not in opts or \
                     "tree_signs" not in opts or \
                     "heavy_quarks" not in opts:
                  raise golem.util.parser.TemplateError(
                        "Cannot use template 'Kinematics' here.")
               in_particles = opts["in_particles"]
               out_particles = opts["out_particles"]
               conf = opts["conf"]
               tree_signs = opts["tree_signs"]
               # tree_flows = opts["tree_flows"]
               heavy_quarks = opts["heavy_quarks"]

               template = golem.templates.kinematics.KinematicsTemplate(
                     f_template)
               template.init_kinematics(conf, in_particles, out_particles,
                     tree_signs, heavy_quarks)
            elif class_name == "OLP":
               if "contract" not in opts or \
                     "subprocesses" not in opts or \
                     "conf" not in opts:
                  raise golem.util.parser.TemplateError(
                        "Cannot use template 'OLP' here.")
               template = golem.templates.olp.OLPTemplate(f_template)
               template.init_contract(opts["contract"])
               template.init_channels(opts["subprocesses"])
            elif class_name == "Multi":
               if "conf" not in opts:
                  raise golem.util.parser.TemplateError(
                        "Cannot use template 'Multi' here.")
               conf = opts["conf"]
               template = golem.templates.multi.MultiTemplate(f_template)
               template.setup(conf, opts)
            elif class_name == "LightCone":
               if "refs" not in opts or \
                     "onshell" not in opts:
                  raise golem.util.parser.TemplateError(
                        "Cannot use template 'LightCone' here.")
               refs = opts["refs"]
               onshell = opts["onshell"]
               template = golem.templates.analyzer.LightConeTemplate(f_template)
               template.setup(refs, onshell)
            else:
               raise golem.util.parser.TemplateError(
                     "Unknown template class '%s'." % (class_name))

            f_template.close()
            if out_file is None:
               result = "".join(s for s in template(*props))
               return result
            else:
               f_out = open(out_file, 'w')
               for chunk in template(*props):
                  f_out.write(chunk)
               f_out.close()

         except golem.util.parser.TemplateError as ex:
            error("While processing '%s': %s" % (in_file, ex))



