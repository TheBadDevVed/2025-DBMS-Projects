module.exports = {
  testEnvironment: 'node',
  transform: {},
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.test.js'],
  moduleFileExtensions: ['js', 'json'],
  collectCoverageFrom: ['src/controller/details.controller.js'],
};