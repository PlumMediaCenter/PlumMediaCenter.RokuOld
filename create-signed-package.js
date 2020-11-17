var rokuDeploy = require('roku-deploy');
rokuDeploy.deployAndSignPackage({
    outFile: 'PlumMediaCenter',
    signingPassword: '2XPxZpIzgplvjaT+FIk74g=='
    //other options if necessary
}).then(function (pathToSignedPackage) {
    console.log('Signed package created at ', pathToSignedPackage);
}, function (err) {
    //it failed
    console.error(err);
});