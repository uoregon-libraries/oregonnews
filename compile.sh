# This bash script simply kills all cached HTML and recompiles assets.  It
# should be used when static assets are added or changed.
#
# This should probably be run as root.
rm /var/tmp/django_cache/* -rf
rm ./.static-media/* -rf
source ENV/bin/activate
export DJANGO_SETTINGS_MODULE=chronam.settings
django-admin.py collectstatic --noinput
