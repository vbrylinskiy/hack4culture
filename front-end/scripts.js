
    var map;
    var markers = [];
    var finalMarkers = [];

    var directionsService;
    var directionsDisplay;
    var stepDisplay;
    var markerListener;
    var events = [];
    var oms;

    $('#saveForm').submit(function(e){
      
      e.preventDefault();
      //save to localStorage
      var storedRoutes = []
      if (localStorage.routes) storedRoutes = JSON.parse(localStorage.getItem("routes"));
      storedRoutes.push({
          name: $('form #nazwa').val(),
          points: finalMarkers
      })
      localStorage.setItem("routes", JSON.stringify(storedRoutes));

      $('#saveRouteModal').modal('hide');
      $('#saveRoute').fadeOut();
    });

    $('#loadForm').submit(function(e){
      e.preventDefault();
      $('#loadRouteModal').modal('hide');
      

      parseOptionCords($('#loadForm select').find(':selected').val());
      
      calculateAndDisplayRoute(directionsDisplay, directionsService, markers, stepDisplay, map);
    })

    function parseOptionCords(cords) {
      var splitted = cords.split(",");
      for (var i = 0; i < splitted.length; i = i +2) {
         placeRoutePoint({          
          lat: +splitted[i],
          lng: +splitted[i+1]
        })
     
      }
      
 
    }

      function initMap() {
        map = new google.maps.Map(document.getElementById('map'), {
          zoom: 14   ,
          center: {lat: 51.1077076 , lng: 17.0776118 }
        });

        oms = new OverlappingMarkerSpiderfier(map, {
          keepSpiderfied: true,
          markersWontMove: true

        });

        directionsService = new google.maps.DirectionsService;
        directionsDisplay = new google.maps.DirectionsRenderer({map: map});
        stepDisplay = new google.maps.InfoWindow;
        showBikes();
        if (localStorage.routes) {
          //show button to load saved routes
          populateRoutes();
          $('#loadRoute').fadeIn();
        } 

        markerListener = map.addListener('click', function(e) {
          placeRoutePoint(e.latLng);
        });
        

      }

      function populateRoutes() {
        var storedRoutes = JSON.parse(localStorage.getItem("routes"));
        var optionsHTML = "";
        storedRoutes.forEach(function(route){
          optionsHTML += "<option value='"+route.points+"'>"+route.name+"</option>";
        })
        $('#loadForm select').html(optionsHTML);
      }

      $('#endRoute').on("click",function(){
        
         if (markers.length > 1) {
            calculateAndDisplayRoute(directionsDisplay, directionsService, markers, stepDisplay, map);

            $('#spinner-modal').fadeIn();
          }
      })

      function placeRoutePoint(latLng) {
        
        var marker = new google.maps.Marker({
          position: latLng,
          map: map
        });
        marker.addListener("click", showRemoveMarkerDialog)
        markers.push(marker);

        map.panTo(latLng); 
        if (markers.length === 1) $('.alert-danger').html('Dodaj przynajmniej jeszcze jeden!');
        if (markers.length > 1) {
            $('#endRoute').fadeIn();    
            $('.alert-danger').hide();
          }

      }

      function placeBikeMarker(latLng, title) {
        var marker = new google.maps.Marker({
           position: latLng,
           map: map,
           icon: {
            "strokeOpacity": 0.5,
            path: "M29.998 28.197c-4.212 0-7.627-3.414-7.627-7.627 0-3.090 1.842-5.745 4.484-6.943l-1.014-2.283 0.165 0.399-6.944 9.321v1.869h1.017v1.018h-3.052v-1.018h1.018v-1.018l-2.877-0.27c-0.524 3.701-3.696 6.551-7.542 6.551-4.212 0.001-7.626-3.413-7.626-7.626 0-4.212 3.414-7.626 7.627-7.626 1.101 0 2.145 0.238 3.090 0.657l1.906-4.788-0.865-2.416c-0.38 0-0.734 0-1.017 0-0.954 0-0.699-1.017-0.699-1.017s0.063-0.89 0.763-0.89 0.699 0.636 1.843 0.636c1.095 0 2.669 0.317 2.669 0.317s0.699 0.953-0.635 0.953c-0.604 0-1.269 0-1.907 0l0.723 2.597h11.052l-0.868-1.973h-0.675v-1.016h4.067v1.017h-2.298l2.977 6.26c0.71-0.219 1.465-0.337 2.246-0.337 4.212 0 7.627 3.414 7.627 7.626-0.001 4.213-3.416 7.627-7.628 7.627zM7.627 13.96c-3.651 0-6.61 2.959-6.61 6.61s2.959 6.609 6.61 6.609c3.319 0 6.060-2.449 6.53-5.639l-5.294-0.545c-0.084 0.477-0.481 0.846-0.982 0.846-0.562 0-1.017-0.455-1.017-1.018 0-0.561 0.455-1.018 1.017-1.018 0.12 0 0.232 0.031 0.339 0.070l2.121-5.33c-0.829-0.372-1.746-0.585-2.714-0.585zM9.152 20.125l5.079 0.537c0.001-0.031 0.005-0.061 0.005-0.092 0-2.35-1.229-4.408-3.077-5.581l-2.007 5.136zM13.077 10.082l-1.543 3.948c2.225 1.332 3.719 3.759 3.719 6.541 0 0.066-0.008 0.133-0.010 0.199l1.726 0.182-3.892-10.87zM24.978 9.396v0.614h-11.12l4.050 10.839 7.687-10.065-0.617-1.388zM29.998 13.96c-0.637 0-1.251 0.095-1.834 0.264l2.374 5.424c0.482 0.078 0.858 0.48 0.858 0.984 0 0.562-0.455 1.018-1.017 1.018s-1.018-0.455-1.018-1.018c0-0.273 0.111-0.521 0.289-0.705l-2.384-5.372c-2.287 1.040-3.879 3.338-3.879 6.014 0 3.65 2.959 6.609 6.609 6.609s6.609-2.959 6.609-6.609-2.957-6.609-6.607-6.609z"
          },
          title: title
        })


      }

      function placeEventMarker(latLng, label, desc, imageSrc, start, end, url) {        

        var image = {
            url: 'http://uxrepo.com/static/icon-sets/elegant/svg/icon_pin.svg',
            // This marker is 20 pixels wide by 32 pixels high.
            size: new google.maps.Size(20, 32),
            // The origin for this image is (0, 0).
            origin: new google.maps.Point(0, 0),
            // The anchor for this image is the base of the flagpole at (0, 32).
            anchor: new google.maps.Point(0, 32)
          };
        
        var marker = new google.maps.Marker({
          position: latLng,
          map: map,
          title: label,
          icon: {
            path: "M50,16.072c-15.539,0-28.135,12.597-28.135,28.135C21.865,65.952,50,83.928,50,83.928S78.135,65.4,78.135,44.207  C78.135,28.669,65.539,16.072,50,16.072z M50,64.155c-11.042,0-19.994-8.952-19.994-19.994c0-11.043,8.952-19.994,19.994-19.994  c11.043,0,19.994,8.952,19.994,19.994C69.994,55.203,61.042,64.155,50,64.155z",
            scale:8,
            fillColor: 'blue',
            fillOpacity: 0.7,
            strokeColor: 'blue',
            scale: 0.5,
            strokeWeight: 0.5
          } ,
          animation: google.maps.Animation.DROP
        });

        oms.addMarker(marker);

        marker.info = new google.maps.InfoWindow({
          content: "<h1>"+label+"</h1><a href='"+url+"' target='_blank'>Więcej</a><p><em>Poczatek: "+start+"</em><br/><em>Koniec: "+end+"</em></p><img src='"+imageSrc+"'/>"+desc
        });

        marker.addListener("click", function(){
          marker.info.open(map,marker);
        });
      }

      function showRemoveMarkerDialog() {
        if (confirm("Do you want to remove this point?")) {
          removeMarker(this);
        }
      } 

      function removeMarker(toRemove) {
        toRemove.setMap(null);
        var toRemoveId = markers.indexOf(toRemove);
        if (toRemoveId > -1) markers.splice(toRemoveId,1);
      }

      function removeAllMarkers() {
        
        markers.forEach(function(marker){
          marker.setMap(null);
        })
        markers = [];
      }

      function parseCords(marker) {
        return marker.lat()+','+marker.lng();
      }

      function calculateAndDisplayRoute(directionsDisplay, directionsService,
          markers, stepDisplay, map) {

        //add waypoints
        var waypoints = [];
        if (markers.length > 2) {
          for (i = 1; i < markers.length -1; i ++) {
            waypoints.push({
              location: parseCords(markers[i].position),
              stopover: true
            })
          }
        }

        // Retrieve the start and end locations and create a DirectionsRequest using
        // WALKING directions.
        directionsService.route({
          origin: parseCords(markers[0].position),
          destination: parseCords(markers[markers.length - 1].position),
          waypoints: waypoints,
          travelMode: google.maps.TravelMode.WALKING
        }, function(response, status) {
          // Route the directions and pass the response to a function to create
          // markers for each step.
          if (status === google.maps.DirectionsStatus.OK) {
  
            directionsDisplay.setDirections(response);

            
            //hide the button 
            $('#endRoute').fadeOut();

            //remove the markers, because we'll get new ones from direction
            removeAllMarkers();

            

            getNewMarkers(response.geocoded_waypoints);           
            
            //not allowing to add markers after route is planned
            google.maps.event.removeListener(markerListener);
   
          } else {
            window.alert('Directions request failed due to ' + status);
          }
        });
      }



      function getNewMarkers(waypoints) {
            var dfds = [];
            waypoints.forEach(function(waypoint){ 
                dfds.push(placeId2Cords(waypoint.place_id));
            })
            $.when.apply($, dfds).done(function(){
              var args = Array.prototype.slice.call(arguments);
              args.forEach(function(location){
                finalMarkers.push(parseCords(location))
              })
                
            fetchEvents();
            
            })
      }



      function placeId2Cords(placeId) {
      var dfd = $.Deferred();        
      var geocoder = new google.maps.Geocoder;
        geocoder.geocode({'placeId': placeId}, function(results, status) {
           if (status === google.maps.GeocoderStatus.OK) {
             if (results[0]) {
                dfd.resolve(results[0].geometry.location)                
             } else {
               dfd.reject('No results found');
             }
           } else {
             dfd.reject('Geocoder failed due to: ' + status);
           }

         });
         return dfd.promise();
      }

      function fetchEvents(){

        
        finalMarkers.forEach(function(finalMarker){
          getNearbyLocations(finalMarker).done(function(results){
            console.log('got nearby locations');
              results.items.forEach(function(location){
                getEventsForLocation(location.id).done(function(results){
                  
                  if (results.items.length) {

                        results.items.forEach(function(event) {
                          if (isCulture(event.offer.type.id)) {
                            events.push({
                              "title": event.offer.title,
                              "desc": event.offer.longDescription,
                              "start": event.startDate,
                              "end": event.endDate,
                              "url": event.offer.pageLink,
                              "thumb": event.offer.mainImage.thumbnail
                            });
                             

                              placeEventMarker({
                               "lat": event.location.lattiude,
                               "lng": event.location.longitude
                              }, event.offer.title, event.offer.longDescription, event.offer.mainImage.thumbnail, event.startDate.split("T").join(", "), event.endDate.split("T").join(", "), event.offer.pageLink);

                              $('#saveRoute').fadeIn();
                             
                        }
                    });
                  }
                  setTimeout(function(){
                    $('#spinner-modal').fadeOut();
                  },1000)
                  
                  
                });
              })
          });
        })
      
      }

      function isCulture(eventTypeId) {
        var nonCultureEvents = {13:true, 17: true, 18: true, 20: true, 21: true, 22: true, 77: true};
        return !nonCultureEvents[eventTypeId];
      }

      function getEventsForLocation(locationId) {
        var timeFrom = +(new Date());
        var timeTo = +(new Date(new Date().getTime() + 1 * 24 * 60 * 60 * 1000));
        
        var url = "http://go.wroclaw.pl/api/v1.0/events?place-id="+locationId+"&key=928012495102009594014322187345717861707&time-from="+timeFrom+"&time-to="+timeTo;
        
        return $.get(url);
      }

      function getNearbyLocations(location) {
        console.log('geting nearby locations');
        var url = "http://go.wroclaw.pl/api/v1.0/places/nearLocation/"+location+"?key=928012495102009594014322187345717861707";
        return $.get(url);
      }

      function showBikes() {

        var bikeStands =  [{

            "lat": "51.13207714749649",
            "lng": "17.06550121307373",
            "name": "Pl. Kromera",

        }, {

            "lat": "51.12454271204484",
            "lng": "17.034999132156372",
            "name": "Dworzec Nadodrze",

        }, {

            "lat": "51.10723376985792",
            "lng": "17.061327695846558",
            "name": "Politechnika Wrocławska - Gmach Główny ",

        }, {

            "lat": "51.094790225798505",
            "lng": "16.980035305023193",
            "name": "FAT - Grabiszyńska - Hallera",


        }, {

            "lat": "51.099264089082496",
            "lng": "17.000784873962402",
            "name": "Grabiszyńska - Stalowa",

        }, {

            "lat": "51.09544381415203",
            "lng": "17.007962465286255",
            "name": "Grochowa - Jemiołowa",

        }, {

            "lat": "51.091191955420186",
            "lng": "16.98563575744629",
            "name": "Hallera - Odkrywców",

        }, {

            "lat": "51.089264676748826",
            "lng": "17.00162172317505",
            "name": "Centrum Handlowe Borek",

        }, {

            "lat": "51.09342911524615",
            "lng": "17.002780437469482",
            "name": "Krucza - Mielecka",

        }, {

            "lat": "51.10097536207561",
            "lng": "17.0082950592041",
            "name": "Pereca - Grabiszyńska",

        }, {

            "lat": "51.09722260577026",
            "lng": "17.01408863067627",
            "name": "Zaporoska - Gajowicka",

        }, {

            "lat": "51.10185118595181",
            "lng": "17.0137882232666",
            "name": "Zaporoska - Grabiszyńska",

        }, {

            "lat": "51.09425117690591",
            "lng": "17.01447486877441",
            "name": "Zaporoska - Wielka",

        }, {

            "lat": "51.09804123119159",
            "lng": "17.00680375099182",
            "name": "Żelazna - Pereca",

        }, {

            "lat": "51.12527668338291",
            "lng": "16.98439121246338",
            "name": "Legnicka - Wejherowska",
        }, {

            "lat": "51.108048849946385",
            "lng": "17.06479847431183",
            "name": "Smoluchowskiego - Łukaszewicza",

        }, {

            "lat": "51.11094529924635",
            "lng": "17.052347660064697",
            "name": "Uniwersytet Wrocławski - Joliot Curie",

        }, {

            "lat": "51.11920928565168",
            "lng": "17.05654263496399",
            "name": "Nowowiejska - Prusa",

        }, {

            "lat": "51.110362656007275",
            "lng": "17.055496573448178",
            "name": "Plac Grunwaldzki - Polaka",
        }, {

            "lat": "51.11568363359365",
            "lng": "17.060614228248596",
            "name": "Sienkiewicza - Piastowska",

        }, {

            "lat": "51.116838676267925",
            "lng": "17.05156981945038",
            "name": "Sienkiewicza - Wyszyńskiego",

        }, {

            "lat": "51.11400321382931",
            "lng": "17.103824615478516",
            "name": "Mickiewicza - pętla tramwajowa",

        }, {

            "lat": "51.119431524045254",
            "lng": "17.05151081085205",
            "name": "Wyszyńskiego - Prusa",

        }, {

            "lat": "51.08992845137241",
            "lng": "17.023476362228394",
            "name": "Komandorska - Kamienna",


        }, {

            "lat": "51.08658926519162",
            "lng": "17.01230764389038",
            "name": "Powstańców Śląskich - Hallera",

        }, {

            "lat": "51.089756612155334",
            "lng": "17.028229236602783",
            "name": "Ślężna - Kamienna",

        }, {

            "lat": "51.09891037318256",
            "lng": "17.051634192466732",
            "name": "Kościuszki - Komuny Paryskiej / Zgodna",
        }, {

            "lat": "51.09699352280998",
            "lng": "17.0562744140625",
            "name": "Traugutta - Kościuszki",


        }, {

            "lat": "51.10443813804785",
            "lng": "17.048335075378418",
            "name": "Traugutta - Pułaskiego",

        }, {

            "lat": "51.09695646516561",
            "lng": "17.03801929950714",
            "name": "Dworzec kolejowy - południe",

        }, {

            "lat": "51.10022753009522",
            "lng": "17.04504132270813",
            "name": "Kościuszki - Pułaskiego",

        }, {

            "lat": "51.11698010808053",
            "lng": "17.033389806747437",
            "name": "Drobnera - Dubois",

        }, {

            "lat": "51.122387866424724",
            "lng": "17.047605514526364",
            "name": "Żeromskiego - Kluczborska",

        }, {

            "lat": "51.11743807478881",
            "lng": "17.041382789611816",
            "name": "Plac Bema",

        }, {

            "lat": "51.1222834885376",
            "lng": "17.05226182937622",
            "name": "Nowowiejska - Wyszyńskiego",

        }, {

            "lat": "51.12288618340934",
            "lng": "17.03056812286377",
            "name": "Plac Staszica",

        }, {

            "lat": "51.113844934670325",
            "lng": "17.034462690353394",
            "name": "Plac Uniwersytecki",

        }, {

            "lat": "51.12462351680015",
            "lng": "17.045599222183228",
            "name": "Jedności Narodowej - Nowowiejska ",

        }, {

            "lat": "51.1102515151332",
            "lng": "17.03505277633667",
            "name": "Wita Stwosza - Szewska ",

        }, {

            "lat": "51.121256532234305",
            "lng": "17.043163776397705",
            "name": "Jedności Narodowej - Oleśnicka",

        }, {

            "lat": "51.12811145398997",
            "lng": "17.05474019050598",
            "name": "Jedności Narodowej - Wyszyńskiego",

        }, {

            "lat": "51.129948",
            "lng": "16.9659",
            "name": "Bajana - Szybowcowa",

        }, {

            "lat": "51.12557296208677",
            "lng": "17.050459384918213",
            "name": "Żeromskiego - Daszyńskiego",

        }, {

            "lat": "51.1039396220822",
            "lng": "17.084147930145264",
            "name": "Teki",

        }, {

            "lat": "51.11413791906944",
            "lng": "17.0137345790863",
            "name": "Inowrocławska - Urząd Skarbowy",

        }, {

            "lat": "51.09965485778756",
            "lng": "17.035846710205078",
            "name": "Dworzec kolejowy - północ",

        }, {

            "lat": "51.111477",
            "lng": "17.037904",
            "name": "Plac Nowy Targ ",

        }, {

            "lat": "51.08346213967434",
            "lng": "17.0352566242218",
            "name": "Armii Krajowej - Borowska",

        }, {

            "lat": "51.08016629798973",
            "lng": "17.04749822616577",
            "name": "Krynicka",

        }, {

            "lat": "51.09156257672623",
            "lng": "17.040224075317383",
            "name": "Gliniana - Gajowa",

        }, {

            "lat": "51.07496256893404",
            "lng": "17.006921768188477",
            "name": "Park Południowy - Powstańców Śląskich",

        }, {

            "lat": "51.08013933717133",
            "lng": "16.99460506439209",
            "name": "Racławicka - Rymarska",

        }, {

            "lat": "51.07333122768277",
            "lng": "16.995055675506592",
            "name": "Skarbowców - Wietrzna",

        }, {

            "lat": "51.111955645831195",
            "lng": "16.960535645484924",
            "name": "Strzegomska - Gubińska",

        }, {

            "lat": "51.112171183577146",
            "lng": "17.06024408340454",
            "name": "Rondo Reagana",


        }, {

            "lat": "51.094668940345535",
            "lng": "17.026888132095333",
            "name": "Arena - Komandorska",

        }, {

            "lat": "51.08774166546555",
            "lng": "17.040288448333737",
            "name": "Kamienna - Gajowa",

        }, {

            "lat": "51.099264089082496",
            "lng": "17.02756404876709",
            "name": "Arkady",

        }, {

            "lat": "51.094520702137686",
            "lng": "17.020998001098633",
            "name": "Sky Tower",

        }, {

            "lat": "51.11287840974499",
            "lng": "17.039633989334103",
            "name": "Hala Targowa ",
        }, {

            "lat": "51.10971938239645",
            "lng": "17.0302677154541",
            "name": "Rynek ",

        }, {

            "lat": "51.11143026836378",
            "lng": "17.021266222000122",
            "name": "Jana Pawła II",

        }, {

            "lat": "51.11760644376091",
            "lng": "17.007222175598145",
            "name": "Zachodnia - Poznańska",

        }, {

            "lat": "51.11346438894182",
            "lng": "17.00635313987732",
            "name": "Plac Strzegomski",

        }, {

            "lat": "51.11533677840705",
            "lng": "16.998703479766846",
            "name": "Dworzec Mikołajów",

        }, {

            "lat": "51.11010332688538",
            "lng": "17.047863006591797",
            "name": "Muzeum Narodowe",


        }, {

            "lat": "51.1019589785129",
            "lng": "17.10146427154541",
            "name": "Olszewskiego - Spółdzielcza",

        }, {

            "lat": "51.104384244689136",
            "lng": "17.02254295349121",
            "name": "Plac Legionów",

        }, {

            "lat": "51.104121513665575",
            "lng": "17.031673192977905",
            "name": "Świdnicka - Chrobry",

        }, {

            "lat": "51.10123811098068",
            "lng": "17.02876567840576",
            "name": "Świdnicka - Piłsudskiego",

        }, {

            "lat": "51.11390891992754",
            "lng": "17.067153453826904",
            "name": "Kredka i Ołówek",

        }, {

            "lat": "51.12887566759688",
            "lng": "17.04499840736389",
            "name": "Promenady Business Park",

        }, {

            "lat": "51.048031338767885",
            "lng": "16.9643497467041",
            "name": "Aleja Bielany",

        }, {

            "lat": "51.136022",
            "lng": "17.036164",
            "name": "Żmigrodzka / Kasprowicza",

        }, {

            "lat": "51.10669149786965",
            "lng": "17.142872214317322",
            "name": "Strachocińska / Wieśniacza",

        }]
        

        bikeStands.forEach(function(bikeStand) {
          placeBikeMarker({
            lat:+bikeStand.lat,
            lng:+bikeStand.lng
          }, bikeStand.name);
        });

      }

      initMap();
        
      