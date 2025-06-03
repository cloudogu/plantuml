import {Given} from '@badeball/cypress-cucumber-preprocessor';

Given('diagram type is set to ascii', () => {
    cy.clickWarpMenuCheckboxIfPossible();
    cy.get('#btn-settings').click();
    // wait so settings json gets loaded
    cy.wait(2500);
    cy.get('#diagramPreviewType').select('txt')
    cy.get('#settings-ok-btn').click();
});
