#!groovy
@Library([
  'github.com/cloudogu/build-lib-wrapper@develop',
  'ces-build-lib',
  'dogu-build-lib'
]) _

// Now call the sharedBuildPipeline function with your custom configuration.
sharedBuildPipeline([
    // Required parameter
    doguName: "plantuml",
    
    // Optional parameters – override defaults here
    preBuildAgent       : 'sos',
    buildAgent          : 'sos',
    doguDirectory       : "/dogu",
    namespace           : "official",
    
    // Credentials and git information
    gitUser             : "cesmarvin",
    committerEmail      : "cesmarvin@cloudogu.com",
    gcloudCredentials   : "gcloud-ces-operations-internal-packer",
    sshCredentials      : "jenkins-gcloud-ces-operations-internal",
    backendUser         : "cesmarvin-setup",
    
    // Additional options
    updateSubmodules    : false,
    shellScripts        : "./resources/startup.sh ./resources/opt/apache-tomcat/bin/setenv.sh",
    dependencies        : ["nginx"],
    checkMarkdown       : true,
    runIntegrationTests : true,
    cypressImage        : "cypress/included:13.14.2",
])
