import request from 'supertest';
import { expect } from 'chai';
import app from '../app.mjs';

describe('GET /', () => {
  it('should return Welcome to ToyeGlobal', async () => {
    const res = await request(app).get('/');
    expect(res.status).to.equal(200);
    expect(res.text).to.equal('Welcome to ToyeGlobal');
  });
});
