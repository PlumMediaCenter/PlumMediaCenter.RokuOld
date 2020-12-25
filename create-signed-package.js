var rokuDeploy = require('roku-deploy');
rokuDeploy.deployAndSignPackage({
    rootDir: "dist",
    retainStagingFolder: true,
    stagingFolderPath: "out/.roku-deploy-staging",
    outFile: 'PlumMediaCenter',
    signingPassword: '2XPxZpIzgplvjaT+FIk74g==',
    files: [
        "**/*",
        "!**/*.map"
    ]
    //other options if necessary
}).then(function (pathToSignedPackage) {
    console.log('Signed package created at ', pathToSignedPackage);
}, function (err) {
    //it failed
    console.error(err);
});