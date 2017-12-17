#!/usr/bin/env python
"""
This script uploads generated certificate files to theorymine website.

This saves lots of clicking and uploading by hand. You call it by providing
a single argument that is the certificate id (also the name of the directory
in docker_shared_dir that contains the files to be uploaded).
"""
import os
import re
import requests
import sys

from lib import cprint

SHARED_DIR = 'docker_shared_dir'

# Without the faked user agent, the web-server gives a request not allowed.
FAKE_USER_AGENT = (
  "Mozilla/5.0 " +
  "(Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 " +
  "(KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36})")


def filetype_of_filename(filename):
  if re.match("^.*\.pdf$", filename):
    return 'application/pdf'
  elif re.match("^.*\.jpg$", filename):
    return 'image/jpg'
  else:
    raise Exception("Unkown filetype for %s" % filename)


def main(argv):
  dir_name = argv[1]
  cprint.green('certificate id: %s' % dir_name)

  files = ['brouchure.pdf', 'certificate.pdf', 'certificate_image.jpg',
           'thm.jpg', 'thm.pdf', 'thy.jpg', 'thy.pdf']

  cprint.yellow("auth...")
  r = requests.post(url='http://theorymine.co.uk/?go=admin',
                    headers={"User-Agent": FAKE_USER_AGENT},
                    data={'admin_pass':'P$^vtpX'})
  cookies = r.cookies
  r.raise_for_status()

  for f in files:
    filepath = os.path.join(SHARED_DIR, dir_name, f)
    cprint.green('uploading: %s' % filepath)
    filehandle = open(filepath, 'rb')
    r = requests.post(url=('http://theorymine.co.uk/?go=admin&s=uploader&pid=%s'
                           % dir_name),
                      headers={"User-Agent": FAKE_USER_AGENT},
                      cookies=cookies,
                      files={'file': (f, filehandle,
                                      filetype_of_filename(f))})
    print(r.text)
    r.raise_for_status()
    filehandle.close()
    cprint.green("uploaded.")


if __name__ == '__main__':
  main(sys.argv)
