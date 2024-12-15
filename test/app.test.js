// test/app.test.js

const request = require('supertest');  // Supertest is used for HTTP assertions
const app = require('../simple-node-api');  // Your Express app (make sure the path is correct)

describe('GET /', () => {
  it('should return Hello, World!', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.text).toBe('Hello, World!');
  });
});
