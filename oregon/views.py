# Create your views here.

from django.conf import settings
from django.core import urlresolvers
from chronam.core.decorator import cache_page
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.http import HttpResponse

#def simpleocr(request):
    #page_title = "OCR"
 #   return HttpResponse("hello world")    
#return render_to_response('simpleocr.html', dictionary=locals(), context_instance=RequestContext(request))
