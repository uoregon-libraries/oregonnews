from django.conf.urls import patterns, url

from oregon.views import simpleocr

urlpatterns = patterns('', url(r'^oregon/simpleocr/$', 'simpleocr', name="chronam_simpleocr")
)
