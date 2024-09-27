// Loads all commands from the dogu integration library into this project
import '@bahmutov/cy-api'
import doguTestLibrary from "@cloudogu/dogu-integration-test-library";

doguTestLibrary.registerCommands()

import "./commands/required_commands_for_dogu_lib"

declare global {
    namespace Cypress {
        interface Chainable {
            startDogu(dogu: string): void
            stopDogu(dogu: string): void
            disableDebugMode(): void
            enableDebugMode(timer: number): void
            waitAndLogin(): void
            waitForCas(): void
            logout(): void
            waitUntilUnreachable(page:string): void
        }
    }
}