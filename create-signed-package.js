var rokuDeploy = require('roku-deploy');
rokuDeploy.deployAndSignPackage({
    files: [
        "manifest",
        "source/**/*.*",
        "images/**/*.*"
    ],
    outFile: 'PlumMediaCenter',
    host: '192.168.1.103',
    password: 'password',
    signingPassword: 'SECRET'
    //other options if necessary
}).then(function (pathToSignedPackage) {
    console.log('Signed package created at ', pathToSignedPackage);
}, function (err) {
    //it failed
    console.error(err);
});