#!groovy
@Library(['github.com/cloudogu/ces-build-lib@2.0.1', 'github.com/cloudogu/dogu-build-lib@v2.3.0'])
import com.cloudogu.ces.cesbuildlib.*
import com.cloudogu.ces.dogubuildlib.*

node('docker') {

    stage('Checkout') {
        checkout scm
    }

    stage('Lint') {
        Dockerfile dockerfile = new Dockerfile(this)
        dockerfile.lint()
    }

    stage('Shellcheck') {
        shellCheck("resources/startup.sh")
        shellCheck("resources/opt/apache-tomcat/bin/setenv.sh")
    }
    stage('Check markdown links') {
        Markdown markdown = new Markdown(this, "3.11.0")
        markdown.check()
    }
}
node('vagrant') {
    Git git = new Git(this, "cesmarvin")
    git.committerName = 'cesmarvin'
    git.committerEmail = 'cesmarvin@cloudogu.com'
    GitFlow gitflow = new GitFlow(this, git)
    GitHub github = new GitHub(this, git)
    Changelog changelog = new Changelog(this)

    timestamps {
        properties([
                // Keep only the last x builds to preserve space
                buildDiscarder(logRotator(numToKeepStr: '10')),
                // Don't run concurrent builds for a branch, because they use the same workspace directory
                disableConcurrentBuilds(),
                parameters([
                    booleanParam(defaultValue: true, description: 'Enables cypress to record video of the integration tests.', name: 'EnableVideoRecording'),
                    booleanParam(defaultValue: true, description: 'Enables cypress to take screenshots of failing integration tests.', name: 'EnableScreenshotRecording'),
                ])
        ])

        EcoSystem ecoSystem = new EcoSystem(this, "gcloud-ces-operations-internal-packer", "jenkins-gcloud-ces-operations-internal")

        try {
            stage('Bats Tests') {
                Bats bats = new Bats(this, docker)
                bats.checkAndExecuteTests()
            }

            stage('Provision') {
                ecoSystem.provision("/dogu")
            }

            stage('Setup') {
                ecoSystem.loginBackend('cesmarvin-setup')
                ecoSystem.setup()
            }

            stage('Wait for dependencies') {
                timeout(15) {
                    ecoSystem.waitForDogu("nginx")
                }
            }

            stage('Build') {
                ecoSystem.build("/dogu")
            }

            stage('Trivy scan') {
                Trivy trivy = new Trivy(this, ecoSystem)
                trivy.scanDogu("/dogu", TrivyScanFormat.HTML, params.TrivyScanLevels, params.TrivyStrategy)
                trivy.scanDogu("/dogu", TrivyScanFormat.JSON,  params.TrivyScanLevels, params.TrivyStrategy)
                trivy.scanDogu("/dogu", TrivyScanFormat.PLAIN, params.TrivyScanLevels, params.TrivyStrategy)
            }

            stage('Verify') {
                ecoSystem.verify("/dogu")
            }

            stage('Integration Tests') {
                echo "run integration tests."
                ecoSystem.runCypressIntegrationTests([
                        cypressImage     : "cypress/included:13.13.1",
                        enableVideo      : params.EnableVideoRecording,
                        enableScreenshots: params.EnableScreenshotRecording,
                ])
            }

            if (gitflow.isReleaseBranch()) {
                String releaseVersion = git.getSimpleBranchName();

                stage('Finish Release') {
                    gitflow.finishRelease(releaseVersion)
                }

                stage('Push Dogu to registry') {
                    ecoSystem.push("/dogu")
                }

                stage('Add Github-Release') {
                    github.createReleaseWithChangelog(releaseVersion, changelog)
                }
            }
        } finally {
            stage('Clean') {
                ecoSystem.destroy()
            }
        }
    }
}
