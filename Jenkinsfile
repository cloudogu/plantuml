#!groovy
@Library([
  'pipe-build-lib',
  'ces-build-lib',
  'dogu-build-lib'
]) _

def pipe = new com.cloudogu.sos.pipebuildlib.DoguPipe(this, [
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
    doBatsTests         : true,
    cypressImage        : "cypress/included:13.14.2",
])

pipe.setBuildProperties()
pipe.addDefaultStages()
pipe.run()
