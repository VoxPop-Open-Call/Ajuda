import { faker } from "@faker-js/faker";

Cypress.Commands.add("login", ({ email, password }) => {
  cy.visit("/");
  cy.get('input[placeholder="Email"]').type(email);
  cy.get('input[placeholder="Password"]').type(password);
  cy.get('button:contains("Login")').click();
});

Cypress.Commands.add("apiLogin", ({ email, password }) => {
  return cy.request({
    method: "POST",
    url: `${Cypress.env("dexUrl")}/token`,
    body: {
      username: email,
      password,
      grant_type: "password",
      client_id: Cypress.env("apiClientId"),
      client_secret: Cypress.env("apiClientSecret"),
      scope: "openid profile email offline_access",
    },
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
  });
});

Cypress.Commands.add("createUser", ({ name, email, password }) => {
  return cy.request("POST", `${Cypress.env("apiUrl")}/users`, {
    name,
    email,
    password,
  });
});

Cypress.Commands.add("createRandomUser", () => {
  return cy.createUser({
    name: faker.internet.userName(),
    email: faker.internet.email(),
    password: faker.internet.password(),
  });
});
