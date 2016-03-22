

var width = 960,
    height = 1160;

var svg = d3.select("#right_box").append("svg")
    .attr("width", width)
    .attr("height", height);

//set up projection
var projection = d3.geo.mercator()
    .scale(4050)
    .center([-478,41])
    .translate([width / 2, height / 2]);

var path = d3.geo.path()
    .projection(projection)

d3.json("media/js/or3.json", function(error, or) {
  if (error) return console.error(error);

  //draw the state

  svg.selectAll(".orstate")
    .data(topojson.feature(or, or.objects.orstates).features)
    .enter().append("path")
    .attr("class", function(d) { return "orstate " + d.id; })
    .attr("filter","url(#map-img)")
    .attr("d", path);

  svg.append("filter")
    .attr("id", "map-img")
    .attr("x", "0%")
    .attr("y", "0%")
    .attr("width","100%")
    .attr("height","100%")
    .append("feImage")
    .attr("xlink:href", "media/images/or/or-map.png" );

  svg.append("filter")
    .attr("id","textbg")
    .attr("x", "0%")
    .attr("y", "0%")
    .attr("width","100%")
    .attr("height","100%")
    .append("feFlood")
    .attr("flood-opacity",".6")
    .attr("flood-color","#F7F3E6");
  svg.selectAll("#textbg")
    .append("feComposite")
    .attr("in","SourceGraphic");

  var label_array = [];
  var anchor_array = [];

  d3.csv("media/titlecities.txt", function(error, data){
    svg.selectAll("circle")
    .data(data)
    .enter()
    .append("circle")
    .attr("cx", function(d){return projection([d.lon, d.lat])[0]; })
    //populate arrays that will be updated by algorithm
    .attr("cy", function(d){
       label_array.push({x:projection([d.lon, d.lat])[0],
                         y:projection([d.lon, d.lat])[1],
                         name:d.label,
                         width:0.0,
                         height:0.0,
                         url:d.url
                         });
       anchor_array.push({x:projection([d.lon, d.lat])[0],
                         y:projection([d.lon, d.lat])[1],
                         r:2
                         });
       return projection([d.lon, d.lat])[1];
      })
      .attr("r",2)
      .style("fill","#254117");

  //add labels, use arrays for data
  var placelabels =  svg.selectAll(".place-label")
    .data(label_array)
    .enter().append("svg:a")
    .attr("xlink:href", function(d) {return d.url;})
    .attr("class", "place-label")
    .attr("x", function(d){return d.x;})
    .attr("y", function(d){return d.y;})
    .append("text")
    .attr("filter","url(#textbg)")
    .text(function(d) { return d.name; });

  //get size of the labels
  var nsweeps = 200;
  var index = 0;
  placelabels.each(function() {
    label_array[index].width = this.getBBox().width +5;
    label_array[index].height = this.getBBox().height;
    index += 1;
  });

  //run labeler to update the arrays
   d3.labeler()
        .label(label_array)
        .anchor(anchor_array)
        .width(900)
        .height(1160)
        .start(nsweeps);

  //move labels to new positions
  placelabels
    .transition()
    .duration(50)
    .attr("x", function(d) { return (d.x); })
    .attr("y", function(d) { return (d.y); });
 });
});
