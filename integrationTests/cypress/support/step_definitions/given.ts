import {Given} from '@badeball/cypress-cucumber-preprocessor';

Given('diagram type is set to ascii', () => {
    cy.get('#btn-settings').click();
    // wait so settings json gets loaded
    cy.get('.view-line:contains("{")', { timeout: 2000 }).should('exist');
    cy.get('#diagramPreviewType').select('txt')
    cy.get('#settings-ok-btn').click();
});