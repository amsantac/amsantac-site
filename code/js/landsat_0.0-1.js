
var tecoreg = ee.FeatureCollection('ft:1Ec8IWsP8asxN-ywSqgXWMuBaxI6pPaeh6hC64lA');
var llanos = tecoreg.filterMetadata('G200_REGIO', 'equals', 'Llanos Savannas');

var llanos_col = ee.FeatureCollection('ft:1X_CeRfYiZ_4F-G9cu78pxjKTI_xD6yHeFiLvVOki');

var image1 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040562000023EDC00');
var image2 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040572000023EDC00');
var image3 = ee.Image('LEDAPS/LE7_L1T_SR/LE70050552000046EDC00');
var image4 = ee.Image('LEDAPS/LE7_L1T_SR/LE70050562000110AGS01');
var image5 = ee.Image('LEDAPS/LT5_L1T_SR/LT50050572000278XXX02');
var image6 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060552000005EDC00');
var image7 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060562000005EDC00');
var image8 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060572000005EDC00');
var image9 = ee.Image('LEDAPS/LT5_L1T_SR/LT50060582000029XXX02');
var image10 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070562000348EDC00');
var image11 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070572000076EDC00');
var image12 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070582000348EDC00');

var collection1 = ee.ImageCollection.fromImages(
  [image1, image2, image3, image4, image5, image6, image7, image8, image9, image10, image11, image12]);
print('collection1: ', collection1);

// Map.addLayer(llanos, {}, 'Llanos');
// Create a blank image to accept the polygon outlines.
var image1 = ee.Image(0).mask(0);
// Outline using the specified color and width.
// var image2 = image1.paint(llanos, '0000ff', 4); 
var image2 = image1.paint(llanos_col, '0000ff', 4);

function toMask(image) {
  return image.mask(image.clip(llanos_col));
}

addToMap(collection1.map(toMask),
  {'bands':['B4', 'B5', 'B3'],
   'min': 0, 'max': 10000
  });

// Define the parameters to specify color  
Map.addLayer(image2, {
    'palette': '0000ff',
    'opacity': 0.5
});

Map.centerObject(llanos_col, 7);
