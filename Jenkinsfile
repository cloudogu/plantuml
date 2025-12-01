#!groovy
@Library([
  'pipe-build-lib',
  'ces-build-lib',
  'dogu-build-lib@feature/75-include-ecosystem-core-for-cluster-setup'
]) _

def pipe = new com.cloudogu.sos.pipebuildlib.DoguPipe(this, [
    doguName: "plantuml",
    updateSubmodules    : false,
    shellScripts        : "./resources/startup.sh ./resources/opt/apache-tomcat/bin/setenv.sh",
    dependencies        : ["nginx"],
    checkMarkdown       : true,
    runIntegrationTests : true,
    doBatsTests         : true,
    cypressImage        : "cypress/included:13.14.2",
])

# test

pipe.setBuildProperties()
pipe.addDefaultStages()
pipe.run()
