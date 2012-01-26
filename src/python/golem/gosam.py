#!/usr/bin/python
# vim: ts=3:sw=3:expandtab

import sys
import golem.app.main as main
import golem.app.olp as olp
import traceback

def report_crash(exc, stack, fname="gosam.crashed"):
   import os
   import platform
   import xml.parsers.expat as expat

   from math import log
   from golem.util.tools import POSTMORTEM_LOG, POSTMORTEM_CFG

   def emit(*args, **opts):
      topic = " ".join(args)
      f.write("---#[ %s:\n" % topic)
      msg = "\n".join(map(str, args))
      if len(opts) > 0:
         ml = max(map(len, opts.keys()))
         fmt = "\n * %%%ds: %%s" % ml
         for key in sorted(opts.keys()):
            msg += fmt % (key, opts[key])
      f.write(msg)
      f.write("\n")
      f.write("---#] %s:\n" % topic)

   f = open(fname, 'w')
   f.write("---#[ COMMAND LINE ARGUMENTS:\n")
   f.write(" ".join(map(repr, sys.argv[1:])) + "\n")
   f.write("---#] COMMAND LINE ARGUMENTS:\n")
   f.write("---#[ MESSAGES:\n")
   for msg in POSTMORTEM_LOG:
      f.write(msg + "\n")
   f.write("---#] MESSAGES:\n")
   f.write("---#[ LAST WORDS:\n")
   f.write(str(exc) + "\n")
   f.write("---#] LAST WORDS:\n")
   f.write("---#[ STACK:\n")
   for idx, line in enumerate(traceback.format_tb(sys.exc_traceback)):
      f.write("[%3d] %s" % (idx, line))
   f.write("---#] STACK:\n")
   if POSTMORTEM_CFG is not None:
      f.write("---#[ CONFIG:\n")
      POSTMORTEM_CFG.list(f)
      f.write("---#] CONFIG:\n")

   emit("Platform",
         platform_short=sys.platform,
         platform_long=platform.platform(),
         machine=platform.machine(),
         processor=platform.processor(),
         version=platform.version(),

         maxunicode=sys.maxunicode,
         maxint=int(log(sys.maxint)/log(2))+1,
         maxsize=int(log(sys.maxsize)/log(2))+1
      )


   if sys.platform.startswith('linux'):
      emit("Linux",
            libc=" ".join(platform.libc_ver()),
            distribution="%s %s (%s)"
               % platform.linux_distribution()
      )
   elif sys.platform.startswith('win'):
      emit("Windows",
            version=platform.win32_ver()
         )
   elif sys.platform.startswith('darwin'):
      emit("Mac OS",
            version=platform.mac_ver()
         )
   elif sys.platform.startswith('java'):
      emit("Java",
            version=platform.java_ver()
         )

   emit("Python",
         version=platform.python_version(),
         revision=platform.python_revision(),
         hexversion="0x%08x" % sys.hexversion,
         build_date=platform.python_build()[1],
         compiler=platform.python_compiler(),
         branch=platform.python_branch(),
         implementation=platform.python_implementation()
      )

   xmlp = expat.ParserCreate()

   emit("XML Parser (Expat)",
         version = ".".join(map(str,expat.version_info)),
         encoding = expat.native_encoding,
         returns_unicode = xmlp.returns_unicode
      )

   f.close()

   print("A detailed crash report has been written to '%s'." % fname)
   print("Please, attach this file when you contact the authors.")

if __name__ == "__main__":
   argv = sys.argv[:]

   try:
      if "--olp" in argv[1:]:
         argv.remove("--olp")
         olp.main(argv)
      else:
         main.main(argv)
   except SystemExit as ex:
      report_crash(ex, sys.exc_traceback)
   except BaseException as ex:
      print("===> Unexpected error: %s" % ex)
      print(traceback.format_tb(sys.exc_traceback)[-1])
      report_crash(ex, sys.exc_traceback)
