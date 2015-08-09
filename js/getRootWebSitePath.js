function getRootWebSitePath()
{
var location = document.location.toString();
var applicationNameIndex = location.indexOf('/', location.indexOf('://') + 3);
var applicationName = location.substring(0, applicationNameIndex) + '/';
var webFolderIndex = location.indexOf('/', location.indexOf(applicationName) + applicationName.length);
var webFolderFullPath = location.substring(0, webFolderIndex);
//return webFolderFullPath;
return location;
}
var rootDir = getRootWebSitePath();