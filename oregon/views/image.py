import logging
import os.path
import simplejson as json
import urlparse
from urllib import url2pathname
import urllib2
from cStringIO import StringIO

from django.conf import settings
from django.http import Http404, HttpResponse, HttpResponseNotFound, HttpResponseServerError
from django.core import urlresolvers

from chronam.core import models
from chronam.core.utils.utils import get_page
from chronam.core.decorator import cors


LOGGER = logging.getLogger(__name__)

if settings.USE_TIFF:
    LOGGER.info("Configured to use TIFFs. Set USE_TIFF=False if you want to use the JPEG2000s.")
    from PIL import Image
else:
    import NativeImaging
    for backend in ('aware_cext', 'aware', 'graphicsmagick'):
        try:
            Image = NativeImaging.get_image_class(backend)
            break
        except ImportError, e:
            LOGGER.info("NativeImage backend '%s' not available.")
    else:
        raise Exception("No suitable NativeImage backend found.")
    LOGGER.info("Using NativeImage backend '%s'" % backend)

def image_tile(request, path, width, height, x1, y1, x2, y2):
    if 'download' in request.GET and request.GET['download']:
        response = HttpResponse(mimetype="binary/octet-stream")
    else:
        response = HttpResponse(mimetype="image/jpeg")

    width, height = int(width), int(height)
    x1, y1, x2, y2 = int(x1), int(y1), int(x2), int(y2)
    try:
        p = os.path.join(settings.BATCH_STORAGE, path)
        im = Image.open(p)
    except IOError, e:
        return HttpResponseServerError("Unable to create image tile: %s" % e)
    c = im.crop((x1, y1, x2, y2))
    f = c.resize((width, height))
    f.save(response, "JPEG")
    return response

def resize(request, path, width, height):
    response = HttpResponse(mimetype="image/jpeg")

    width = int(width)
    height = int(height)

    try:
        p = os.path.join(settings.BATCH_STORAGE, path)
        im = Image.open(p)
    except IOError, e:
        return HttpResponseServerError("Unable to read image for resizing: %s" % e)

    actual_width, actual_height = im.size

    # Accommodate "fit to width" requests as these are how thumbnails work
    if height == 0:
        height = int(round(width / float(actual_width) * float(actual_height)))

    f = im.resize((width, height))
    f.save(response, "JPEG")
    return response

@cors
def coordinates(request, lccn, date, edition, sequence, words=None):
    url_parts = dict(lccn=lccn, date=date, edition=edition, sequence=sequence)
    try:
        f = open(models.coordinates_path(url_parts))
    except IOError:
        return HttpResponse()
    data = f.read()

    r = HttpResponse(mimetype='application/json')
    r['Content-Encoding'] = 'gzip'
    r['Content-Length'] = len(data)
    r.write(data)
    f.close()
    return r
