import { defineConfig } from "cypress";
// @ts-ignore
import fsConf from "cypress-fs/plugins/index.js";
// @ts-ignore
import createBundler from "@bahmutov/cypress-esbuild-preprocessor";
import { addCucumberPreprocessorPlugin } from "@badeball/cypress-cucumber-preprocessor";
import createEsbuildPlugin from "@badeball/cypress-cucumber-preprocessor/esbuild";
import doguTestLibrary from "@cloudogu/dogu-integration-test-library";

async function setupNodeEvents(on, config) {
    // This is required for the preprocessor to be able to generate JSON reports after each run, and more,
    await addCucumberPreprocessorPlugin(on, config);

    on(
        "file:preprocessor",
        createBundler({
            plugins: [createEsbuildPlugin(config)],
        })
    );

    fsConf(on);

    config = doguTestLibrary.configure(config);

    return config;
}

export default defineConfig({
    e2e: {
        baseUrl: "https://192.168.56.2",
        env: {
            "DoguName": "plantuml",
            "MaxLoginRetries": 3,
            "AdminUsername": "ces-admin",
            "AdminPassword": "Ecosystem2016!",
            "AdminGroup": "CesAdministrators"
        },
        retries : {
            runMode: 2,
            openMode: 0
        },
        videoCompression: false,
        specPattern: ["cypress/e2e/**/*"],
        excludeSpecPattern: ["cypress/e2e/**/cas_browser.feature", "cypress/e2e/**/privileges.feature"],
        setupNodeEvents,
    },
});
