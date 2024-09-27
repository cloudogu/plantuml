import {Given} from "@badeball/cypress-cucumber-preprocessor";

Given("diagram type is set to ascii", () => {
    // wait so settings json gets loaded
    cy.wait(1000);
    cy.get('#btn-settings').click();
    cy.get('#diagramPreviewType').select('txt')
    cy.get('#settings-ok-btn').click();
});