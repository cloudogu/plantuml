import {Given} from '@badeball/cypress-cucumber-preprocessor';

// Given('diagram type is set to ascii', () => {
//     cy.clickWarpMenuCheckboxIfPossible();
//     cy.get('#btn-settings').click();
//     // wait so settings json gets loaded
//     cy.wait(2500);
//     cy.get('#diagramPreviewType').select('txt')
//     cy.get('#settings-ok-btn').click();
// });

Given('diagram type is set to ascii', () => {
  cy.clickWarpMenuCheckboxIfPossible();
  cy.get('#btn-settings').click();
  cy.wait(2500);

  cy.get('#diagramPreviewType').select('txt');

cy.window().then((win) => {
  const allModels = win.monaco?.editor?.getModels?.();
  // Find the one *not* containing the diagram code
  const settingsModel = allModels.find((model) => {
    return !model.getValue().includes('@startuml');
  });

  if (settingsModel) {
    settingsModel.setValue(`{
  "automaticLayout": true,
  "fixedOverflowWidgets": true,
  "minimap": {
    "enabled": false
  },
  "scrollbar": {
    "alwaysConsumeMouseWheel": false
  },
  "scrollBeyondLastLine": false,
  "tabSize": 2,
  "theme": "vs"
}`);
  } else {
    throw new Error('Could not find Monaco settings model');
  }
});

  cy.get('#settings-ok-btn').click({ force: true });
});

