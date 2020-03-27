var rokuDeploy = require('roku-deploy');
rokuDeploy.deployAndSignPackage({
    files: [
        "manifest",
        "source/**/*.*",
        "images/**/*.*"
    ],
    outFile: 'PlumMediaCenter',
    host: '192.168.1.104',
    password: 'password',
    signingPassword: '2XPxZpIzgplvjaT+FIk74g=='
    //other options if necessary
}).then(function (pathToSignedPackage) {
    console.log('Signed package created at ', pathToSignedPackage);
}, function (err) {
    //it failed
    console.error(err);
});