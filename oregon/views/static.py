from django.conf import settings
from django.core import urlresolvers
from chronam.core.decorator import cache_page
from django.shortcuts import render_to_response
from django.template import RequestContext

@cache_page(settings.DEFAULT_TTL_SECONDS)
def about(request):
    page_title = "About Historic Oregon Newspapers"
    #crumbs = list(settings.BASE_CRUMBS)
    crumbs = list([
        {'label':'About',
         'href': urlresolvers.reverse('chronam_about'),
         'active': True},
    ])
    return render_to_response('about.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def about_api(request):
    page_title = "About the Site and API"
    crumbs = list(settings.BASE_CRUMBS)
    crumbs.extend([
        {'label':'About API',
         'href': urlresolvers.reverse('chronam_about_api'),
         'active': True},
    ])
    return render_to_response('about_api.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def help(request):
    page_title = "Help"
    #crumbs = list(settings.BASE_CRUMBS)
    crumbs = list([
        {'label':'Help',
         'href': urlresolvers.reverse('chronam_help'),
         'active': True},
    ])
    return render_to_response('help.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def faq(request):
    page_title = "FAQ"
    #crumbs = list(settings.BASE_CRUMBS)
    crumbs = list([
        {'label':'FAQ',
         'href': urlresolvers.reverse('chronam_faq'),
         'active': True},
    ])
    return render_to_response('faq.html', dictionary=locals(),
                              context_instance=RequestContext(request))
                              
@cache_page(settings.DEFAULT_TTL_SECONDS)
def acknow(request):
    page_title = "Acknowledgements"
    #crumbs = list(settings.BASE_CRUMBS)
    crumbs = list([
        {'label':'Acknowledgements',
         'href': urlresolvers.reverse('chronam_acknow'),
         'active': True},
    ])
    return render_to_response('acknow.html', dictionary=locals(),
                              context_instance=RequestContext(request))
                              
@cache_page(settings.DEFAULT_TTL_SECONDS)
def k12(request):
    page_title = "K-12 Resources"
    #crumbs = list(settings.BASE_CRUMBS)
    crumbs = list([
        {'label':'K-12 Resources',
         'href': urlresolvers.reverse('chronam_k12'),
         'active': True},
    ])
    return render_to_response('k12.html', dictionary=locals(),
                              context_instance=RequestContext(request))
                              
@cache_page(settings.DEFAULT_TTL_SECONDS)
def faq(request):
    page_title = "Title FAQ"
    #crumbs = list(settings.BASE_CRUMBS)
    crumbs = list([
        {'label':'Title FAQ',
         'href': urlresolvers.reverse('chronam_faq'),
         'active': True},
    ])
    return render_to_response('faq.html', dictionary=locals(),
		              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def essays_or(request):
    page_title = "Historic Essays"
    #crumbs = list(settings.BASE_CRUMBS)
    crumbs = list([
        {'label':'Historic Essays',
         'href': urlresolvers.reverse('chronam_essays_or'),
         'active': True},
    ])
    return render_to_response('history/essays_or.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def astorian(request):
    page_title = "Astorian"
    return render_to_response('history/astorian.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def bendbulletin(request):
    page_title = "Bend Bulletin"
    return render_to_response('history/bendbulletin.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def burnstimes(request):
    page_title = "Burns Times-Herald"
    return render_to_response('history/burnstimes.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def coastmail(request):
    page_title = "Coast Mail and Coos Bay Times"
    return render_to_response('history/coastmail.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregonsentinel(request):
    page_title = "Oregon Sentinel"
    return render_to_response('history/oregonsentinel.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def kfallsherald(request):
    page_title = "Klamath Falls Evening Herald"
    return render_to_response('history/kfallsherald.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def medfordmail(request):
    page_title = "Medford Mail Tribune"
    return render_to_response('history/medfordmail.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def ontarioargus(request):
    page_title = "Ontario Argus"
    return render_to_response('history/ontarioargus.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def spectator(request):
    page_title = "Oregon Spectator"
    return render_to_response('history/spectator.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def eastoregonian(request):
    page_title = "Pendleton East Oregonian"
    return render_to_response('history/eastoregonian.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def newage(request):
    page_title = "Portland New Age"
    return render_to_response('history/newage.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def newnw(request):
    page_title = "Portland New Northwest"
    return render_to_response('history/newnw.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregonian(request):
    page_title = "Portland Oregonian"
    return render_to_response('history/oregonian.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def stjohnsreview(request):
    page_title = "St. Johns Review"
    return render_to_response('history/stjohnsreview.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def capitaljournal(request):
    page_title = "Salem Capital Journal"
    return render_to_response('history/capitaljournal.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def willfarmer(request):
    page_title = "Willamette Farmer"
    return render_to_response('history/willfarmer.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def umpquagazette(request):
    page_title = "Umpqua Weeky Gazette"
    return render_to_response('history/umpquagazette.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def sumpterminer(request):
    page_title = "Sumpter Miner"
    return render_to_response('history/sumpterminer.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def bakerdemocrat(request):
    page_title = "Baker Morning Democrat"
    return render_to_response('history/bakerdemocrat.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def bandonrecorder(request):
    page_title = "Bandon Recorder"
    return render_to_response('history/bandonrecorder.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def grantcountynews(request):
    page_title = "Grant County News"
    return render_to_response('history/grantcountynews.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def bohemianugget(request):
    page_title = "Cottage Grove Bohemia Nugget"
    return render_to_response('history/bohemianugget.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def lagrandeobserver(request):
    page_title = "La Grande Observer"
    return render_to_response('history/lagrandeobserver.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def lakecountyexaminer(request):
    page_title = "Lake County Examiner"
    return render_to_response('history/lakecountyexaminer.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def madraspioneer(request):
    page_title = "Madras Pioneer"
    return render_to_response('history/madraspioneer.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregonfreepress(request):
    page_title = "Oregon Free Press"
    return render_to_response('history/oregonfreepress.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def plaindealer(request):
    page_title = "Roseburg Plaindealer"
    return render_to_response('history/plaindealer.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def springfieldnews(request):
    page_title = "Springfield News"
    return render_to_response('history/springfieldnews.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def dalleschronicle(request):
    page_title = "The Dalles Daily Chronicle"
    return render_to_response('history/dalleschronicle.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def tillamookherald(request):
    page_title = "Tillamook Herald"
    return render_to_response('history/tillamookherald.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregonscout(request):
    page_title = "Union Oregon Scout"
    return render_to_response('history/oregonscout.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def malheurenterprise(request):
    page_title = "Malheur Enterprise"
    return render_to_response('history/malheurenterprise.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def eaglevalleynews(request):
    page_title = "Richland Eagle Valley News"
    return render_to_response('history/eaglevalleynews.html', dictionary=locals(),
                              context_instance=RequestContext(request))
                              
@cache_page(settings.DEFAULT_TTL_SECONDS)
def ashlandtidings(request):
    page_title = "Ashland Tidings"
    return render_to_response('history/ashlandtidings.html', dictionary=locals(),
                              context_instance=RequestContext(request))                              

@cache_page(settings.DEFAULT_TTL_SECONDS)
def enterprisenewsrecord(request):
    page_title = "News Record"
    return render_to_response('history/enterprisenewsrecord.html', dictionary=locals(),
                              context_instance=RequestContext(request))
                              
@cache_page(settings.DEFAULT_TTL_SECONDS)
def roguerivercourier(request):
    page_title = "Rogue River Courier"
    return render_to_response('history/roguerivercourier.html', dictionary=locals(),
                              context_instance=RequestContext(request))    
                              
@cache_page(settings.DEFAULT_TTL_SECONDS)
def wallowachieftain(request):
    page_title = "Wallowa Chieftain"
    return render_to_response('history/wallowachieftain.html', dictionary=locals(),
                              context_instance=RequestContext(request))  
                              
@cache_page(settings.DEFAULT_TTL_SECONDS)
def mist(request):
    page_title = "St. Helens Mist"
    return render_to_response('history/mist.html', dictionary=locals(),
                              context_instance=RequestContext(request))    
                            
@cache_page(settings.DEFAULT_TTL_SECONDS)
def timesmountaineer(request):
    page_title = "The Dalles Times-Mountaineer"
    return render_to_response('history/timesmountaineer.html', dictionary=locals(),
                              context_instance=RequestContext(request)) 
                              
@cache_page(settings.DEFAULT_TTL_SECONDS)
def lincolncountyleader(request):
    page_title = "Lincoln County Leader"
    return render_to_response('history/lincolncountyleader.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def eugenebroadaxebroadaxetribune(request):
    page_title = "Broad-Axe Tribune and Broad-Axe"
    return render_to_response('history/eugenebroadaxebroadaxetribune.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def eugenestaterepublican(request):
    page_title = "State Republican"
    return render_to_response('history/eugenestaterepublican.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregoncitycourier(request):
    page_title = "Oregon City Courier"
    return render_to_response('history/oregoncitycourier.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregoncityoregonargus(request):
    page_title = "Oregon Argus"
    return render_to_response('history/oregoncityoregonargus.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def portlandwestshoreillustratedwestshore(request):
    page_title = "West Shore and Illustrated West Shore"
    return render_to_response('history/portlandwestshoreillustratedwestshore.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def sthelenscolumbian(request):
    page_title = "Columbian"
    return render_to_response('history/sthelenscolumbian.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def houltoncolumbiaregister(request):
    page_title = "Columbia Register"
    return render_to_response('history/houltoncolumbiaregister.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregoncitypress(request):
    page_title = "Oregon City Press"
    return render_to_response('history/oregoncitypress.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS) 
def oregoncityenterprise(request):
    page_title = "Oregon City Enterprise"
    return render_to_response('history/oregoncityenterprise.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregoncityclackamascountyrecord(request):
    page_title = "Clackamas County Record"
    return render_to_response('history/oregoncityclackamascountyrecord.html', dictionary=locals(),
                              context_instance=RequestContext(request))                                                                                                                                                                
@cache_page(settings.DEFAULT_TTL_SECONDS)
def lagrandeeveningobserver(request):
    page_title = "Evening Oberserver"
    return render_to_response('history/lagrandeeveningobserver.html', dictionary=locals(),
                              context_instance=RequestContext(request))

@cache_page(settings.DEFAULT_TTL_SECONDS)
def heppnerherald(request):
    page_title = "Heppner Herald"
    return render_to_response('history/heppnerherald.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def chemawaamerican(request):
    page_title = "Chemawa American"
    return render_to_response('history/chemawaamerican.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def smokesignals(request):
    page_title = "Smoke Signals"
    return render_to_response('history/smokesignals.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def auroraborealis(request):
    page_title = "Aurora Borealis"
    return render_to_response('history/auroraborealis.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def athenapress(request):
    page_title = "Athena Press"
    return render_to_response('history/athenapress.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def beavertonowltimes(request):
    page_title = "Owl/Beaverton Times"
    return render_to_response('history/beavertonowltimes.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def bentondemocrat(request):
    page_title = "Benton Democrat"
    return render_to_response('history/bentondemocrat.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def corvallisdailygazettetimes(request):
    page_title = "Daily Gazette-Times"
    return render_to_response('history/corvallisdailygazettetimes.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def corvallisgazette(request):
    page_title = "Corvallis Gazette"
    return render_to_response('history/corvallisgazette.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def corvallistimes(request):
    page_title = "Corvallis Times/The Gazette-Times"
    return render_to_response('history/corvallistimes.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def crookcountyjournal(request):
    page_title = "Crook County Journal"
    return render_to_response('history/crookcountyjournal.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def douglasindependent(request):
    page_title = "Douglas Independent"
    return render_to_response('history/douglasindependent.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def echoregister(request):
    page_title = "Echo Register"
    return render_to_response('history/echoregister.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def heppnergazette(request):
    page_title = "Weekly Gazette/Heppner Gazette/Gazette-Times"
    return render_to_response('history/heppnergazette.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def hillsboroargus(request):
    page_title = "Argus/The Hillsboro Argus"
    return render_to_response('history/hillsboroargus.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def hoodriverglacier(request):
    page_title = "Hood River Glacier"
    return render_to_response('history/hoodriverglacier.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def hoodriversun(request):
    page_title = "Hood River Sun"
    return render_to_response('history/hoodriversun.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def junctioncitybulletin(request):
    page_title = "Junction City Bulletin"
    return render_to_response('history/junctioncitybulletin.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregonrepublican(request):
    page_title = "Oregon Republican/Liberal Republican"
    return render_to_response('history/oregonrepublican.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def oregonunion(request):
    page_title = "Oregon Union"
    return render_to_response('history/oregonunion.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def polkcountyobserver(request):
    page_title = "Polk County Observer"
    return render_to_response('history/polkcountyobserver.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def roseburgreview(request):
    page_title = "Roseburg Review"
    return render_to_response('history/roseburgreview.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def spraycourier(request):
    page_title = "Spray Courier"
    return render_to_response('history/spraycourier.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def staterightsdemocrat(request):
    page_title = "State Rights Democrat"
    return render_to_response('history/staterightsdemocrat.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def toveritar(request):
    page_title = "Toveritar"
    return render_to_response('history/toveritar.html', dictionary=locals(),
                              context_instance=RequestContext(request))
@cache_page(settings.DEFAULT_TTL_SECONDS)
def uniongazette(request):
    page_title = "Oregon Union/The Union Gazette/Corvallis Gazette"
    return render_to_response('history/uniongazette.html', dictionary=locals(),
                              context_instance=RequestContext(request))

                       
