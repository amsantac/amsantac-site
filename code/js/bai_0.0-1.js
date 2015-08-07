
var tecoreg = ee.FeatureCollection('ft:1Ec8IWsP8asxN-ywSqgXWMuBaxI6pPaeh6hC64lA');
var llanos = tecoreg.filterMetadata('G200_REGIO', 'equals', 'Llanos Savannas');

var start_date = '2004-05-01';
var end_date = '2004-06-30';

var collection1 = ee.ImageCollection('LEDAPS/LE7_L1T_SR').filterDate(start_date, end_date).sort();
  
var collection2 = ee.ImageCollection('MODIS/MCD43A4_BAI').filterDate(start_date, end_date).sum();

// var stats = collection1.aggregate_stats('BAI');
//print("max is: " + stats.getInfo().values.max);

// print('collection1: ', collection1);
// Map.addLayer(llanos, {}, 'Llanos');
// Create a blank image to accept the polygon outlines.
var image1 = ee.Image(0).mask(0);
// Outline using the specified color and width.
var image2 = image1.paint(llanos, '0000ff', 4); 

addToMap(collection1,
  {'bands':['B4', 'B5', 'B3'],
   'min': 0, 'max': 10000
  }, "Landsat");

//addToMap(collection2,
//  {'min': 0, 'max': 1000}, "BAI");

// add rasterized vector  
Map.addLayer(image2, {
    'palette': '0000ff',
    'opacity': 0.5
}, "llanos");

// Map.centerObject(llanos, 7);
//centerMap(-70.9126, 5.5873, 10);

centerMap(-71.1581, 5.5186, 13);