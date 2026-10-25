const test = require('node:test');
const assert = require('node:assert');
const { add } = require('./index');

test('add numbers correctly', () => {
  assert.strictEqual(add(2, 3), 5);
  assert.strictEqual(add(-1, 1), 0);
});
