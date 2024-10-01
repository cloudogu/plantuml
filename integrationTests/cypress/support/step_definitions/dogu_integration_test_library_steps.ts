import {
    Then,
    When
} from "@badeball/cypress-cucumber-preprocessor";
// Loads all steps from the dogu integration library into this project

When("the user clicks the dogu logout button", function () {
    cy.get('[data-testid="navbar-nav-item-right-bar-user-trigger"]').click();
    cy.get('[data-testid="navbar-nav-item-right-bar-user-logout-normal"]').click();
});

Then("the user has administrator privileges in the dogu", function () {
    cy.get('#user-field-role-admine')
});

Then("the user has no administrator privileges in the dogu", function () {
    cy.get('#user-field-role-reader')
});

const doguTestLibrary = require('@cloudogu/dogu-integration-test-library')
doguTestLibrary.registerSteps()