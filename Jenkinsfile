#!groovy
@Library([
  'pipe-build-lib',
  'ces-build-lib',
  'dogu-build-lib@fix/preset-for-new-coder-instance'
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

pipe.setBuildProperties()
pipe.addDefaultStages()
pipe.run()
